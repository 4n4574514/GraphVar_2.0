%  This file is part of GraphVar.
%
%  Copyright (C) 2014
%
%  GraphVar is free software: you can redistribute it and/or modify %  it under the terms of the GNU General Public License as published by %  the Free Software Foundation, either version 3 of the License, or %  (at your option) any later version.
%
%  GraphVar is distributed in the hope that it will be useful, %  but WITHOUT ANY WARRANTY; without even the implied warranty of %  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the %  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License %  along with GraphVar.  If not, see <http://www.gnu.org/licenses/>.

function GraphVar_enable_disable(handles,disable)

s = fieldnames(handles);
for ii=2:length(s)
if isscalar(handles.(s{ii})) && ishandle(handles.(s{ii})) && isprop(handles.(s{ii}),'Enable')
set(handles.(s{ii}),'Enable',disable);
end

end

if strcmp(disable,'Off')
     set(handles.Unlock_btn,'Visible','On');
     set(handles.Unlock_btn,'Enable','On');
else
     set(handles.Unlock_btn,'Visible','Off');
end



[~, hasP] = isParallel; if hasP
 set(handles.editParallelWorkersNumber,'Enable', 'on'); else
 set(handles.editParallelWorkersNumber,'Enable', 'off'); end

drawnow();
