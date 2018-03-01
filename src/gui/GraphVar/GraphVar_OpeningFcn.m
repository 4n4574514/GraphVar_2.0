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

function GraphVar_OpeningFcn(hObject, eventdata, handles, varargin)
global root_path;
global brain_path;
global isRegisterd;
global workspacePath;
global result_path;
global debug; 
global InterimResults_current;

InterimResults_current = 0;
debug = 1;
isRegisterd = 0;
workspacePath = [];
files = [];
for i=1:2:length(varargin)
    if ischar(varargin{i})
        switch(varargin{i})
            case 'Workspace'
            workspacePath = varargin{i+1};
        end
    end
end

if isempty(workspacePath)
    path= fileparts(mfilename('fullpath'));
    if exist([path 'LastOpend.mat'],'file')
        load([path 'LastOpend.mat'],'workspacePath');
    else
        delete(hObject);
        return;
    end
end
[~,workspaceName] = fileparts(workspacePath);
set(hObject,'Name',['GraphVar - ' workspaceName]);

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(gcf,'javaframe');
jIcon=javax.swing.ImageIcon([ root_path 'src\gui\GraphVar\Icon.png']);
jframe.setFigureIcon(jIcon);  
warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

%manual code to edit font size of uitabgroup title 
%JTabGroup = handles.tabgroup
%jTabGroup.setTitleAt(1,'<html><font color="red"><i>Panel 2');

%panel overlay  ML v. GLM
handles.tabgroup = uitabgroup('Parent', hObject, ...
    'Position',get(handles.panel_glm,'Position'));
handles.tab_glm = uitab('Parent', handles.tabgroup, 'Title', 'GLM');
handles.tab_ml = uitab('Parent', handles.tabgroup, 'Title', 'Machine Learning');

set(get(handles.panel_glm, 'Children'),'Parent', handles.tab_glm);
set(get(handles.panel_svm, 'Children'),'Parent', handles.tab_ml);

delete(handles.panel_glm);
delete(handles.panel_svm);

set(handles.tab_glm,'Tag', 'panel_glm');
set(handles.tab_ml,'Tag', 'panel_svm');


% %panel overlay  manual v. nested panels 
handles.tabgroup2 = uitabgroup('Parent', handles.tab_ml, ...
    'Position',get(handles.nested_tuning,'Position'));          %see nested model tuning first 
handles.tab_nested = uitab('Parent', handles.tabgroup2, 'Title', 'Model Tuning (Nested)');  %handles tabgroup
handles.tab_manual= uitab('Parent', handles.tabgroup2, 'Title', 'Model Tuning (Manual)');

set(get(handles.nested_tuning, 'Children'),'Parent', handles.tab_nested);
set(get(handles.manual_tuning, 'Children'),'Parent', handles.tab_manual);

delete(handles.nested_tuning);
delete(handles.manual_tuning);

set(handles.tab_nested,'Tag', 'nested_tuning');
set(handles.tab_manual,'Tag', 'manual_tuning');

set(hObject,'Units','Pixels');
handles.startSize = get(hObject,'Position');
set(handles.DynamicGraphVar,'Visible','Off');

cd(workspacePath);
result_path = [workspacePath filesep 'results'];
load(fullfile(workspacePath,'Workspace.mat'));
set(handles.edit_varxls,'String',variableSheet,'Value',1);
set(handles.edit_brainxls,'String',brainSheet,'Value',1);
[brainSheet variableSheet] =  abs_rel_correct(brainSheet,variableSheet);
    
functionList = getFunctions();
functionListP = {};


handles.randomFuncDescription = ...
    {
    '<b>randomizer_bin_und</b><br>This function directly searches for rewirable edge pairs (rather than trying to rewire edge pairs at random),<br> and hence avoids long loops and works especially well in dense matrices.' , ...
    '<b>randmio_und</b><br>This function randomizes an undirected network, while preserving the degree distribution.  <br>This function does not preserve the out-strength distribution in weighted networks.' ,...
    '<b>randmio_und_connected</b><br>This function randomizes an undirected network, while preserving the degree distribution.  <br>This function does not preserve the out-strength distribution in weighted networks. <br>Additional (to randmio_und) this version ensures that the randomized network does not disconnect.' , ...
    '<b>randmio_und_signed</b><br>This function randomizes an undirected network, while preserving the degree distribution.  <br>This function does not preserve the out-strength distribution in weighted networks. <br>Additional (to randmio_und) this signed version of the function separately preserves the degree distributions of positive and negative weights.' ...
    };


