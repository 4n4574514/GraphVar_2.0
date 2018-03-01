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

function [thresh,fun,var,brain] = Results_Filters(hObject,handles)
set(gcf,'windowbuttonmotionfcn','');

tmp = get(handles.L_Var,'String');
VarFilt = tmp(get(handles.L_Var,'value'));
tmp = get(handles.L_Graph,'String');
VarGraph = tmp(get(handles.L_Graph,'value'));
thresh = get(handles.L_thresh,'value');

if ~strcmp(VarFilt,'All')
    [~,var] = ismember(VarFilt,handles.vars);
else
    var = 1:length(handles.vars);
end

if ~strcmp(VarGraph,'All')
    [~,fun] = ismember(VarGraph,handles.functionList);
else
    fun = 1:length(handles.functionList);
end

brain  = get(handles.L_brain,'value');