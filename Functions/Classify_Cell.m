function [type] = Classify_Cell(Cell)
%Classify_Cell

if Cell.Properties.SagReb.Rebound.ReboundLocation_ms < 90
    type = 'Type 2';
    return
end

Ca_buffer = Cell.CaBuffer;

type_overall = cell(1, 8);

figure;

for i = 3:8
    
    % Load the LDA fit and standardized data values with the appropriate calcium buffer and spike number   
    load(strcat('Standardized_Data_Values_', Ca_buffer, '_', mat2str(i)))
    load(strcat('LDA_fit_var_', Ca_buffer, '_', mat2str(i)))
    
    adaptation_ratio = reallog(Cell.Properties.(sprintf('APWaveformValues_%dspikes', i)).adaptation_ratio.Adaptation_Ratio_1(2));
    dVdt_rising = Cell.Properties.(sprintf('APWaveformValues_%dspikes', i)).dVdt_rising.percent20(i);
    threshold_vs_threshold = Cell.Properties.(sprintf('APWaveformValues_%dspikes', i)).mV_change.threshold_vs_threshold(i);
    sag = Cell.Properties.SagReb.Sag.sag_amplitude_fit;
    reb_delta_t = Cell.Properties.SagReb.Rebound.reb_delta_t;
    
    % Standardize the given cell
    Non_Fluor_array = [adaptation_ratio, dVdt_rising, threshold_vs_threshold, sag, reb_delta_t];
    Variable_means_matrix = repmat(fluor_means, size(Non_Fluor_array, 1), 1);
    Variable_stdev_matrix = repmat(fluor_stdev, size(Non_Fluor_array, 1), 1);
    NonFluor_points = (Non_Fluor_array-Variable_means_matrix)./Variable_stdev_matrix;
   
    % Compute the distance from decision boundary of the genetically labelled cells and the given
    % nonfluorescent cell
  
    D1_distances = distance_from_hyperplane(K, L, D1_points);
    D3_distances = distance_from_hyperplane(K, L, D3_points);
    NonFluor_distances = distance_from_hyperplane(K, L, NonFluor_points);
    
    % Fit normal distributions to both D1 and D3 values 
    pd_D1 = fitdist(D1_distances,'Normal');
    pd_D3 = fitdist(D3_distances, 'Normal');
    x_values = -10:.01:10;
    y_D1 = pdf(pd_D1,x_values);
    y_D3 = pdf(pd_D3, x_values);    
    
    % Set cutoffs for exclusion zone
    
    cutoff_D1 = pd_D1.mean-1.64*pd_D1.std; cutoff_D3 = pd_D3.mean+1.64*pd_D3.std;
    
    if cutoff_D1 > 0
        cutoff_D1 = 0;
    end
    
    if cutoff_D3 < 0
        cutoff_D3 = 0;
    end
    
    % Plot the data
    
    subplot(2, 3, i-2); hold on
        
    grey = [.5, .5, .5]; lightgrey =  [0.8242, 0.8242, 0.8242]; blue =  [0.1172, 0.5625, 1.0000]; 
    
    exclusion_zone = histogram(0, 1);
    exclusion_zone.BinEdges = sort([cutoff_D1, cutoff_D3]);
    exclusion_zone.FaceAlpha = .5;
    exclusion_zone.FaceColor = grey;
    exclusion_zone.EdgeColor = lightgrey;
        
    plot([0, 0], [0, 1], '--r', 'LineWidth', 1.5)
    plot(x_values,y_D1,'LineWidth',2, 'Color', 'k')
    plot(x_values,y_D3,'LineWidth',2, 'Color', blue)
    
    plot(D1_distances, .15, 'ok')
    plot(NonFluor_distances,.2, 'o', 'MarkerSize', 7, 'MarkerEdgeColor', 'r', 'LineWidth', .5)
    plot(D3_distances, .25, 'o', 'Color', blue)
    
    xlim([-5, 5]); ylim([0, .7])
    xlabel('Distance from Decision Boundary'); ylabel('Probability')
    
    % Determine cell classification based on current spike number
    if NonFluor_distances <=cutoff_D1
        type = 'Type 3';
        type_overall{i} = 3;
    elseif NonFluor_distances >= cutoff_D3
        type = 'Type 1';
        type_overall{i} = 1;
    elseif ~isnan(NonFluor_distances)
        type = 'Unidentified';
    else
        type = 'Unidentified: No Sweep';
    end
    
    spike_num = sprintf('%d spikes', i);
    type_identification = sprintf('ID: %s', type);
    
    text(-4.5, .55, spike_num)
    text(-4.5, .5, type_identification)
    
    fig = gcf;
    fig.CurrentAxes.TickDir = 'out'; 

    
end


% Determine the overall cell type and use that to make the title
idx = find(~cellfun(@isempty, type_overall));
type_identifier_overall = type_overall(idx);
type_identifier_overall = cell2mat(type_identifier_overall);

if isempty(type_identifier_overall)
    type = 'Unidentified';
elseif all(type_identifier_overall == type_identifier_overall(1))
    type = sprintf('Type %d', type_identifier_overall(1));
else
    type = 'Unidentified';
end


fig = gcf;
set(fig, 'Position', [336, 180, 1234, 675])
subplot(2, 3, 2)
if strcmp(type, 'Unidentified')
    title('Unidentified Cell')
else
    title(type);
end


end






