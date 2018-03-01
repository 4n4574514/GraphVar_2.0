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

%% SELECT SUBJECT FILES
function GraphVar_selectVp_Callback(hObject, eventdata, handles)
global workspacePath;
[fileName, pathName, filterIndex] = uigetfile({'*.mat'}, 'Select file(s)', 'MultiSelect', 'on');
if iscell(fileName)
    nbfiles = length(fileName);
    handles.vpPath = pathName;
    
        for i=1:nbfiles
            files{i} =  [pathName fileName{i}];
        end
        
        
    if strcmp([workspacePath filesep 'data' filesep 'CorrMatrix' filesep],pathName)
        for i=1:nbfiles
            files_box =  fileName;
        end
    else
        files_box = files;
    end


    handles.vpFiles = files;
    set(handles.subjects,'String',files_box);
    content = load([pathName fileName{1}]);
    fNames = fieldnames(content);
    [selection,ok] = listdlg('PromptString','Select the field where r-Values are stored :','ListString',fNames,'SelectionMode','single');
    set(handles.MatrixName,'String',fNames(selection));
    handles.fNames = fNames;
    
    set(handles.FileName_Selector,'String',fileName{1});

    
    if sum(strcmp(handles.fNames,'is_dyn')) && content.is_dyn == 1 
        set(handles.DynamicGraphVar,'Visible','On');
        set(handles.DynamicGraphVar2,'Visible','On');
    else
        set(handles.DynamicGraphVar,'Visible','Off');
        set(handles.DynamicGraphVar2,'Visible','Off');
    end
    
elseif fileName ~= 0
    nbfiles = 1;
else
    nbfiles = 0;
end
guidata(hObject, handles);
GraphVar_settingsChanged(handles)