function [DS] = load_ibw(fnstr)

%KJB 11/18/2014, RLClarkson added DAQ and kHz functionality
%Creates data structure that stores all data for many cells
%
%                   INPUTS
%FNSTR = filename string used to find data. wildcards are helpful (e.g.
%       'burke*' to find all filenames starting with "burke"
%
%                   OUTPUTS
%DS = 1XN data structure containing fields for:
%        -name
%        -data
%        -commands
%        -temp (temperature)
%        -sweep_time
%        -DAQ (number of data acquisition points per sweep)
%        -kHz (sampling frequency)
%   ... where N is the number of cells found according to fnstr
%
%                  REQUIREMENTS
% Data format:  Data exported from igor can only have 6 different extensions:
% '_rawsweeps.ibw', '_commands.ibw', '_temperature.ibw', 'sweeptimes.ibw',
% '_DAQ.ibw', '_kHz.ibw'

% Functions in directory:
%        IBW_read
%        ConvertDAQ




DS = struct();
if(nargin<1 || strcmp(fnstr,''))
    fnstr = '*.ibw';
end

% pull out names
FNS = dir(fnstr);
name_arr = {FNS.name};
for i=1:length(name_arr);
    name_arr{i} = name_arr{i}(1:regexp(FNS(i).name,'_')-1);
end
names = intersect(name_arr, name_arr);

% read/load data into MATLAB object using IBWread

% First initialize filetypes and datatypes to be the length of the exported
% data types

number_exported_files = length(FNS);
filetypes = cell(1, number_exported_files);
ds_datatypes = cell(1, number_exported_files);

% Then extract out all the file names 



filetypes = {'_DAQ.ibw','_commands.ibw','_kHz.ibw',	'_rawsweeps.ibw','_sweeptimes.ibw',	'_temperature.ibw'};

datatypes_key = containers.Map;
datatypes_key('_rawsweeps.ibw') = 'data';
datatypes_key('_commands.ibw') = 'commands';
datatypes_key('_temperature.ibw') = 'temp';
datatypes_key('_sweeptimes.ibw') = 'sweep_time';
datatypes_key('_DAQ.ibw') = 'DAQ';
datatypes_key('_kHz.ibw') = 'kHz';

for i = 1:number_exported_files
   ds_datatypes{i} = datatypes_key(filetypes{i});
end

for i=1:length(names)                              % for each cell
    DS(i).name = names{i};                         % load name
    for j=1:length(filetypes)                      % load data
       temp = IBWread([names{i} filetypes{j}]);
       DS(i).(ds_datatypes{j}) = temp.y;
    end
end

% If all sampling frequency are not the same, the import function will not
% work properly, and the data and command fields will be one long vector
% instead of a matrix. To fix this, I have written code to export the DAQ
% values for each sweep. 

% if size(DS.data == 1,2) & isfield(DS, 'DAQ')
%     DS = ConvertDAQ(DS);
%     % Determine how sampling frequencies
%     DS.no_of_samples = intersect(DS.DAQ, DS.DAQ);
% end


end