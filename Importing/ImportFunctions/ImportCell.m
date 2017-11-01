function[Cell] = ImportCell(Cell_to_load, select_sweeps)
%IMPORT_CELL
%

% All cells from Igor must within the matlab file path in the below folder; 


% Import cell from igor
try
    Cell = load_ibw(Cell_to_load);
    Cell = ConvertDAQ(Cell);
    Cell.Fs = intersect(Cell.kHz, Cell.kHz)*1000;
catch ME
    warning(ME.message)
end


% Determine what calcium buffer was used

% Setting default as 'EGTA'
Cell.CaBuffer = 'EGTA';
% str = input('What calcium buffer was used? (Fluo5 or EGTA)  ', 's');
% if ~strcmp(str, 'Fluo5') && ~strcmp(str, 'EGTA')
%     str = input('Please enter "Fluo5" or "EGTA"  ', 's');
% end
% Cell.CaBuffer = str;



% Establish Cell.time
[~, num_sweeps] = size(Cell.data);
Cell.time = nan(max(intersect(Cell.DAQ, Cell.DAQ)), num_sweeps);

for ii = 1:num_sweeps
    points_per_sec = Cell.kHz(ii)*1000;
    num_points = Cell.DAQ(ii);
    sec_per_sweep = num_points/points_per_sec;
    sec_per_point = 1/points_per_sec;
    Cell.time(1:num_points, ii) = [0:sec_per_point:sec_per_sweep-sec_per_point]';
end

%%  Select input resistance and sag/rebound sweeps

