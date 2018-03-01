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

function GraphVar_RandomNetwork_check_Callback(hObject, eventdata, handles)
if get(handles.RandomNetwork_check,'Value');   
    set(handles.RandomNetwork_n,'Visible','on')
    set(handles.RandomNetwork_func,'Visible','on')
    set(handles.binary_check,'Visible','on')
    set(handles.weighted_check,'Visible','on')
    set(handles.RandomNetwork_iter,'Visible','on')
    set(handles.text30,'Visible','on')
    set(handles.text31,'Visible','on')
    
    if ~(get(handles.binary_check,'Value') || get(handles.weighted_check,'Value'))
        set(handles.binary_check,'Value',1);
    end
    
else
    set(handles.RandomNetwork_n,'Visible','off')
    set(handles.RandomNetwork_func,'Visible','off')
    set(handles.binary_check,'Visible','off')
    set(handles.weighted_check,'Visible','off')
    set(handles.RandomNetwork_iter,'Visible','off')
    set(handles.text30,'Visible','off')
    set(handles.text31,'Visible','off')
end
