function [numspikes, sptms]=findspikes(traces,thresh,expected)

%Kenneth Burke 11/18/2014
%takes matrix of traces representing FI curve, generates stats
%
%               INPUT             
%TRACES = matrix of traces (each col is a trace)
%THRESH = optional voltage threshold for detecting a spike (def. -10)
%EXPECTED = optional expected number of spikes in each trace, yells at you 
%       and allows some user interaction to solve problem or abort (def. -1
%       == no expectation or subsequent errors)
%
%               OUTPUT
%NUMSPIKES = vector of num of spikes (useful for FI curve)
%SPTMS = cell array of spike times per input trace

if(nargin<3)
    expected = -1;
    if(nargin<2)
        thresh = -10;
    end
end

numspikes = [];
sptms = {};

steps = size(traces,2);

for i=1:steps
    sptms{i} = find(traces(2:end,i) > thresh & traces((1:end-1),i) <= thresh);
    if(~(expected==-1) && ~(length(sptms{i})==expected))
        warning('---ERROR IN FINDSPIKES---')
        fprintf(['\nExpected ' num2str(expected) ' spikes, instead detected '...
            num2str(length(sptms{i})) ' spikes...\n'])
        disp(['Plotting problematic sweep...'])
        figure();
        plot(traces(:,i));
        prompt = 'Manually insert desired indeces? y/n\n';
        str = input(prompt,'s');
        
        if(strcmp(str,'y') || strcmp(str,'yes'))
            sptms{i} = [];
            fprintf(['\n' num2str(expected) ' indeces to be inserted...'])
            for j=1:expected;
                prompt = ['\nInsert desired # ' num2str(j) ' spike index : '];
                str = input(prompt,'s');
                sptms{i} = [sptms{i}; str2num(str)];
            end
            disp(['---Manual insertion complete!---'])
        else
            error('Observed spikes ~== expected spikes... rerun without expected spikes or insert indeces manually') 
        end

    end    
    numspikes = [numspikes length(sptms{i})];
end

end