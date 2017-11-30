%% Import a cell from Igor and select the sweeps for calculating sag/rebound and input resistance


%                       ASSUMPTIONS
% Timing for sag/rebound and Rin pulses are consistent across selected
% sweeps.
% Igor-to-Matlab has to be exported to "filepath"


function [Cell] = Import_and_Classify(Cell_to_load, opts, varargin)

options = struct('select_sweeps', 0, 'filepath', 'cell_folder/ibt_files/');

switch nargin
    case 2
    case 3
        options = fOptions(options, opts);
    otherwise
        options = fOptions(options, struct(opts, varargin{:}));
end

currentfolder = cd;

cd(options.filepath)

if ischar(Cell_to_load)
    [Cell] = ImportCell(Cell_to_load, options.select_sweeps);
else
    Cell = Cell_to_load;
end

cd(currentfolder)

% Run all analyses on the particular cell

if exist('Cell', 'var')
    
    if isfield(Cell, 'cell_location')
        if strcmp(Cell.cell_location, 'cPFC') || strcmp(Cell.cell_location, 'iPFC') || strcmp(Cell.cell_location, 'PFC')
            [Cell] = Analyze_Cell(Cell);
            [type] = Classify_Cell(Cell);
            if strcmp(type, 'Type 1')
                Cell.type = 1;
            elseif strcmp(type, 'Type 2')
                Cell.type = 2;
            elseif strcmp(type, 'Type 3')
                Cell.type = 3;
            elseif strcmp(type, 'Unidentified')
                Cell.type = 4;
            end
        else
            Cell.type = nan;
            
        end
    else
        warning('Data not successfully inputed')
    end
    
else
    warning('Cell did not load')
    Cell = struct();
end

end


function dfar = fOptions(dfar,opts)
input_fnm = fieldnames(opts);
idx = ~cellfun(@(f)any(strcmpi(f,fieldnames(dfar))),input_fnm);
if any(idx)
    error('Unsupported field name/s:%s\b',sprintf(' <%s>,',input_fnm{idx}))
end

for i = 1:length(input_fnm)
    dfar.(input_fnm{i}) = opts.(input_fnm{i});
end

end