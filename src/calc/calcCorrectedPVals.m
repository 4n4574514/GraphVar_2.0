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

function res = calcCorrectedPVals(input,doZtransform,isCorr)
global data_container;
isScal = 0;
if iscell(input) 
    if isscalar(input{1})
        isScal = 1;
    end
elseif isscalar(input(1))
	isScal = 1;
end
    
    
if isScal
    if iscell(input)
        input = cell2mat(input);
    end
    
%     if doZtransform
%     input=0.5*log((1+input)./(1-input));
%     end

    [~,IX] = sort(input,'descend');
    if isCorr
        eSize = length(IX)/2;
        if eSize == floor(eSize)
            res = min([find(IX(1:eSize) ==1)/eSize,(1 + length(IX(ceil(eSize)+1:end)) - find(IX(eSize+1:end) ==1))/eSize]);
        else
            if(IX(ceil(eSize)) == 1)
                res = 1;
            else
                res = min([find(IX(1:floor(eSize)) ==1)/eSize,(1 + length(IX(ceil(eSize)+1:end)) - find(IX(ceil(eSize)+1:end)==1))/eSize]);
            end
        end
        
%         res = res * 2; res(res > 1) = 1;
    else
        res = find(IX ==1)/length(IX);
    end
else
    data_container = input;
    clear input;
    res  = nDimPVals(size(data_container{1}),doZtransform,isCorr);
end
clearvars -global data_container;

end

function res = nDimPVals(dim,doZtransform,isCorr,varargin)
global data_container;

if(nargin > 3)
    pos = varargin{1};
else
    pos = [];
end

if isempty(dim)
    
    if (length(unique(pos)) == 1)
        res = 1; 
        return;
    end
    
    
    dimStr = '';
    for i = 1:length(pos)
        dimStr = [dimStr num2str(pos(i)) ','];
    end
    dimStr(end) = [];
    
    data = eval(['cellfun(@(v) v(' dimStr '),data_container)']);
    
    if sum(isnan(data)) > 1
        if isCorr
            data(isnan(data)) = [];
        else
            data(isnan(data)) = max(data) +1;
        end
    end

%     if doZtransform
%     data=0.5*log((1+data)./(1-data));
%     end

    
    [~,IX] = sort(data,'descend');
    
    if isCorr
        eSize = length(IX)/2;
        if eSize == floor(eSize)
            res = min([find(IX(1:eSize) ==1)/eSize,(1 + length(IX(ceil(eSize)+1:end)) - find(IX(eSize+1:end) ==1))/eSize]);
        else
            if(IX(ceil(eSize)) == 1)
                res = 1;
            else
                res = min([find(IX(1:floor(eSize)) ==1)/eSize,(1 + length(IX(ceil(eSize)+1:end)) - find(IX(ceil(eSize)+1:end)==1))/eSize]);
            end
        end
%         res = res * 2; res(res > 1) = 1;
    else
        res = find(IX ==1)/length(IX);
    end
    if isempty(res) 
        res = NaN;
    end
    
else
    dimStr = '';
    for i = 1:length(dim)-1
        dimStr = [dimStr ',:'];
    end
    
    for i = 1:dim(1)
        eval(['res(i' dimStr ')= nDimPVals(dim(2:end),doZtransform,isCorr,[pos i]);']);
    end
end
end
