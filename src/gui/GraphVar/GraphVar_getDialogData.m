
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

function [returnVal,dialogData] = GraphVar_getDialogData(handles,forCalcFunc,varargin)
global workspacePath; 
if(~isempty(varargin)) 
    noCorr = varargin{1};
else 
    noCorr = 0;
end
dialogData.n_multislice = 100;

dialogData.RandomNetwork_smallWorld = 0;
dialogData.randBinary = 0; dialogData.randWeighted=0;
dialogData.functionsIndex = [];
dialogData.brainXLS = []; dialogData.variableXLS = []; dialogData.subjects = [];
dialogData.randomNetwork_func = [];
dialogData.functionList=[];
dialogData.functionTypeList=[];
dialogData.subjectNamePos=[];
dialogData.randomIter=[];
dialogData.nRandom=[];
dialogData.thresholds=[];
dialogData.thresholdsStr=[];
dialogData.thresholdType=[];
dialogData.MatrixName=[];
dialogData.VarList=[];
dialogData.CovarList=[];
dialogData.brainD=[];
dialogData.ConnectivityThr_bool=[];
dialogData.ConnectivityThr=[];
dialogData.nShuffel=0;    
dialogData.nRandGroup = 0; 
dialogData.normalize = 0; 
dialogData.shuffleRandom = '' ;
dialogData.RandomRawIter = 1 ; 
dialogData.TestAgainstRandomCorr = 0 ;
returnVal = 0;
dialogData.testAgainstShuffel = 0; 
dialogData.newInterimResults = 1;  
dialogData.RandomDataRepitions = 0;
dialogData.weightAdjust_Thr = 0;
dialogData.weightAdjust_Raw = 0;
dialogData.R2Z = get(handles.r2z_check,'Value');
%%%%%%%%%%%

dialogData.DoML=[];
dialogData.ML_method=[];
dialogData.ML_nCVFolds=[];
dialogData.ML_nHyperOptSteps=[];
dialogData.ML_FeatSelThres=[];
dialogData.ML_Outcome=[];
dialogData.ML_nuisance=[];
dialogData.DoFeatureSelection = [];
dialogData.DoHyperparameterOptimization = [];

dialogData.DoNetwork=[];
dialogData.DoGraph=[];
%dialogData.threshold_list_SICE=[];
dialogData.subjects=[];
dialogData.ML_parametric=[];

%Ml manual panel dialog 
dialogData.ML_mpar1= [];
dialogData.ML_mpar2= [];
dialogData.doManual = [];

dialogData.doManual= ~strcmp(get(get(handles.tabgroup2, 'SelectedTab'), 'Title'), 'Model Tuning (Nested)');
dialogData.mpar1= str2double(get(handles.ml_PString1, 'String'));
dialogData.mpar2= str2double(get(handles.ml_PString2, 'String'));

dialogData.DoML= ~strcmp(get(get(handles.tabgroup, 'SelectedTab'), 'Title'), 'GLM');  % 
values = get(handles.classifier_type, 'String');
dialogData.ML_method= values{get(handles.classifier_type,'Value')} ;  %classifier type 
dialogData.ML_nCVFolds= str2double(get(handles.cv_fold_number, 'String'));
dialogData.ML_Outcome = get(handles.list_response,'String');

dialogData.ML_nuisance = get(handles.list_nuisance_covariates,'String');
dialogData.ML_extra = get(handles.list_extra_feat,'String');
dialogData.ML_nHyperOptSteps=str2double(get(handles.hyperopt_steps, 'String'));
dialogData.ML_FeatSelThres=str2double(get(handles.featsel_thres, 'String'));

dialogData.DoFeatureSelection = get(handles.do_featsel,'Value');
dialogData.DoHyperparameterOptimization = get(handles.do_hyperopt,'Value');

dialogData.ML_test_type = get(get(handles.uibuttongroup8,'SelectedObject'), 'Tag');
dialogData.RandomDataRepitionsML   =  str2double(get(handles.RandomDataRepitionsML,'String'));

dialogData.DoNetwork= get(handles.DoNetwork,'Value');
dialogData.DoGraph= get(handles.DoGraph,'Value');

dialogData.ML_parametric= get(handles.do_ml_parametric,'Value');
dialogData.subjects= get(handles.subjects,'String');

