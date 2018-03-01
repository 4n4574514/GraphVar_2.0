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

function GraphVar_CheckFrag_Callback(hObject, eventdata, handles)
global running
global workspacePath;

handles.FragCheck = 1;

[returnVal,dialogData] = GraphVar_getDialogData(handles,1);
if(~returnVal)
    allTasks = [];
    res = 0;
    return;
end
running = 1;
GraphVar_enable_disable(handles,'Off');

% Delete all old frag_check.mat files from the folder
result_path = [workspacePath filesep 'results' filesep 'FragCheck'];
delete([result_path filesep '*.mat']);

[res,n_dyn] = GraphVar_CheckFrag(dialogData.thresholds,dialogData.thresholdType,dialogData.brainD,handles.vpFiles,'TaskPlaner','MatrixName',dialogData.MatrixName,'FilePos',dialogData.subjectNamePos, 'DoRandom',get(handles.RandomNetwork_check,'Value'), 'nRandom', dialogData.nRandom, 'RandomFunction' , 'RandomIterations' , dialogData.randomIter, 'Smallworldness', get(handles.RandomNetwork_smallWorld,'Value'), 'randomForType', [get(handles.binary_check,'Value'),get(handles.weighted_check,'Value')],'DoShuffelRandom',get(handles.shuffel_check,'Value'),'NShuffelRandom',dialogData.nShuffel,'Normalize',dialogData.normalize,'RandomRaw',dialogData.shuffleRandom,'RandomRawIter',dialogData.RandomRawIter,'NoCorr','InterimResult','weightAdjust_Thr',dialogData.weightAdjust_Thr,'DynamicGraphVar', dialogData.DynamicGraphVar);


% LOAD WORKSPACE INFO
load(fullfile(workspacePath,'Workspace.mat'));

for i = 1:length(handles.vpFiles)
    [~,tmp, tmp2] = fileparts(handles.vpFiles{i});
    tmp = [tmp tmp2]; 
    vpNames{i} = tmp(dialogData.subjectNamePos(1):end-dialogData.subjectNamePos(2)); 
end

vpNames = rot90(vpNames,3);

if (res)
    all_thr = dialogData.thresholds;
    for i_thr = 1:length(all_thr)
        
        start = 2 +(size((vpNames),1))* (i_thr-1);
        stop = start + (size((vpNames),1)-1);
        
        curr_thr = all_thr(:,i_thr)*10;
        A = load([result_path filesep 'frag_check_' num2str(curr_thr) '.mat']);
        B = cell2mat(rot90(A.frag_check,3));
        
        %% check fragmentation per subject (across all windows)
        for i = 1:size((vpNames),1)
            if sum(B(i,:))== 0
                QC_subj{i,:} = 'OK';
            else
                QC_subj{i,:} = 'Frag';
            end
        end
        %% identify subjects with fragmentation (across all windows)
        idx = find(strcmp('Frag',QC_subj));
        BS = cell(1);
        for n = 1:length(idx)
            BS{n,1} = vpNames{idx(n),:};
        end
        bad_subj = strjoin(BS,',');
        clear BS
        %% check fragmentation per threshold across sample (across all windows)
        if sum(B(:)) == 0
            QC_thr{1,:} = 'OK';
        else
            QC_thr{1,:} = 'Frag';
        end
        
        %% generate detailed QC table for all subjects
        table_subj(1,1) = cellstr('Subjects');
        table_subj(1,2) = cellstr('Thresholds');
        table_subj(1,3) = cellstr('Network fragmentation');
        table_subj(start:stop,1) = vpNames;
        table_subj(start:stop,2) = num2cell(curr_thr/10);
        table_subj(start:stop,3) = QC_subj;
        if (n_dyn > 1)
            for j = 1:n_dyn
            table_subj(1,3+j) = cellstr(['Window ' num2str(j)]);
            end
            table_subj(start:stop,4:4+(n_dyn-1)) = num2cell(B);
        end
        
        %% generate overview QC table for thresholds
        table_thr(1,1) = cellstr('Thresholds');
        table_thr(1,2) = cellstr('Overall sample status');
        table_thr(1,3) = cellstr('Fragmented networks in subject');
        table_thr(i_thr+1,1) = num2cell(curr_thr/10);
        table_thr(i_thr+1,2) = QC_thr;
        if ~isempty(idx)
            table_thr(i_thr+1,3) = cellstr(bad_subj);
        else
            table_thr(i_thr+1,3) = cellstr('none');
        end
        
    end
end

%% write all tables to .txt files
save_path = [result_path filesep 'FragCheck_Detailed_' (datestr(now,30)) '.txt'];

dlmcell([result_path filesep 'FragCheck_Detailed_' (datestr(now,30)) '.txt'],table_subj);
dlmcell([result_path filesep 'FragCheck_Summary_' (datestr(now,30)) '.txt'],table_thr);
delete([result_path filesep '*.mat']);

logWnd_1 = dialog('WindowStyle', 'normal', 'Name', 'CheckFrag Detailed Log','Resize','on');
t = uitable(logWnd_1,'Data',table_subj,'ColumnWidth',{50},     'units','normalized', ...
     'Position',[0.02 0.02 0.96 0.96] );

logWnd_2 = dialog('WindowStyle', 'normal', 'Name', 'CheckFrag Summary Log','Resize','on');
t = uitable(logWnd_2,'Data',table_thr,'ColumnWidth',{50},     'units','normalized', ...
     'Position',[0.02 0.02 0.96 0.96] );


GraphVar_enable_disable(handles,'On');
end

