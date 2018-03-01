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

function position = getPositionOnFigure( hObject,units )
%GETPOSITIONONFIGURE returns absolute position of object on a figure
%
% (since get(hObject,'Position') returns position relative to hObject's
%  parent)

hObject_pos=getRelPosition(hObject,units);
parent = get(hObject,'Parent');
parent_type = get(parent,'Type');

if isequal(parent_type,'figure')
    position = hObject_pos;
    return;
    
else
    parent_pos = getPositionOnFigure( parent,units );
    position = relativePos2absolutePos(hObject_pos,parent_pos,units);
end
