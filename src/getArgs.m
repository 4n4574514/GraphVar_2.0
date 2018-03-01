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

function [varargout] = getArgs(args,varargin)
% Input: (1)   varargin of the function 
%        (2-n) wanted 'Argument Names' of Arguments or {'Name','Default Value'}
% Output: argument Values in the order of Argument Names in Input
for i = 1:length(varargin) 
    if ischar(varargin{i}) 
        toTest = varargin{i};
        defaultVal= [];
    else
        toTest = varargin{i}{1};
        defaultVal = varargin{i}{2};
    end
    isSet = 0;
    for j = 1:length(args)
        if ischar(args{j}) && strcmp(args{j},toTest)
                     varargout{i} = args{j+1};
                     isSet = 1;
                     break;
        end
    end
    
    if ~isSet && ~isempty(defaultVal)
        varargout{i} = defaultVal;
    end
end