for i = 1:size(functionList{1},1)
    functionListP{end+1} = ['Binary: ' functionList{1}{i,1}];
end

for i = 1:size(functionList{2},1)
    functionListP{end+1} = ['Weighted: ' functionList{2}{i,1}];
end
functionListDescription = functionList{1}(:,4);
functionListDescription = [functionListDescription ; functionList{2}(:,4)];

handles.functionDescription = functionListDescription;
[handles.BrainMap,handles.brain]       = GraphVar_loadBrainRegions(hObject, eventdata, handles,brainSheet);
[handles.Variables,handles.vpNamesNeo] = GraphVar_loadVariables(hObject, eventdata, handles,0,variableSheet);


handles.vpFiles = {};
count = 1;
thr_str = cell(1,41);

for i = 0.1:0.01:0.5
    thr_str{count} = num2str(i);
    count = count + 1 ;
end

count = 1;
for i = 0.05:0.01:1
    thr_str2{count} = num2str(i);
    count = count + 1 ;
end

count = 1;
thr_str3 = cell(1,41);

for i = 0.1:0.01:0.5
    thr_str3{count} = num2str(i);
    count = count + 1 ;
end

axes(handles.LogoImg);
image(imread('GraphVar.png'));
axis off
axis image 



set(handles.MatrixName,'String',fieldName,'Value',1);

set(handles.list_brainvars_var,'String',functionListP,'Value',1);
set(handles.list_thresholds_var,'String',thr_str,'Value',1);
set(handles.list_thresholds_var2,'String',thr_str2,'Value',1);
set(handles.threshold_list_SICE,'String',thr_str3,'Value',1);

set(handles.filename_start,'String',filename_start,'Value',1);
set(handles.filename_end,'String',filename_end,'Value',1);

if ~ isempty(files)       
    
   if exist(files{1} , 'file')~=2
       if exist(fullfile(workspacePath, 'data','CorrMatrix',files_rel{1}) , 'file')  == 2   
           for i = 1:length(files)
               files{i} = fullfile(workspacePath, 'data','CorrMatrix',files_rel{i});
           end   

           save(fullfile(workspacePath,'Workspace.mat'),'files');
           validFiles = 1;
       else
           validFiles = 0;
       end
   else
       validFiles = 1;
   end
   
   if validFiles
        set(handles.subjects,'String',files_rel);
        content = load(files{1});
        handles.fNames = fieldnames(content);   
        handles.vpFiles = files;
        k = strfind(handles.vpFiles{1}, filesep);
        set(handles.FileName_Selector,'String',handles.vpFiles{1}(k(end)+1:end));
        if sum(strcmp(handles.fNames,'is_dyn')) && content.is_dyn == 1 
            set(handles.DynamicGraphVar,'Visible','On');
            set(handles.DynamicGraphVar2,'Visible','On');
        else
            set(handles.DynamicGraphVar,'Visible','Off');
            set(handles.DynamicGraphVar2,'Visible','Off');
        end
   end
elseif  ~isempty(brain_path) 
    tmpDir = dir(brain_path);
    handles.vpPath = brain_path;

    if(size(tmpDir,1) > 0)
        tmpDir(1:2) = [];
    end

    if(size(tmpDir,1) > 0)
        content = load([brain_path filesep tmpDir(1).name]);
        handles.fNames = fieldnames(content);   
        for i=1:length(tmpDir)
        	handles.vpFiles{i} = [brain_path tmpDir(i).name];
        end
        set(handles.subjects,'String',handles.vpFiles);   
        k = strfind(handles.vpFiles{1}, filesep);
        set(handles.FileName_Selector,'String',handles.vpFiles{1}(k(end)+1:end));
    else
        handles.fNames = {};
    end
end

handles.sigField = [];
handles.output = hObject;


[~, hasP] = isParallel;
    if hasP
        set(handles.editParallelWorkersNumber,'Enable', 'on');
    else
        set(handles.editParallelWorkersNumber,'Enable', 'off');
    end  
    
    
guidata(hObject, handles);