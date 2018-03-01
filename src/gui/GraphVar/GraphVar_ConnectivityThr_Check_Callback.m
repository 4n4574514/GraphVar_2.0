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

function GraphVar_ConnectivityThr_Check_Callback(hObject, eventdata, handles)
if get(handles.ConnectivityThr_Check,'Value')
    set(handles.ConnectivityThr_Listbox,'Enable','on')
%     if isempty(eventdata)
        [selection,ok] = listdlg('PromptString','Select the field where p-Values are stored :','ListString',handles.fNames,'SelectionMode','single');
        if(ok)
            handles.sigField = handles.fNames(selection);
            guidata(hObject, handles);

        else
            set(handles.ConnectivityThr_Check,'Value',0)
        end
%     end
else
    set(handles.ConnectivityThr_Listbox,'Enable','off')
end
if isempty(eventdata)
    GraphVar_settingsChanged(handles)
end