dialogData.random_network=get(get(handles.graph_metrics_testing,'SelectedObject'), 'Tag');
dialogData.random_raw=get(get(handles.raw_matrix_testing,'SelectedObject'), 'Tag');

idx = get(handles.DynamicGraphVar,'Value');
strings = get(handles.DynamicGraphVar,'String');
dialogData.DynamicGraphVar = strings(idx);

idx = get(handles.DynamicGraphVar2,'Value');
strings = get(handles.DynamicGraphVar2,'String');
dialogData.DynamicGraphVar2 = strings(idx);


idx = get(handles.classifier_type,'Value');
strings = get(handles.classifier_type,'String');
dialogData.classifier_type = strings(idx);

dialogData.weightAdjust_Thr = get(handles.weights_absolute,'Value')  + 2 * get(handles.weights_negToZero,'Value');
dialogData.weightAdjust_Raw = get(handles.weights_absolute_raw,'Value')  + 2 * get(handles.weights_negToZero_raw,'Value');

dialogData.n_multislice = str2double(get(handles.n_multislice,'String'));

dialogData.TestAgainstRandom = 0;
dialogData.testAgainstRandGroup = 0;
dialogData.TestAgainstRandomData = 0;
dialogData.testAgainstRandGroup_check	= 0;
dialogData.testRawAgainstRandom_check   =  0;

if(~check_StructureName(handles,forCalcFunc))
    return;
end

dialogData.randBinary = get(handles.binary_check,'Value');
dialogData.randWeighted=get(handles.weighted_check,'Value');

GraphVar_saveSettings(handles);
dialogData.newInterimResults = get(handles.newInterimResults_check,'Value');

index_selected = get(handles.list_brainvars_var,'Value');
dialogData.functionsIndex = index_selected;

fullFunctionList = getFunctions(0);
fLength = size(fullFunctionList{1},1);
binary = index_selected(index_selected<=fLength);
weighted = index_selected(index_selected>fLength)-fLength;
if get(handles.DoGraph,'Value')
    dialogData.functionList{1} =         fullFunctionList{1}(binary,2);
    dialogData.functionList{2} =         fullFunctionList{2}(weighted,2);
    dialogData.functionTypeList{1} =     fullFunctionList{1}(binary,3);
    dialogData.functionTypeList{2} =     fullFunctionList{2}(weighted,3);
else
    dialogData.functionList{1} =        {};
    dialogData.functionList{2} =        {};
    dialogData.functionTypeList{1} =    {};
    dialogData.functionTypeList{2} =    {};
end
dialogData.brainXLS = get(handles.edit_brainxls,'String') ;
dialogData.variableXLS = get(handles.edit_varxls,'String') ;
dialogData.subjects = handles.vpFiles;

dialogData.RandomNetwork_smallWorld = get(handles.RandomNetwork_smallWorld,'Value') ;
if get(handles.RandomNetwork_smallWorld,'Value') || strcmp(dialogData.random_network,'graph_randNW') || get(handles.normalize,'Value');
    if ~get(handles.RandomNetwork_check,'Value')
        errordlg('You need to create randomized subject data(Network Construction), if you want to use it for smallworldness or comparison.');
        return;
    elseif (~get(handles.binary_check,'Value')) && (~isempty(dialogData.functionList{1})) && (get(handles.normalize,'Value'))
        errordlg('You need to create --> BINARY <-- randomized subject data(Network Construction), if you want to use it for smallworldness or comparison.');
        return;
    elseif (~get(handles.weighted_check,'Value')) && (~isempty(dialogData.functionList{2})) && (get(handles.normalize,'Value'))
        errordlg('You need to create --> WEIGHTED <-- randomized subject data(Network Construction), if you want to use it for smallworldness or comparison.');
        return;
    end
end

if strcmp(dialogData.random_raw,'raw_randNW') && (~get(handles.shuffel_check,'Value'))
    errordlg('You need to create shuffeld subject data (Raw Matrix), if you want to test against it.');
    return;
end


