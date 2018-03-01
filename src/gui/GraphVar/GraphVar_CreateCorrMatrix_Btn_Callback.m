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

function GraphVar_CreateCorrMatrix_Btn_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.GenerateCorrMatrix,'Visible','On');
    uistack(handles.GenerateCorrMatrix, 'top');
else
    set(handles.GenerateCorrMatrix,'Visible','Off');
end
