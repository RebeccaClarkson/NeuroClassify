 function [PulseOnset PulseOffset] = PulseTiming(Cell, StepSize, SweepIdx)
        PulseOnset = find(Cell.commands(:, SweepIdx(1))==StepSize, 1, 'first')-1;
        PulseOffset = find(Cell.commands(:, SweepIdx(1))==StepSize, 1, 'last')-1;
 end