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

% GENERATE SUBJECT DATA FROM TIMECOURSES
function GraphVar_generate_btn_Callback(hObject, eventdata, handles)
global workspacePath;
global running;


[fileName, pathName, filterIndex] = uigetfile({'*.mat'}, 'Select file(s)', 'MultiSelect', 'on');
if iscell(fileName)
    data = load([pathName  fileName{1}]);
    fNames = fieldnames(data);
    [selection,ok] = listdlg('PromptString','Select the field where the timecourses are stored :','ListString',fNames,'SelectionMode','single');
    if(ok)
        fieldName = fNames(selection);
    else
        return;
    end
    wait = waitbar(0,'Step 2: Correlating Vars','WindowStyle', 'modal' ,'CreateCancelBtn',@stopGenerate);
    running = 1;
            
    if get(handles.timeseriesType_Randomize,'Value')
        type = 1;
    elseif get(handles.timeseriesType_Shuffle,'Value')
        type = 2;
    elseif get(handles.timeseriesType_FFT,'Value')
        type = 3;
    end
    
    files = generateFromTimecourses(pathName,fileName,get(handles.partial_check_files,'Value'), get(handles.spearman_check_files,'Value'),...
        get(handles.bend_check_files,'Value'),get(handles.mutual_check_files,'Value'),get(handles.SICEdense_check_files,'Value'),get(handles.covariance,'Value'), ...
        get(handles.list_brainareas,'Value'),fieldName,get(handles.Rand_timeseries,'Value'), ...
        type,get(handles.Rand_timeseries,'Value') * str2double(get(handles.timeseriesType_N,'String')),...
        str2double(get(handles.SICE_density,'String')),get(handles.SlidingWindows,'Value'),str2double(get(handles.WindowSize,'String')),str2double(get(handles.WindowStep,'String')),wait);
    if isempty(files)
        return;
    end
    

    idx = strfind(files{1},filesep);
    filenameBox = files{1}(idx(end)+1:end);
    handles.vpFiles = files;
    handles.vpPath = pathName;
       
    set(handles.subjects,'String',files)
    set(handles.MatrixName,'String','CorrMatrix')
    set(handles.FileName_Selector,'String',filenameBox)
    
    content = load(files{1});
    handles.fNames = fieldnames(content);
    guidata(hObject, handles);
    GraphVar_settingsChanged(handles);
    delete(wait);
    
    if sum(strcmp(handles.fNames,'is_dyn')) && content.is_dyn == 1 
        set(handles.DynamicGraphVar,'Visible','On');
        set(handles.DynamicGraphVar2,'Visible','On');
    else
        set(handles.DynamicGraphVar,'Visible','Off');
        set(handles.DynamicGraphVar2,'Visible','Off');
    end
    
    set(handles.CreateCorrMatrix_Btn, 'Value',0);
    GraphVar_CreateCorrMatrix_Btn_Callback(handles.CreateCorrMatrix_Btn, 0, handles);

    
elseif fileName ~= 0
    nbfiles = 1;
else
    nbfiles = 0;
end



function stopGenerate(arg1,arg2)
global running;
running = 0;
