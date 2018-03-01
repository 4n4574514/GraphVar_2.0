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

function GraphVar_FileName_selection_change(arg1, arg2,handles)
endN = arg2.getMark();
startN = arg2.getDot();
if(endN==0)&&(startN==0)
    return; 
end
if(startN>endN)
    startN=endN;
    endN = arg2.getDot();
end

k = length(arg1.getText()) - endN ;
set(handles.filename_start,'string' ,  num2str(startN+1));
set(handles.filename_end,'string' ,  num2str(k));