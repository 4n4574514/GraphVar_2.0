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


function res = multidimfunc(func,vals,dim)
global values;
global returnValue;
returnValue = [];
values = vals;
vSize = size(vals);
vSize(dim) = [];
ndim(ndims(vals)-1,[],vSize,dim,func);
res = returnValue;
end

function data = ndim(actDim,actPos,sizeVec,intrestDim,functionName)
global values;
global returnValue;

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
         eval([ 'returnValue(' dimStr2 ') = ' functionName '(valueTemp);']);
                  
        return; 
    end

    for i = 1:sizeVec(actDim) 
        ndim(actDim-1,[actPos i],sizeVec,intrestDim,functionName);
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
        