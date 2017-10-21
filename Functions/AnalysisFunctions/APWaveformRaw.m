function [AP_max_points, repol_values, thresh_values, spike_width_20percent, dVdt_rising_20percent, dVdt_falling_20percent, sweeps_to_analyze] = APWaveformRaw(Cell, number_of_spikes)
% APWaveform
%   Input:  Cell to analyze, and the number of spikes that you want the
%   train to have (with 300 ms current injection)
%   This function calculates the parameters of the spike waveform that are
%   needed for subsequent analysis.
%           - Threshold Vm (dVdt>15 mV/s)
%           - Threshold timing for 1st spike
%           - AP peak timing
%           - Peak repolarization (ie. repolarization Vmin)
%           - Spike width and dV/dt @ 20% of spike height

[injection_durations, numspikes, spike_times, ms_per_point_for_spiking] = CurrentInjectionForSpiking(Cell);

% Find all sweeps that occur in first 150 seconds that had a 300 ms current
% injection, then find the number of spikes in the spike train for all sweeps that had 300
% ms current injection
injection_duration_300ms = intersect(find(Cell.sweep_time<150), find(injection_durations==300));
numspikes_300ms = numspikes(injection_duration_300ms); 

% Determine the sweep numbers of all sweeps that are going to be analyzed 
sweeps_to_analyze = injection_duration_300ms(numspikes_300ms == number_of_spikes);
num_sweeps = sum(~isnan(sweeps_to_analyze), 1); % total number of sweeps for cell

% Initialize structures for AP waveform data
properties_string = {'AP_max_points', 'repol_values', 'thresh_values', 'spike_width_20percent',...
    'dVdt_rising_20percent', 'dVdt_falling_20percent'};

for ii = 1:length(properties_string)
    evalc([properties_string{ii} ' = cell(1, num_sweeps)']);
end


if num_sweeps > 0
    
    PulseOnset = find(Cell.commands(:, sweeps_to_analyze)>0, 1, 'first')-1;
    
    for i = 1:length(sweeps_to_analyze) % Looping through each sweep (all having same # of spikes)
        j = sweeps_to_analyze(i); % j is the sweep number that you are analyzing for this iteration
        current_sweep = Cell.data(:, j);
        
        [~, PulseOffset] = PulseTiming(Cell,  max(Cell.commands(:,j))  , j);
        
        
        % Initialize all matrices for AP waveform data
        start_spike_point = nan(numspikes(j), 1);

        AP_max_points{i} = nan(numspikes(j), 1);
        AP_max_values{i} = nan(numspikes(j), 1);

        repol_values{i} = nan(numspikes(j), 1);
        repol_points{i} = nan(numspikes(j), 1);

        thresh_values{i} = nan(numspikes(j), 1);
        thresh_points{i} = nan(numspikes(j), 1);

        spike_amplitudes{i} = nan(numspikes(j), 1);
        
        spike_width_20percent{i} = nan(numspikes(j), 1);
        dVdt_rising_20percent{i} = nan(numspikes(j), 1);
        dVdt_falling_20percent{i} = nan(numspikes(j), 1);
        
        % Calculate first derivative to use for threshold
        dVdt = gradient(current_sweep)./ms_per_point_for_spiking;
        
        
        for ii = 1:numspikes(j) % looping through each spike
            
            if ii == 1
                % if analyzing first spike, set start as 10 ms before spike
                % detection threshold (which was set at -10 mV)
                start_spike_point(ii) = spike_times{j}(ii)-10/ms_per_point_for_spiking;
            else
                % Else start analysis at repolarization point of previous
                % spike
                start_spike_point(ii) = repol_points{i}(ii-1);
            end
            
            
            %% AP peak time points  
            if ii ~= numspikes(j) % if not last AP
                [AP_max_values{i}(ii), AP_max_points{i}(ii)] = max(current_sweep(start_spike_point(ii):spike_times{j}(ii+1)));
            else
                [AP_max_values{i}(ii), AP_max_points{i}(ii)] = max(current_sweep(start_spike_point(ii):(PulseOffset+10/ms_per_point_for_spiking))); % added 10 ms to catch spikes that occur slightly after pulse offset
            end
            
            AP_max_points{i}(ii) = AP_max_points{i}(ii) + start_spike_point(ii)-1; % adjust for the offset
            
            %% Repolarization calculations
            if ii ~= numspikes(j)
                [repol_values{i}(ii), repol_points{i}(ii)] = min(current_sweep(AP_max_points{i}(ii):spike_times{j}(ii+1)));
                repol_points{i}(ii) = repol_points{i}(ii) + AP_max_points{i}(ii)-1; % adjust for the offset
            end
            
            %% Threshold calculations
            end_point_for_threshold = AP_max_points{i}(ii) - 0.2/ms_per_point_for_spiking; % only go to .2 ms from peak, avoid spurious results
            thresh_points{i}(ii) = find(dVdt(start_spike_point(ii):end_point_for_threshold)>15, 1);
            thresh_points{i}(ii) = thresh_points{i}(ii) + start_spike_point(ii)-2; % adjust for the offset, and also subtract 1 extra so that its the last point <15 ms
            thresh_values{i}(ii) = current_sweep(thresh_points{i}(ii));
                      
            
            
            %% Spike width calculations 
            spike_amplitudes{i}(ii) = AP_max_values{i}(ii)-thresh_values{i}(ii); 
                     
            % Extract all AP waveform before and after AP peak
            AP_values_before_peak = current_sweep(start_spike_point(ii):AP_max_points{i}(ii));
            
            if ii ~= numspikes(j)
                AP_values_after_peak = current_sweep(AP_max_points{i}(ii):repol_points{i}(ii));
            else
                AP_values_after_peak = current_sweep(AP_max_points{i}(ii):AP_max_points{i}(ii)+10/ms_per_point_for_spiking);
            end
            
            % Find closest voltage in the trace to the voltage at 20% of AP amplitude both before and after the AP peak 
            voltage_20percent_amp = thresh_values{i}(ii) + spike_amplitudes{i}(ii)*0.2; % calculate voltage at 20% of AP amplitude
            
            tmp_mV_before = abs(AP_values_before_peak-voltage_20percent_amp);
            tmp_mV_after  = abs(AP_values_after_peak-voltage_20percent_amp);
            
            [~, tmp_before_point] = min(tmp_mV_before);
            [~, tmp_after_point] = min(tmp_mV_after);
            
            before_point_20percent = start_spike_point(ii)+tmp_before_point-1;
            after_point_20percent = AP_max_points{i}(ii)+tmp_after_point-1;
            
            spike_width_20percent{i}(ii) = (after_point_20percent-before_point_20percent)*ms_per_point_for_spiking;
            
            %% Calculate dVdt rising and falling at 20% spike amplitude
            
            dVdt_rising_20percent{i}(ii) = dVdt(before_point_20percent);
            dVdt_falling_20percent{i}(ii) = dVdt(after_point_20percent);
            
                        
        end
        
    end
end

end






