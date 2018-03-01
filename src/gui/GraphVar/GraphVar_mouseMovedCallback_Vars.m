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

%************************************************************************%
%% MOUSE OVER IN GRAPH VARS
function GraphVar_mouseMovedCallback_Vars(jListbox, jEventData, hListbox,JBox,handles)
% Get the currently-hovered list-item
mousePos = java.awt.Point(jEventData.getX, jEventData.getY);
hoverIndex = JBox.locationToIndex(mousePos) + 1;
listValues = get(hListbox,'string');
hoverValue = listValues{hoverIndex};
% Modify the tooltip based on the hovered item
msgStr = sprintf('<html>%s</html>', handles.functionDescription{hoverIndex});
set(hListbox, 'Tooltip',msgStr);
% mouseMovedCallback
