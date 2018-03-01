%  This file is part of GraphVar.
%
%  Copyright (C) 2014
%
%  GraphVar is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  GraphVar is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with GraphVar.  If not, see <http://www.gnu.org/licenses/>.


function res = multidimfunc_multislice(func,vals,dim,thr,InterimResult,isRand)
global values;
global returnValue;
global workspacePath;
returnValue = [];
values = [];
size(vals)
result_path = [workspacePath filesep 'results' filesep InterimResult];
curr_thr = thr*10;


if nargin > 5 && isRand == 1
    multislice_community_assignment = load([result_path filesep 'GraphVars' filesep 'multislice_community_assignment_slicesXnodes_'  num2str(curr_thr) '_2-rand.mat' ]);
    multislice_community_assignment = multislice_community_assignment.multislice_community_assignment_random;
else
    multislice_community_assignment = load([result_path filesep 'GraphVars' filesep 'multislice_community_assignment_slicesXnodes_'  num2str(curr_thr) '_2.mat' ]);
    multislice_community_assignment = multislice_community_assignment.multislice_community_assignment;
end

if(size(multislice_community_assignment,1) == 1)
    res = zeros([1 size(vals, 2) 1 size(vals, 4)]);
else
    res = zeros([1 size(vals, 2) size(multislice_community_assignment, 1) size(multislice_community_assignment, 2)]);
end

res = zeros([1 size(vals, 2) 1 size(vals, 4)]);

for i = 1:size(multislice_community_assignment, 1)
    for ii = 1:size(multislice_community_assignment, 2)
        
        S = multislice_community_assignment{i,ii};
        numCommunities = length(unique(S));
        
        if(size(multislice_community_assignment,1) == 1)
            values = vals(:, :, :, i);
        else
            values = vals(:, :, i, ii, :);
        end
        
        vSize = size(values);
        ndim(ndims(values)-1,[],vSize,dim,func,thr,InterimResult,numCommunities);
        res(:, :, i, ii) = returnValue;
        returnValue = [];
    end
end
end

function data = ndim(actDim,actPos,sizeVec,intrestDim,functionName,thr,InterimResult,numCommunities)
global values;
global returnValue;
global workspacePath;
load(fullfile(workspacePath,'Workspace.mat'));

if(actDim == 0)
    actPos = fliplr(actPos);
    actPos = [actPos(1:intrestDim-1),1,actPos(intrestDim:end)];
    dimStr = '';
    dimStr2 = '';
    
    for i = 1:length(actPos)
        if(i == intrestDim)
            dimStr = [dimStr ':,'];
        else
            dimStr = [dimStr num2str(actPos(i)) ','];
        end
        
        dimStr2 = [dimStr2 num2str(actPos(i)) ','];
        
    end
    dimStr(end) = [];
    dimStr2(end) = [];
    valueTemp = squeeze(eval(['values (' dimStr ')']));
    if(ndims(valueTemp) == 2) && (size(valueTemp,2) == 1)
        valueTemp = rot90(valueTemp);
    end
    eval([ 'returnValue(' dimStr2 ') = ' functionName '(valueTemp,numCommunities);']);
    
    return;
end


for i = 1:sizeVec(actDim)
    ndim(actDim-1,[actPos i],sizeVec,intrestDim,functionName,thr,InterimResult,numCommunities);
end

end



% for i = 1:dim4
%     for ii = 1: dim3
%         for iii = 1: dim1
%             FUNCTION(VALUE(iii,:,ii,i));
%         end
%     end
% end
%