[Cell.Properties.Rin.Sweep, Cell.Properties.Rin.AveragedSweeps] = SelectInputResistance();
[Cell.Properties.SagReb.Sweep, Cell.Properties.SagReb.AveragedSweeps] = SelectSagReboundSweeps();

    function [Rin_Sweep_Average, Rin_Sweeps_Idx] = SelectInputResistance()
        Rin_Sweeps_Idx = intersect(find(Cell.sweep_time<300), find(any(Cell.commands==-50)));
        Rin_Sweeps = Cell.data(:, Rin_Sweeps_Idx);
        
        % Remove nan from any row that contains it - this assumes that all
        % selected sweeps have the same sampling frequency
        Rin_Sweeps = Rin_Sweeps(~any(isnan(Rin_Sweeps),2), :);
        
        if select_sweeps == 1
            figure
            fig = gcf;
            fig.Position = [1107, 541, 560, 420];
            plot(Rin_Sweeps)
            clickableLegend(num2str(Rin_Sweeps_Idx)) % clickableLegend is a downloaded script
            
            str = input('Do you want to remove any sweeps? y/n   ', 's');
            if str ~= 'y' && str ~= 'n'
                str = input('Please enter "y" or "n"  ', 's');
            end
            
            Rin_Sweeps_Tmp = Rin_Sweeps;
            
            if str == 'y'
                sweeps_to_remove= input('What sweeps do you want to remove?   ');
                
                all_indices_to_remove = [];
                for i = 1:length(sweeps_to_remove)
                    current_sweep = sweeps_to_remove(i);
                    current_ind = find(Rin_Sweeps_Idx == current_sweep);
                    all_indices_to_remove = [all_indices_to_remove current_ind];
                end
                
                Rin_Sweeps_Tmp(:, all_indices_to_remove) = [];
                figure
                fig = gcf;
                fig.Position = [1107, 541, 560, 420];
                plot(Rin_Sweeps_Tmp)
                str = input('Do you want to keep these changes? y/n  ', 's');
                
                if str ~= 'y' && str ~= 'n'
                    str = input('Please enter "y" or "n"  ', 's');
                end
                
                if str == 'y'
                    Rin_Sweeps = Rin_Sweeps_Tmp;
                    Rin_Sweeps_Idx(all_indices_to_remove) = [];
                elseif str == 'n'
                    % if you don't want to save these changes, it will start over
                    % the sweep selection process
                    [Cell.Properties.Rin.Sweep, Cell.Properties.Rin.AveragedSweeps] = SelectInputResistance();
                end
            end
        end
        
        
        
        % Compute the average Rin sweep, the output of this function
        
        Rin_Sweep_Average = mean(Rin_Sweeps, 2);
        
        
    end

    function [SagRebSweep, SagReb_Sweeps_Idx] = SelectSagReboundSweeps()
        % Find all -400 pA hyperpolarizing pulses within the first 5 minutes
        % (or occassionally 10 minutes, if characterized a bit slower)
        SagReb_Sweeps_Idx = intersect(find(Cell.sweep_time<300), find(any(Cell.commands==-400)));
        SagReb_Sweeps = Cell.data(:, SagReb_Sweeps_Idx);
        %%
        if select_sweeps == 1
            % Display these sweeps to see if you need to remove any
            plot(SagReb_Sweeps)
            clickableLegend(num2str(SagReb_Sweeps_Idx)) % clickableLegend is a downloaded script
            
            str = input('Do you want to remove any sweeps? y/n   ', 's');
            if str ~= 'y' && str ~= 'n'
                str = input('Please enter "y" or "n"  ', 's');
            end
            
            % Create a temporary sagreb_sweeps so that you can check you removed
            % the right sweeps, if necessaryv
            SagReb_Sweeps_Tmp = SagReb_Sweeps;
            
            if str == 'y'
                sweeps_to_remove= input('What sweeps do you want to remove?   ');
                
                if ~isa(sweeps_to_remove, 'numeric')
                    input('Please enter a number  ', 's');
                end
                
                
                all_indices_to_remove = [];
                SagReb_Sweeps_Idx_Tmp = SagReb_Sweeps_Idx;
                
                % Remove sweeps if desired
                for i = 1:length(sweeps_to_remove)
                    current_sweep = sweeps_to_remove(i);
                    current_ind = find(SagReb_Sweeps_Idx == current_sweep);
                    all_indices_to_remove = [all_indices_to_remove current_ind];
                    
                end
                
                SagReb_Sweeps_Tmp(:, all_indices_to_remove) = [];
                % Plot the remaining sweeps and see if you want to keep the changes
                figure
                fig = gcf;
                fig.Position = [1107, 541, 560, 420];
                plot(SagReb_Sweeps_Tmp)
                
                str = input('Do you want to keep these changes? y/n  ', 's');
                
                if str ~= 'y' && str ~= 'n'
                    str = input('Please enter "y" or "n"  ', 's');
                end
                
                if str == 'y'
                    SagReb_Sweeps = SagReb_Sweeps_Tmp;
                    SagReb_Sweeps_Idx(all_indices_to_remove) = [];
                    
                elseif str == 'n'
                    % if you don't want to save these changes, it will start over
                    % the sweep selection process
                    [Cell.Properties.SagReb.Sweep, Cell.Properties.SagReb.AveragedSweeps] = SelectSagReboundSweeps()
                end
                
            end
        end
        
        
        % Calculate the average sag and rebound sweep
        SagRebSweep = mean(SagReb_Sweeps, 2);
        
        
        
    end


[Cell] = InputCellProperties(Cell);

end

function [Cell] = InputCellProperties(Cell)

% Optional inputs - comment out if desired
% Determine the animal genotype and age
Cell.mouse_genotype = input('What is the mouse genotype?  ', 's');
Cell.genetic_marker = input('What is the genetic marker? ', 's');
% Cell.animal_age = input('What is mouse age in days?   ', 's');
% Cell.Vm = input('What was the resting membrane potential?    ');

Cell.cell_location = input('Where was this recording done (must be PFC for classification?) ', 's');

% if strcmp(Cell.cell_location, 'cPFC') || strcmp(Cell.cell_location, 'iPFC') || strcmp(Cell.cell_location, 'PFC')
%     Cell.layer = input('What layer was this cell? ');
%     Cell.distance_from_pia = input('What was the distance from the pia?    ');
% end


end