if(get(handles.RandomNetwork_smallWorld,'Value') && ~forCalcFunc )
    if(get(handles.binary_check,'Value'))
        dialogData.functionList{1} = [dialogData.functionList{1}{:} {'smallworldness_bu'}];
        dialogData.functionTypeList{1} = {dialogData.functionTypeList{1},2};
    end
    if(get(handles.weighted_check,'Value'))
        dialogData.functionList{2} = [dialogData.functionList{2}{:} {'smallworldness_wu'}];
        dialogData.functionTypeList{2} = {dialogData.functionTypeList{2},2};
    end
end

dialogData.functionList{4} = {};
if get(handles.DoNetwork,'Value')
    if strcmp(dialogData.DynamicGraphVar2,'Brain-Network Variability')
        dialogData.functionList{4} = fullFunctionList{3}(1,6);
        dialogData.functionList{3} = {};
    else
        dialogData.functionList{3} = fullFunctionList{3}(1,2);
    end
else
    dialogData.functionList{3} = {};
end
% GET THE SUBJECT NAME POSITION IN FILENAME
dialogData.subjectNamePos(1) = str2double(get(handles.filename_start,'String'));
dialogData.subjectNamePos(2) = str2double(get(handles.filename_end,'String'));
if ~isempty(find(isnan(dialogData.subjectNamePos),1))
    errordlg('Start or end position of subject name in filename is not a valid number');
    return;
end

dialogData.normalize = get(handles.normalize,'Value') ;

% Get number of random networks and number of iterations
dialogData.nRandom = 0;
dialogData.randomIter = 0;
if(get(handles.RandomNetwork_check,'Value'))
    dialogData.randomIter = str2double(get(handles.RandomNetwork_iter,'String'));
    if isnan(dialogData.randomIter)
        errordlg('The number of iterations is not a valid number');
        return;
    end
    dialogData.nRandom = str2double(get(handles.RandomNetwork_n,'String'));
    dialogData.randomNetwork_func = get(handles.RandomNetwork_func,'String');
    dialogData.randomNetwork_func = dialogData.randomNetwork_func(get(handles.RandomNetwork_func,'Value'));

    
    if isnan(dialogData.nRandom) || (abs(round(dialogData.nRandom)-dialogData.nRandom)) > eps('double')
        errordlg('The number of random networks is not a valid number');
        return;
    end
    if dialogData.nRandom < 1
        errordlg('Randomized subject data:  Please enter a number higher than zero (Network Construction)');
        return;
    end
end

% Get threshholds and threshhold type

if (get(handles.DoGraph,'Value'))
    if(get(handles.Rel_radio,'Value'))
        index_selected = get(handles.list_thresholds_var,'Value');
        thresholdStr = get(handles.list_thresholds_var,'String');
        dialogData.thresholdType = 1;
    elseif (get(handles.Abs_Radio,'Value'))
        index_selected = get(handles.list_thresholds_var2,'Value');
        thresholdStr = get(handles.list_thresholds_var2,'String');
        dialogData.thresholdType = 2;
    elseif (get(handles.Significant_Radio,'Value'))
        index_selected = get(handles.list_thresholds_Sig,'Value');
        thresholdStr = get(handles.list_thresholds_Sig,'String');
        dialogData.thresholdType = 3;
    elseif (get(handles.SICE_Radio,'Value'))
        index_selected = get(handles.threshold_list_SICE,'Value');
        thresholdStr = get(handles.threshold_list_SICE,'String');
        dialogData.thresholdType = 5;
    else 
        index_selected = [1 2];
        thresholdStr = {'0';'0'};
        dialogData.thresholdType = 4;
    end
    
    dialogData.thresholds = rot90(str2double(thresholdStr(index_selected)));
    dialogData.thresholdsStr = thresholdStr(index_selected);
else
    dialogData.thresholdStr = {};
    dialogData.thresholdType = 0;
    dialogData.thresholds = [];
end

% Check if there are filenames
if(isempty(handles.vpFiles))
    errordlg('Please select Files');
    return
end

% Get the matrix name (Field where Correlation is stored)
dialogData.MatrixName = get(handles.MatrixName,'String');

