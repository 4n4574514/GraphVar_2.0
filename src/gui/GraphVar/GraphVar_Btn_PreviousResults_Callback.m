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
%% OPEN PREVIOUS RESULTS
function GraphVar_Btn_PreviousResults_Callback(hObject, eventdata, handles)
global result_path;
dirs = dir([result_path filesep 'Saved']);
cmenu = uicontextmenu;
uimenu(cmenu, 'label','Last Results','Callback',{@GraphVar_loadSession,'CorrResults'});

for i = 3:length(dirs)
    if(dirs(i).isdir)
        load([result_path filesep 'Saved' filesep dirs(i).name filesep 'info.mat']);
        uimenu(cmenu, 'label',info.name{:},'Callback',{@GraphVar_loadSession,['Saved' filesep dirs(i).name]});
    end
end
set(hObject,'uicontextmenu',cmenu);

hObject_pos = getPositionOnFigure(hObject,'pixels');
pos = hObject_pos(1:2);
set(cmenu,'Position',pos);
set(cmenu,'Visible','on');
