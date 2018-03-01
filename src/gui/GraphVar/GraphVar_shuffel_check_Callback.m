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

function GraphVar_shuffel_check_Callback(hObject, eventdata, handles)
if get(handles.shuffel_check,'Value')
    set(handles.raw_random,'Visible','on');
    set(handles.shuffel_n,'Visible','on') ;
    set(handles.text52,'Visible','on');
    set(handles.text54,'Visible','on') ;
    set(handles.text36,'Visible','on');
    set(handles.RandomRawIter,'Visible','on');
else
    set(handles.raw_random,'Visible','off');
    set(handles.shuffel_n,'Visible','off') ;
    set(handles.text52,'Visible','off');
    set(handles.text54,'Visible','off') ;
    set(handles.text36,'Visible','off');
    set(handles.RandomRawIter,'Visible','off');
end