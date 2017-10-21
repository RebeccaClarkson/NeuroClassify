function [SagAnalysis] = CalculateSag(Cell)
% CalculateSag
%   Assumption: Injection of -400 pA occurred at the same timing

SagSweepsIdx  = Cell.Properties.SagReb.AveragedSweeps;

% Establish x values (time) for sag sweeps

points_per_sec = Cell.kHz(SagSweepsIdx(1)) * 1000;
sec_per_point = 1/points_per_sec;
ms_per_point = sec_per_point*1000;
sweep_time = Cell.time(:,SagSweepsIdx(1));

% determine start and end points for analysis of sag: Sag_Start_point is the
% point at beginning of -400 current injection, Sag_End_point is 120 ms later.
[Sag_Start_point, ~] = PulseTiming(Cell, -400, SagSweepsIdx);
Sag_End_point = Sag_Start_point + 120/ms_per_point;


% Find time point of peak sag
[~, PeakSagLocation_point] = min(Cell.Properties.SagReb.Sweep(Sag_Start_point:Sag_End_point));
PeakSagLocation_point = PeakSagLocation_point+Sag_Start_point;
PeakSagLocation_ms = (PeakSagLocation_point-Sag_Start_point) * ms_per_point;

%% Fit the sag with an exponential

start_point_fit = PeakSagLocation_point;
end_point_fit = Sag_End_point;

if start_point_fit < end_point_fit
    
    subset.voltage = Cell.Properties.SagReb.Sweep(start_point_fit:end_point_fit);
    subset.time = sweep_time(start_point_fit:end_point_fit);
    
    
    % Offset subset.time so that xData starts at 0
    xData = subset.time-sweep_time(start_point_fit);
    
    % Offset yData so that yData either starts or ends at 0 mV.
    yData1 = subset.voltage - subset.voltage(end);
    yData2 = subset.voltage - subset.voltage(1);
    
    f = fittype('exp1');
    [fitresult1, gof1] = fit(xData, yData1, f);
    [fitresult2, gof2] = fit(xData, yData2, f);
    
    % Determine which exponential fit has the highest rsquared value.
    if gof1.rsquare >= gof2.rsquare
        coeffvals1 = coeffvalues(fitresult1);
        amplitude_fit1 = coeffvals1(1);
        amplitude_fit = amplitude_fit1;
    elseif gof1.rsquare < gof2.rsquare
        coeffvals2 = coeffvalues(fitresult2);
        amplitude_fit2 = coeffvals2(1);
        amplitude_fit = amplitude_fit2;
    end
    
else
    
    amplitude_fit = nan;
    
end

SagAnalysis.sag_amplitude_fit = amplitude_fit;
SagAnalysis.PeakSagLocation_ms = PeakSagLocation_ms;
end




