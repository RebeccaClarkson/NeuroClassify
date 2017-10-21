function [Cell] = ConvertDAQ(Cell)
% This function corrects the import from igor for when there are multiple
% sampling frequencies. 

%                   INPUT/OUTPUT
% Input:  A cell that has been imported from Igor, which has multiple
% sampling frequencies
% Output: Corrected Cell.data and Cell.comm, which are matrices in which
% each column is a sweep. Number of rows = number of points for maximum
% number of samples

%                   ASSUMPTIONS
% This assumes that that ONLY the sampling frequency changes between
% sweeps.
%

% Determine the total number of sweeps as well as the maximum Fs (DAQ) -
% these determine the size of the data and command matrices. 
number_of_sweeps = length(Cell.sweep_time);
max_DAQ = max(Cell.DAQ);
Cell.data_tmp = NaN(max_DAQ, number_of_sweeps);
Cell.comm_tmp = NaN(max_DAQ, number_of_sweeps);


startindex = 1;
for i = 1:number_of_sweeps
    Cell.data_tmp(1:Cell.DAQ(i), i) = Cell.data(startindex: (startindex + Cell.DAQ(i)-1));
    startindex = startindex + Cell.DAQ(i);
end

startindex = 1;
for i = 1:number_of_sweeps
    Cell.comm_tmp(1:Cell.DAQ(i), i) = Cell.commands(startindex: (startindex + Cell.DAQ(i)-1));
    startindex = startindex + Cell.DAQ(i);
end

Cell.data = Cell.data_tmp;
Cell.commands = Cell.comm_tmp;

% Remove the temporary data and command fields

Cell = rmfield(Cell, 'data_tmp');
Cell = rmfield(Cell, 'comm_tmp');

end


