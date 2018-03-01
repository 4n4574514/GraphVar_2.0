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

function [BrainMap, BrainCriteria] = GraphVar_loadBrainRegions(hObject, eventdata, handles,Brain_Atlas)
[BrainMap] = importSpreadsheet(Brain_Atlas);
BrainCriteria = cell2mat(BrainMap(:,1));
BrainMap = BrainMap(:,3);
set(handles.list_brainareas,'String',BrainMap,'Value',1);
selectedBrain = find(BrainCriteria == 1);
set(handles.list_brainareas,'value',selectedBrain);
set(handles.list_brainareas,'UserData',selectedBrain);
set(handles.list_brainareas, 'ListboxTop', 1);
 GraphVar_settingsChanged(handles)