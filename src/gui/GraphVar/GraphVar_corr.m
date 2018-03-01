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

function res = GraphVar_corr(handles, varargin)
global result_path;
global InterimResultsID;

global wait
global running;
global debug;
global fid;
[returnVal,dialogData] = GraphVar_getDialogData(handles,0);

doML = dialogData.DoML;

Files = [];
if dialogData.testAgainstRandGroup
    nRand = dialogData.nRandGroup;
else
    nRand =dialogData.nRandom;
end

if nargin > 1
    allTasks = varargin{1};
elseif doML
    allTasks = folder('All Tasks', 1, 1, ...
        {
            folder('SVM', 1, 1, { ...
                folder('Cross-validation fold', 1, 1, { ...
                    folder('Nested cross-validation fold', 1, 1, {folder('Null', 1, 1, {})}) ... 
                }), ...
                folder('Permutation', 1, 1, { ...
                    folder('Cross-validation fold', 1, 1, { ...
                        folder('Nested cross-validation fold', 1, 1, {folder('Null', 1, 1, {})}) ...        
        })})})}).init();
else
    allTasks = folder('All Tasks', 1, 1, ...
        {
            folder('GLM', 1, 1, { ...
                folder('Variable', 1, 1, { ...
                    folder('Threshold', 1, 1, { ...
                        folder('Chunk', 1, 1, {folder('Null', 1, 1, {})}) ...        
        })})})}).init();
end
allTasks.start()

if(~returnVal)
    multiWaitbar('CloseAll');
    res = 0;
    return;
end

try
    fclose(fid);
    rmdir([result_path filesep 'CorrResults'],'s');
    mkdir([result_path filesep 'CorrResults']);
catch
end
running = 1;

dialogData.ConnectivityThr = unique(dialogData.ConnectivityThr);
dialogData.thresholds = unique(dialogData.thresholds);
dialogData.thresholdsStr = unique(dialogData.thresholdsStr);

NCV = dialogData.NuisanceList;
RDR = dialogData.RandomDataRepitions;
if doML
    NCV = dialogData.ML_nuisance;
    RDR = dialogData.RandomDataRepitionsML;
end

[Files, LAB, N] = executeStats(allTasks, ...
                         dialogData.functionList, ...
                         dialogData.thresholds, ...
                         dialogData.VarList, ...
                         dialogData.BetweenList, ...
                         dialogData.withinID, dialogData.WithinList, ...
                         NCV, dialogData.ML_extra, ...
                         dialogData.Interactions, ...
                         dialogData.random_network, ...
                         dialogData.random_raw, ...
                         dialogData.ML_test_type, ...
                         RDR, ...
                         dialogData.nShuffel, ...
                         dialogData.nRandom, ...
                         dialogData.ConnectivityThr, ...
                         doML, ...
                         dialogData.DoFeatureSelection, dialogData.ML_FeatSelThres, ...
                         dialogData.DoHyperparameterOptimization, dialogData.ML_nHyperOptSteps, ...
                         dialogData.ML_method, ...
                         dialogData.ML_nCVFolds, ...
                         dialogData.ML_Outcome, ...
                         dialogData.doManual, ...
                         dialogData.mpar1, ...
                         dialogData.mpar2 );

nShuffel = dialogData.nShuffel;
nRandom = dialogData.nRandom;

if dialogData.RandomDataRepitions > 0
    nRandom = dialogData.RandomDataRepitions;
    nShuffel = dialogData.RandomDataRepitions;
end
if ~iscell(Files)
    fclose(fid);
    res = 0;
    multiWaitbar('CloseAll');
    return;
end

dialogData.nShuffel = nShuffel;
dialogData.nRandom = nRandom;
dialogData.N = N;
dialogData.Files = Files;
dialogData.InterimResultsID = InterimResultsID;
dialogData.VarList = LAB;
VarList = dialogData;
save([result_path filesep 'CorrResults' filesep 'VarList' '.mat'],'VarList');
clear Settings;

multiWaitbar('CloseAll');

if(running)
    delete(wait);
    running = 0;
    Results;
else
    fclose(fid);
end

