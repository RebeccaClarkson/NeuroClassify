function [Cell] = Analyze_Cell(Cell)


Cell.Fs = intersect(Cell.kHz, Cell.kHz)*1000;

% Sag and Rebound Properties

[Cell.Properties.SagReb.Sweep, Cell.Properties.SagReb.AveragedSweeps] = SelectSagReboundSweeps();
    function [SagRebSweep, SagReb_Sweeps_Idx] = SelectSagReboundSweeps()
        % Find all -400 pA hyperpolarizing pulses within the first 5 minutes
        SagReb_Sweeps_Idx = intersect(find(Cell.sweep_time<300), find(any(Cell.commands==-400)));
        SagReb_Sweeps = Cell.data(:, SagReb_Sweeps_Idx);
        
        % Calculate the average sag and rebound sweep
        SagRebSweep = mean(SagReb_Sweeps, 2);
    end


[Cell.Properties.SagReb.Sag] = CalculateSag(Cell);

[Cell.Properties.SagReb.Rebound] = CalculateRebound(Cell);


% AP Waveform Properties 
% 
Cell.Properties.APWaveformValues_3spikes = APWaveformSummaryStats(Cell, 3);
Cell.Properties.APWaveformValues_4spikes = APWaveformSummaryStats(Cell, 4);
Cell.Properties.APWaveformValues_5spikes = APWaveformSummaryStats(Cell, 5);
Cell.Properties.APWaveformValues_6spikes = APWaveformSummaryStats(Cell, 6);
Cell.Properties.APWaveformValues_7spikes = APWaveformSummaryStats(Cell, 7);
Cell.Properties.APWaveformValues_8spikes = APWaveformSummaryStats(Cell, 8);


[type] = Classify_Cell(Cell)

end
