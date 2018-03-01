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

function GraphVar_DoNetwork_Callback(hObject, eventdata, handles)
if get(handles.DoNetwork,'Value')
    set(handles.ConnectivityThr_Check,'Enable','on')
    GraphVar_ConnectivityThr_Check_Callback(hObject, 1, handles)
    children = get(handles.raw_matrix_testing,'Children');
    set(children,'Enable','on');

    
    set(handles.shuffel_check,'Enable','on')
    set(handles.shuffel_n,'Enable','on')
    set(handles.text36,'Enable','on')
    set(handles.r2z_check,'Enable','on')
    set(handles.text49,'Enable','on')

 else
    set(handles.ConnectivityThr_Listbox,'Enable','off')
    
    set(handles.ConnectivityThr_Check,'Value',0);
    children = get(handles.raw_matrix_testing,'Children');
    set(children,'Enable','off');
    set(handles.shuffel_check,'Value',0);
    set(handles.r2z_check,'Value',0);

    set(handles.r2z_check,'Enable','off')
    set(handles.text49,'Enable','off')

    set(handles.ConnectivityThr_Check,'Enable','off')
    set(handles.shuffel_check,'Enable','off')
    set(handles.shuffel_n,'Enable','off')
    set(handles.text36,'Enable','off')
end