if(~noCorr)
    dialogData.VarList      = get(handles.list_cov_vars,'String');
    dialogData.BetweenList  = get(handles.list_between_vars,'String');
    dialogData.WithinList   = get(handles.list_within_vars,'String');
    dialogData.NuisanceList = get(handles.list_nuisance_vars,'String');
    dialogData.withinID  = get(handles.withinID,'String');
    dialogData.Interactions = get(handles.interactions_Popup,'Value');
    
    dialogData.testAgainstRandGroup = strcmp(dialogData.random_network,'graph_randNW');
    dialogData.TestAgainstRandomData = strcmp(dialogData.random_network,'graph_permutation') ||  strcmp(dialogData.random_raw,'raw_permutation');
    dialogData.testAgainstRandGroup_check	= strcmp(dialogData.random_network,'graph_permutation') ||  strcmp(dialogData.random_raw,'raw_permutation');
    dialogData.testRawAgainstRandom_check   =  strcmp(dialogData.random_raw,'raw_randNW');
    if strcmp(dialogData.random_network,'graph_randNW') ||  strcmp(dialogData.random_network,'graph_permutation') || ...
       strcmp(dialogData.random_raw,'raw_randNW')     ||  strcmp(dialogData.random_raw,'raw_permutation')
        dialogData.RandomDataRepitions   =  str2double(get(handles.RandomDataRepitions,'String'));

        if isnan(dialogData.RandomDataRepitions) || (abs(round(dialogData.RandomDataRepitions)-dialogData.RandomDataRepitions)) > eps('double')
            errordlg('The number of repetition is not a valid number');
            return;
        end
        if dialogData.RandomDataRepitions < 1
            errordlg('#Rep:  Please enter a number higher than zero (Group Comparison)');
            return;
        end
    end    
end


% Get the Brainregions
index_selected = get(handles.list_brainareas,'Value');
dialogData.brainD = zeros(1,length(handles.brain));



dialogData.brainD(index_selected) = 1;
if(~ get(handles.RandomNetwork_check,'Value'))
    dialogData.nRandom = 0;
end

if get(handles.ConnectivityThr_Check,'Value') && get(handles.DoNetwork,'Value')
    dialogData.ConnectivityThr_bool = 1;
    dialogData.ConnectivityThr = get(handles.ConnectivityThr_Listbox,'String');
    dialogData.ConnectivityThr = str2double(dialogData.ConnectivityThr(get(handles.ConnectivityThr_Listbox,'Value')));
else
    dialogData.ConnectivityThr_bool = 0;
    dialogData.ConnectivityThr = [];
end

if get(handles.DoNetwork,'Value')&& isempty(dialogData.ConnectivityThr)
    dialogData.ConnectivityThr = 1;
end

if get(handles.shuffel_check,'Value') &&  get(handles.DoNetwork,'Value')
    dialogData.nShuffel = str2double(get(handles.shuffel_n,'String'));
    dialogData.shuffleRandom = get(handles.raw_random,'String');
    dialogData.shuffleRandom = dialogData.shuffleRandom( get(handles.raw_random,'Value'));
    dialogData.RandomRawIter = str2double(get(handles.RandomRawIter,'String'));
    %dialogData.R2Z = get(handles.r2z_check,'Value');
    %this would additionally transform
    %the resulting r-values of the correlational analysis into z values
    %(also for the correlation with random data) that will be used for
    %non-parametric p-value calculations -> would have to be changed in the
    %calccorrectedpval script in src/calc as well
    if isnan(dialogData.RandomRawIter)
        errordlg('The number of iterations is not a valid number');
        return;
    end
   
    if isnan(dialogData.nShuffel) || (abs(round(dialogData.nShuffel)-dialogData.nShuffel)) > eps('double')
        errordlg('The number of random shuffel natworks is not a valid number');
        return;
    end
    if dialogData.nShuffel < 1
        errordlg('Shuffeld subject data:  Please enter a number higher than zero (Raw Matrix)');
        return;
    end
end

returnVal = 1;

%************************************************************************%
%************************************************************************%

function res =check_StructureName(handles,isFirst)
matrixName = get(handles.MatrixName,'String');
if ~isfield(handles,'vpFiles') || isempty(handles.vpFiles)
    res = 0;
    errordlg('Please select Subjects.');
    return;
end
file = load(handles.vpFiles{1});
if(~isfield(file,matrixName))
    res = 0;
    errordlg('The selected Field (for correlation Values) does not exsist in the files');
