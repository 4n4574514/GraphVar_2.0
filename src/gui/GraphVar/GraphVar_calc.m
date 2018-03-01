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

function [res,allTasks] = GraphVar_calc(handles,varargin)
global running
global workspacePath;
global InterimResultsID

if(~isempty(varargin)) 
    noCorr = varargin{1};
else 
    noCorr = 0;
end

[returnVal,dialogData] = GraphVar_getDialogData(handles,1,noCorr);

if(~returnVal)
    allTasks = [];
    res = 0;
    return;
end
running = 1;
randomNetwork_func = get(handles.RandomNetwork_func,'String');
randomNetwork_func = randomNetwork_func(get(handles.RandomNetwork_func,'Value'));

nSub = length(handles.vpFiles);
nOp = GraphVar_numberOfOperations(handles.vpFiles,dialogData);

if (exist(dialogData.variableXLS,'file')==2) && noCorr
    noCorr = 0;    
end
if dialogData.newInterimResults
    InterimResultsID = load([workspacePath filesep 'results' filesep 'InterimResultsID.mat']);
    InterimResultsID = InterimResultsID.InterimResultsID + 1;
    mkdir([workspacePath filesep 'results' filesep num2str(InterimResultsID)]);
    
    mkdir([workspacePath filesep 'results' filesep num2str(InterimResultsID) filesep 'GraphVars']);
    mkdir([workspacePath filesep 'results' filesep num2str(InterimResultsID) filesep 'RandomizedShuffel']);
          
    
    save([workspacePath filesep 'results' filesep 'InterimResultsID.mat'],'InterimResultsID');
    InterimResultsID = num2str(InterimResultsID);    

else
    InterimResultsID = 'default';
end
    dateTime = now;

save([workspacePath filesep 'results' filesep InterimResultsID filesep 'info.mat'],'dialogData','dateTime');

allTasks = ...
    folder('All Tasks',1,nOp, {...
    folder('Create Shuffeld Subjects',1,nSub*dialogData.nShuffel) , ...
    folder('Thresholds',1,length(dialogData.thresholds),{ ...
        folder('Types',0,2,{ ...
        folder('Thresholding Subject',1,nSub),...
        folder('Randomize Subject',1,nSub*dialogData.nRandom) ...
    }), ...
    folder('Graph Function',1,length(dialogData.functionList{1}) + length(dialogData.functionList{2}),{ ...
    folder('Subject',1,nSub + ((dialogData.nRandom)*nSub))...
    }), ...
    }) ...
    folder('GLM', 1, 1, { ...
                folder('Variable', 1, 1, { ...
                    folder('Threshold', 1, 1, { ...
                        folder('Chunk', 1, 1, {folder('Null', 1, 1, {})})}) ...        
    })}), ...
    folder('SVM', 1, 1, { ...
                folder('Permutation', 1, 1, { ...
                    folder('Cross-validation fold', 1, 1, { ...
                        folder('Nested cross-validation fold', 1, 1, {folder('Null', 1, 1, {})}) ...         
    })})}), ...
    }).init();

if ~isfield(handles,'sigField')
    handles.sigField =[];
end

[res,shuffelFiles] = CalcVars(dialogData.thresholds,dialogData.thresholdType,dialogData.brainD,dialogData.functionList,handles.vpFiles,'TaskPlaner',allTasks,'MatrixName',dialogData.MatrixName,'FilePos',dialogData.subjectNamePos, 'DoRandom',get(handles.RandomNetwork_check,'Value'), 'nRandom', dialogData.nRandom, 'RandomFunction' ,randomNetwork_func ,  'RandomIterations' , dialogData.randomIter, 'Smallworldness', get(handles.RandomNetwork_smallWorld,'Value'), 'randomForType', [get(handles.binary_check,'Value'),get(handles.weighted_check,'Value')],'pValueField',handles.sigField,'TestAgainstRandom',strcmp(dialogData.random_network,'graph_randNW'),'DoShuffelRandom',get(handles.shuffel_check,'Value'),'NShuffelRandom',dialogData.nShuffel,'Normalize',dialogData.normalize,'RandomRaw',dialogData.shuffleRandom,'RandomRawIter',dialogData.RandomRawIter,'NoCorr',noCorr,'InterimResult',InterimResultsID,'weightAdjust_Thr',dialogData.weightAdjust_Thr,'DynamicGraphVar', dialogData.DynamicGraphVar,'n_multislice', dialogData.n_multislice);

if ~res
    rmdir([workspacePath filesep 'results' filesep num2str(InterimResultsID)],'s');
    return; 
end

if get(handles.DoNetwork,'Value') && ~noCorr
    getMeanMatrix(handles.vpFiles,dialogData.MatrixName,dialogData.brainD,dialogData.subjectNamePos,0,InterimResultsID, dialogData.R2Z);
    outputName = dialogData.functionList{3};
    if isempty(outputName)
        outputName = dialogData.functionList{4};
    end
    outputName = outputName{:};
    calcCorrMatrixResult = CalcCorrMatrix(handles.vpFiles,dialogData.MatrixName,dialogData.brainD,1,dialogData.subjectNamePos,handles.sigField,dialogData.ConnectivityThr_bool,dialogData.ConnectivityThr,0,InterimResultsID,dialogData.weightAdjust_Raw, dialogData.R2Z, dialogData.DynamicGraphVar2,outputName);
    if isscalar(calcCorrMatrixResult) && calcCorrMatrixResult == 0
        res = 0;
        return;
    end
    if get(handles.shuffel_check,'Value')
%         if ~ get(handles.shuffel_check,'Value')
%             errordlg('You cannot test against random networks if you dont create some');
%             res = 0; return;
%         end
        for i = 1:dialogData.nShuffel
            getMeanMatrix(shuffelFiles(i,:),dialogData.MatrixName,dialogData.brainD,dialogData.subjectNamePos,i,InterimResultsID, dialogData.R2Z);
            CalcCorrMatrix(shuffelFiles(i,:),dialogData.MatrixName,dialogData.brainD,1,[9 11],handles.sigField,dialogData.ConnectivityThr_bool,dialogData.ConnectivityThr,i,InterimResultsID,dialogData.weightAdjust_Raw, dialogData.R2Z, dialogData.DynamicGraphVar2, outputName);
        end
    end
end
set(handles.Corr,'Enable','on')




%[~ b] = ismember(dialogData.functionList{1},fullFunctionList{1}(:,2))