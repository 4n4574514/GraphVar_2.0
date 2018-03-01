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

function GraphVar_saveSettings(handles)
global workspacePath;
fieldName = get(handles.MatrixName,'String');
brainSheet = get(handles.edit_brainxls,'String'); 
variableSheet = get(handles.edit_varxls,'String');
filename_start_tmp = str2double(get(handles.filename_start,'String'));
if ~isnan(filename_start_tmp)
    filename_start = filename_start_tmp;
else
    filename_start = 0;
end
filename_end_tmp = str2double(get(handles.filename_end,'String'));
if ~isnan(filename_end_tmp)
    filename_end = filename_end_tmp;
else
    filename_end = 0;
end
fieldName = get(handles.MatrixName,'String');
partVar = {};%get(handles.list_covars_cor,'Value');
corrVar = {};%get(handles.list_variables_cor,'Value');


if isfield(handles,'vpFiles')
    files = handles.vpFiles;
else
    files = [];
end

files_rel = get(handles.subjects,'String');

path= fileparts(mfilename('fullpath'));
save([path 'LastOpend.mat'],'workspacePath');

save([workspacePath filesep 'Workspace.mat'],'fieldName','filename_start','filename_end','fieldName','partVar','corrVar','brainSheet','variableSheet','files','files_rel');
