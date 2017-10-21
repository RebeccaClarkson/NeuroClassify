function [mean_values] = APWaveformSummaryStats(Cell, number_of_spikes)
%APWaveformSummaryStats
%

[AP_max_points, repol_values, thresh_values, spike_width_20percent, dVdt_rising_20percent,...
    dVdt_falling_20percent, sweeps_to_analyze] = APWaveformRaw(Cell, number_of_spikes);

number_of_sweeps =  sum(~isnan(sweeps_to_analyze));


% Initialize a nan matrix for storing spike data that is mxn where m = number_of_sweeps and
% n=number_of_spikes 
if number_of_sweeps > 0
    preallocated_all_spikes = nan(number_of_sweeps, number_of_spikes);
else
    preallocated_all_spikes = nan(1, 10);
end

% Initialize the structures for storing all spike waveform and spike train analysis data 
dVdt_allsweeps_rising = struct('percent20', preallocated_all_spikes);
dVdt_allsweeps_falling = struct('percent20', preallocated_all_spikes);

spike_width_allsweeps = struct('percent20', preallocated_all_spikes);
spike_width_ratios_allsweeps = struct('percent20', preallocated_all_spikes);

adaptation_ratio_all_sweeps = struct('Adaptation_Ratio_1', preallocated_all_spikes);

mV_change_allsweeps = struct('threshold_vs_threshold', preallocated_all_spikes, ...
    'AHP_vs_AHP', preallocated_all_spikes);

if number_of_sweeps > 0
    for i = 1:number_of_sweeps
        for ii = 1:number_of_spikes
            
            dVdt_allsweeps_rising.percent20(i, ii) = dVdt_rising_20percent{i}(ii);
            dVdt_allsweeps_falling.percent20(i, ii) = dVdt_falling_20percent{i}(ii);
            
            spike_width_allsweeps.percent20(i, ii) = spike_width_20percent{i}(ii);
            spike_width_ratios_allsweeps.percent20(i, ii) = spike_width_20percent{i}(ii)/spike_width_20percent{i}(1);
            
            mV_change_allsweeps.threshold_vs_threshold(i, ii) = thresh_values{i}(ii) - thresh_values{i}(1);
            mV_change_allsweeps.AHP_vs_threshold(i, ii) = repol_values{i}(ii)-thresh_values{i}(1);       
                        
            if ii<number_of_spikes
                adaptation_ratio_all_sweeps.Adaptation_Ratio_1(i, ii) = (AP_max_points{i}(ii+1)-AP_max_points{i}(ii))/(AP_max_points{i}(2)-AP_max_points{i}(1));
            end
            
        end
    end
end

all_values_structure_names = {'dVdt_allsweeps_rising', 'dVdt_allsweeps_falling', 'spike_width_allsweeps', 'spike_width_ratios_allsweeps', 'adaptation_ratio_all_sweeps', 'mV_change_allsweeps'};
mean_values_structure_names = {'dVdt_rising', 'dVdt_falling', 'spike_width', 'spike_width_ratios', 'adaptation_ratio', 'mV_change'};

for i = 1:length(all_values_structure_names)
    
    all_values = eval(all_values_structure_names{i});
    fields_to_evaluate = fieldnames(all_values);
    
    for ii = 1:length(fields_to_evaluate)
        if number_of_sweeps > 1
            mean_values.(mean_values_structure_names{i}).(fields_to_evaluate{ii}) ...
                = mean(all_values.(fields_to_evaluate{ii}));
        else
            mean_values.(mean_values_structure_names{i}).(fields_to_evaluate{ii}) ...
                = all_values.(fields_to_evaluate{ii});
        end      
    end
    
end

mean_values.analyzed_sweeps = sweeps_to_analyze;
mean_values.number_of_spikes = number_of_spikes;

end


