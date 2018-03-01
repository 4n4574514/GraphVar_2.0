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

%% EXPORT DATA TO XLS
function GraphVar_CalcExport_Callback(hObject, eventdata, handles)
global workspacePath;
global inter
global running;
global InterimResultsID;


dname = uigetdir('','Select Folder To Export');
if ~ischar(dname) && dname == 0
    return;
end
fileType = questdlg('Please select export file format. Excel is only supported on Windows with installed Excel', ...
    'Export', ...
    'Excel','CSV','CSV');
if isempty(fileType)
    return;
end


GraphVar_enable_disable(handles,'Off');

filesType = strcmp(fileType,'Excel'); % 1 = Excel, 0 = CSV

[res allTasks] = GraphVar_calc(handles,1);
exportTask = folder('Exporting',1,1, {}).init(0);
allTasks.contents =[allTasks.contents, {exportTask}];
exportTask.start()
exportTask.setBusy();

% LOAD WORKSPACE INFO
load(fullfile(workspacePath,'Workspace.mat'));
result_path = [workspacePath filesep 'results'];
selectVP =load([result_path filesep InterimResultsID filesep 'Settings.mat']);


for i = 1:length(handles.vpFiles)
    [~,vpNames{i}] = fileparts(handles.vpFiles{i});;
end

[~,dialogData] = GraphVar_getDialogData(handles,0,1);
if(res)
    for type = 1:2
        tmpFunctionList = dialogData.functionList{type};
        for i_thr = 1:length(dialogData.thresholds)
            globalC = 1;
            for i_func = 1:length(tmpFunctionList)
                load([result_path filesep InterimResultsID filesep 'GraphVars' filesep  tmpFunctionList{i_func} '_' num2str(dialogData.thresholds(i_thr)*10) '_' num2str(type) '.mat'])
                if(sum(size(Result{1}) > 1))
                    Shape = [Result{:}];
                    if(sum(size(Shape) == 1) > 0)
                        nCol = max(size(Result{1}));
                        tes = flipud(rot90(reshape(Shape,nCol,length(Shape)/nCol),1));
                    else
                        tes = flipud(rot90(Shape));
                    end
                    if(filesType == 1)
                        xlswrite([dname filesep tmpFunctionList{i_func}],rot90(handles.BrainMap(logical(dialogData.brainD))),num2str(dialogData.thresholds(i_thr)),'B1');
                    else
                        brStr = rot90(handles.BrainMap(logical(dialogData.brainD)));
                        outCell(1,2:length(brStr)+1) = brStr;
                    end                 
                    if(sum(size(Result{1}) > 1) == 2)
                        arrOut = cell(0,0);
                        vps = vpNames;
                        brain = handles.BrainMap(logical(dialogData.brainD));
                        for i = 1:length(vps)
                            for ii = 1:length(brain)
                                arrOut{end+1,1} = [vps{i} ' - '  brain{ii}];
                            end
                        end
                        if(filesType == 1)
                            xlswrite([dname filesep tmpFunctionList{i_func}],arrOut,num2str(dialogData.thresholds(i_thr)),'A2');
                        else
                            outCell(2:size(arrOut,1)+1,1:size(arrOut,2)) = arrOut; 
                       end
                    else
                        if(filesType == 1)
                            xlswrite([dname filesep tmpFunctionList{i_func}],rot90(vpNames,3),num2str(dialogData.thresholds(i_thr)),'A2');
                        else
                            outCell(2:length(vpNames)+1,1) = vpNames; 
                        end
                    end
                    if(filesType == 1)
                        xlswrite([dname filesep tmpFunctionList{i_func}],tes,num2str(dialogData.thresholds(i_thr)),'B2');
                    else
                        outCell(2:size(tes,1)+1,2:size(tes,2)+1) = num2cell(tes);
                        dlmcell([dname filesep tmpFunctionList{i_func} '-' num2str(dialogData.thresholds(i_thr)) '.txt'],outCell);
                    end
                    
                else
                    globalOut(:,globalC) = [tmpFunctionList{i_func} ; rot90(Result,3)];
                    globalC = globalC + 1;
                end
                exportTask.setBusy();
                if(~running)
                    GraphVar_enable_disable(handles,'On');
                    return;
                end
                
                
            end
            if globalC > 1
                
                if(filesType == 1)
                    xlswrite([dname filesep 'globalVariables'],flipud(rot90(vpNames)),num2str(dialogData.thresholds(i_thr)),'A2');
                    xlswrite([dname filesep 'globalVariables'],globalOut,num2str(dialogData.thresholds(i_thr)),'B1');
                else
                    outCell(2:length(vpNames)+1,1) = flipud(rot90(vpNames));
                    outCell(1:size(globalOut,1),2:size(globalOut,2)+1) =  globalOut;
                    dlmcell([dname filesep 'globalVariables' '-' num2str(dialogData.thresholds(i_thr)) '.txt'],outCell);
                end
            end
        end
    end
end

% if exist(dialogData.variableXLS,'file')~=2
%     rmdir([result_path filesep InterimResultsID filesep],'s');
% end


multiWaitbar('CloseAll');
GraphVar_enable_disable(handles,'On');
