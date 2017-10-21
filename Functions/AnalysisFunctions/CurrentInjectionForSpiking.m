function [injection_duration, all_numspikes, spike_times, ms_per_point_for_spiking] = CurrentInjectionForSpiking(Cell)
%CurrentInjectionforSpiking 
%  

num_sweeps = size(Cell.data, 2); % total number of sweeps for cell

[all_numspikes, spike_times]=findspikes(Cell.data); % number of spikes in each sweep plus spike times (times just based on arbitrary threshold)

first_sweep = find(~cellfun('isempty', spike_times),1);
points_per_sec = Cell.kHz(first_sweep) * 1000;
sec_per_point = 1/points_per_sec;
% establish ms_per_point based on sampling frequency of first sweep with spikes
ms_per_point_for_spiking = sec_per_point*1000; 

injection_duration = nan(1, num_sweeps); % Array for current injection pulse duration (ms) per sweep
pos_current_injection = max(Cell.commands); % Find amount of positive current injected (assumes only one positive current injection)

for i = 1:num_sweeps
   if pos_current_injection(i) ~= 0
       injection_duration(i) = sum(Cell.commands(:,i) == pos_current_injection(i)) * ms_per_point_for_spiking;
   else
       injection_duration(i) = 0;
   end
end

end

