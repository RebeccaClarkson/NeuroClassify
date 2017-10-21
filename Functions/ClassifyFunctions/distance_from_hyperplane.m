function [distance] = distance_from_hyperplane(K, L, points)
%distance_from_hyperplane
% Calculates the distance of the input point from the hyperplane determined
% from Linear Discriminant Analysis, with sign indicating the side of the hyperplane.  

% 

number_of_points = size(points, 1); 


%%
num_variables = 5; 
x = sym('x', [1, num_variables]);  

hyperplane_equation = dot(L, x) + K(1); % define the equation for the hyperplane
solved_hyperplane_equation  = solve(hyperplane_equation, x(end)); % solve this equation for the final variable

normal_vector = [L(1:end)]'; %  get length normal vector
unit_normal = normal_vector/norm(normal_vector);
unit_normal = repmat(unit_normal, number_of_points, 1);

solved_point_on_plane = subs(solved_hyperplane_equation, x(1:end-1), [1:1:num_variables-1]); % get a point on the hyperplane 


v_plane_to_point = bsxfun(@minus, points, [1:1:num_variables-1, sym2poly(solved_point_on_plane)]); % get the vector from the point on the hyperplane to the desired point 

distance = dot(unit_normal, v_plane_to_point, 2); % solve for distance

end

