function [ReboundAnalysis] = CalculateRebound(Cell)
%CalculateRebound

SagSweepsIdx = Cell.Properties.SagReb.AveragedSweeps;

% Establish x values (time) for -400 pA sweeps

points_per_sec = Cell.kHz(SagSweepsIdx(1)) * 1000;
ms_per_point = 1/points_per_sec * 1000;
sweep_time = Cell.time(:,SagSweepsIdx(1));


% Determine start and end points for -400 pA current injection
[~, Sag_End_point] = PulseTiming(Cell, -400, SagSweepsIdx); % Determine sag onset and offset points

% Determine start and end points for analysis of rebound
subset.reb_voltage = Cell.Properties.SagReb.Sweep(Sag_End_point:(Sag_End_point+100/ms_per_point));
subset.reb_time = sweep_time(Sag_End_point:(Sag_End_point+100/ms_per_point));

% Calculate timing of rebound (to determine if Type 2)
[maximum_mV, ReboundLocation_point] = max(subset.reb_voltage);
ReboundLocation_ms = (ReboundLocation_point)*ms_per_point; 

% Calculate time to get from 20% to 80% of voltage change from steady state to maximum repolarization

steady_state = mean(Cell.Properties.SagReb.Sweep(Sag_End_point-Cell.Fs*.01:Sag_End_point));
amplitude_change = maximum_mV - steady_state;
Increase20percent = steady_state + amplitude_change * .20;
Increase80percent = steady_state + amplitude_change * .80;

tmp20 = abs(subset.reb_voltage - Increase20percent);
tmp80 = abs(subset.reb_voltage - Increase80percent);
[~, point_20percent] = min(tmp20);
[~, point_80percent] = min(tmp80);

delta_t = (subset.reb_time(point_80percent) - subset.reb_time(point_20percent))*1000;


% Save the output
ReboundAnalysis.reb_delta_t = delta_t;
ReboundAnalysis.ReboundLocation_ms = ReboundLocation_ms; 

end