else
    res = 1;
end

s = str2double(get(handles.filename_start,'String'));
e = str2double(get(handles.filename_end,'String'));

name = get(handles.FileName_Selector,'String');
s(s==0) = 1;
name = name(s:end-e);
if isempty(name) 
    errordlg('Please select subject name in file name');
    res = 0; 
    return;
end

%ML related error messages... 



if ~strcmp(get(get(handles.tabgroup, 'SelectedTab'), 'Title'), 'GLM')
        beep on % turn on beep warning sound 
        %determine type input (response) appropriate for test selected
        global workspacePath
        load(fullfile(workspacePath,'Workspace.mat'));
        [~, variableSheet] =  abs_rel_correct(brainSheet,variableSheet);
        if(exist([workspacePath filesep 'ImportSettings.mat'],'file'))
            load([workspacePath filesep 'ImportSettings.mat']);
        else
            userVar = 2;
        end
        [NeoData] = importSpreadsheet(variableSheet);
        response = get(handles.list_response,'String');
        handles.varnames = NeoData(1,:);
        n = handles.varnames;
        
        for i = 1:numel(response) 
           tf = find(strcmp(response(i),n));
           A = NeoData(:, tf);
        end
        get(handles.classifier_type,'String');
        values  = get(handles.classifier_type, 'String');
        method = values{get(handles.classifier_type,'Value')} ;  %classifier type 
        c = ~isempty(regexp(method, 'classification$'));                                        % 1= class 0 = reg
        A = (A(2:end));
        B = iscellstr(A);      % call if different format 
        if B == 1 
        res_type = length(unique(A));
        elseif B == 0 
        A=cell2mat(A);
        res_type = length(unique(A));
        end
           
        if c == 0 && res_type <= 2  %model reg with grouping
            errordlg('Regression: please select continious outcome variable.');
                res = 0; 
                return;
        end
        
        if c == 1 && res_type > 2     %model classf with conti
            errordlg('Classification: Please select grouping variable.');
                res = 0; 
                return;
        end

        %%%%
         if isempty(response)    % force user to pick outcome var 
                errordlg('Please select an outcome variable (class or value)');
                res = 0; 
                return;
         end

%          if length(response) >=2    %only 1 outcome var 
%                 msgbox('More than 1 outcome variable selected. Running multiple predictions.');            
%          end

        RawThr = get(handles.ConnectivityThr_Listbox,'Value');
         if length(RawThr) >=2    %multiple Raw Mat thresholds selected 
                errordlg('Please select 1 Raw Matrix Threshold at any time.');
                res = 0; 
                return;
         end

        feat_sel=   sum( get(handles.DoNetwork,'Value') +   get(handles.DoGraph,'Value') ) ;
        list = isempty( get(handles.list_extra_feat,'String'));
         if  feat_sel == 0  && list == 1  %Check if a feature was selected 
                errordlg('No features selected. Select a feature to proceed.');
                res = 0; 
                return;
         end

        Perm_Btn = (get(handles.do_ml_parametric,'Value'));
        nPerm = str2num(get(handles.RandomDataRepitionsML,'String'));        %#Perms chosen
        noPerm = sum ( isempty(nPerm) || nPerm < 2 );
        
        if Perm_Btn == 0  &&  noPerm == 1    %doPermutation but nPerms = 0 or empty (or char?)
                errordlg('Please enter number of Permutations to proceed.');
                res = 0; 
                return;
        end
        
         if noPerm == 0  &&   Perm_Btn == 1    %doPermutation but nPerms = 0 or empty (or char?)
                errordlg('To proceed with Parametric test, set # Permutations to 0.');
                res = 0; 
                return;
         end
       
        
end 
 
if isscalar(handles.vpNamesNeo{2})
    name = str2double(name);
    handles.vpNamesNeo = cell2mat(handles.vpNamesNeo(2:end));
end

if ~ismember(name, handles.vpNamesNeo) && isFirst
    options.Default = 'No';
    options.Interpreter = 'none';
    
    choise = questdlg('The first subject name could not be found in the excel sheet do you want to continue ? ','Subject Name',...
        'Yes','No',options);
    if strcmp(choise,'No')
        res = 0;
    end
end