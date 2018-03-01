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

function [res,shuffelFiles] = CalcVars(thresholds,thresholdType, brain,functions,files,varargin)
global running;
global workspacePath;
load(fullfile(workspacePath,'Workspace.mat'));
[brainSheet variableSheet] =  abs_rel_correct(brainSheet,variableSheet);
[MatrixName, filePos, allTasks, doRandom, nRandom, randomFunction, randomIterations, smallworldness, ...
    randomForType, pValueField, testAgainstRandom, doShuffelRandom, nShuffelRandom,normalize,random_shuffle_calc,randomRawIter,noCorr,InterimResult, weightAdjust_Thr,DynamicGraphVar,n_multiply] = ...
    getArgs(varargin,{'MatrixName','P'},'FilePos','TaskPlaner',{'DoRandom',0},'nRandom','RandomFunction','RandomIterations','Smallworldness','randomForType',{'pValueField','PValMatrix'},{'TestAgainstRandom',0},{'DoShuffelRandom',0},{'NShuffelRandom',0},{'Normalize',0},{'RandomRaw',''},{'RandomRawIter',0},{'NoCorr',0},{'InterimResult','default'},{'weightAdjust_Thr',0},{'DynamicGraphVar',''},{'n_multislice','100'});

result_path = [workspacePath filesep 'results' filesep InterimResult];
% is_dyn = 1;
multislice = 0;
continueWithNeg = 0;
InterimResult_num = InterimResult;

%[BrainMap] = xlsread(brainSheet);
%BrainMap(:,1) = brain;

if(exist([workspacePath filesep 'ImportSettings.mat'],'file'))
    load([workspacePath filesep 'ImportSettings.mat']);
else
    userVar = 2;
end

if(noCorr ~=1)
    [NeoData] = importSpreadsheet(variableSheet);
    ID = NeoData(2:end,userVar);
    
    hasNumericalID = 0;
    if isscalar(ID{1})
        ID = cell2mat(ID(:));
        hasNumericalID = 1;
    end
    
    clear NeoData;
end
loc = [];

shuffelFiles = [];

if iscell(pValueField)
    pValueField = pValueField{:};
end

nSub = length(files);
if(iscell(MatrixName))
    MatrixName  = MatrixName{:};
end
emptyCells = ~cellfun(@isempty,functions);
types = 1:2;
types = types(emptyCells(1:2));

if smallworldness
    types = unique([types 1:length(randomForType)]);
end

allTasks.start();


%% ************************************************************************************
%% PART 1:
%% Create Shuffeld Subjects (NO Thresholding!!)
if(doShuffelRandom)
    actTask = allTasks.getTask('Create Shuffeld Subjects');     actTask.start();
    shuffelFiles = cell(nShuffelRandom,nSub);
    
    if isParallel
        
        disp(repmat('#', 2, 60))
        disp([repmat('#', 1, 24) '  Progress  ' repmat('#', 1, 24)])
        disp([repmat('#', 1, 24) '  Display  ' repmat('#', 1, 25)])
        disp(repmat('#', 2, 60))
        disp('Press Ctrl-C to cancel. ')
        
        parfor i_sub_p=1:nSub
            %         disp(checkGlobalRunning())
            %         if(checkGlobalRunning())
            %% STD SUBJECT LOAD PROCEDURE
            FileCont = load (files{i_sub_p});     % Load a Subject
            k = strfind(files{i_sub_p}, filesep);
            subName = files{i_sub_p}(k(end)+1:end);
            subName = subName(filePos(1):end-filePos(2)); % get the Subject Name;
            fNames=fieldnames(FileCont);    % Get the field names of the Subject Content (P Matrix, R Matrix etc. )
            
            if(~isfield(FileCont,MatrixName))   % The requested Matrix
                error(['The field "' MatrixName '" has not been found: ' ]);
            end
            
            is_dyn_p = 0;
            if isfield(FileCont,'is_dyn')
                is_dyn_p = FileCont.is_dyn;
            end
            
            n_gyn_p = 1;
            if(is_dyn_p == 1)
                n_gyn_p = size(FileCont.(MatrixName), 2);
            end
            fNames=fNames(~cellfun(@isempty, strfind(fNames, 'Matrix'))); % filter is_dyn and other non-Matrix fields
            
            for i = 1:nShuffelRandom        % i-Random Subjects
                actTask.newCycle([' ' num2str((i_sub_p-1) * nShuffelRandom + i) ' of ' num2str(nSub*nShuffelRandom)]);
                
                Out = struct();
                Out.is_dyn = is_dyn_p;
                
                for i_dyn = 1:n_gyn_p
                    if(is_dyn_p)
                        R = FileCont.(MatrixName){i_dyn};
                    else
                        R = FileCont.(MatrixName);
                    end
                    
                    mSize = size(R); % Matrix Size
                    
                    if (mSize(1) ~= mSize(2))
                        error('Matrix is not quadratic');
                    end
                    
                    for j = 1:length(fNames)    % with j-matrices each
                        try
                            randFuncHandle = str2func(random_shuffle_calc{:});
                            randM = randFuncHandle(R,randomRawIter);
                        catch err
                            if(GraphVarError(err))
                                continue;
                            else
                                rethrow(err);
                            end
                        end
                        
                        if(is_dyn_p)
                            Out.(fNames{j}){i_dyn} = randM;
                        else
                            Out.(fNames{j}) = randM;
                        end
                    end
                end
                shuffelFiles{i,i_sub_p} = [result_path filesep 'RandomizedShuffel' filesep 'Shuffel_' subName '_'  num2str(i,'%06d')  '.mat'];
                
                disp(['Created shuffled subject ' num2str(i_sub_p) ' iteration ' num2str(i)])
                saveShuffled(shuffelFiles{i,i_sub_p}, Out);
            end
        end
    else
        for i_sub=1:nSub
            %% STD SUBJECT LOAD PROCEDURE
            FileCont = load (files{i_sub});     % Load a Subject
            k = strfind(files{i_sub}, filesep);
            subName = files{i_sub}(k(end)+1:end);
            subName = subName(filePos(1):end-filePos(2)); % get the Subject Name;
            fNames=fieldnames(FileCont);    % Get the field names of the Subject Content (P Matrix, R Matrix etc. )
            
            if(~isfield(FileCont,MatrixName))   % The requested Matrix
                error(['The field "' MatrixName '" has not been found: ' ]);
            end
            
            names = fieldnames(FileCont);
            idx = find(strcmp(names,'is_dyn'), 1);
            if ~isempty(idx) && FileCont.is_dyn == 1
                is_dyn = 1;
            else
                is_dyn = 0;
            end
            
            if ~isempty(idx)
                fNames(idx) = [];
            end
            
            if(is_dyn == 1)
                n_dyn = size(FileCont.(MatrixName), 2);
                fNames=fNames(~cellfun(@isempty, strfind(fNames, 'Matrix'))); % filter is_dyn and other non-Matrix fields
            else
                n_dyn = 1;
            end
            
            for i = 1:nShuffelRandom        % i-Random Subjects
                actTask.newCycle([' ' num2str((i_sub-1) * nShuffelRandom + i) ' of ' num2str(nSub*nShuffelRandom)]);
                
                if(~running)
                    res = 0;
                    return;
                end
                
                Out = struct();
                Out.is_dyn = is_dyn;
                
                for i_dyn = 1:n_dyn
                    if(is_dyn)
                        R = FileCont.(MatrixName){i_dyn};
                    else
                        R = FileCont.(MatrixName);
                    end
                    
                    mSize = size(R); % Matrix Size
                    
                    if (mSize(1) ~= mSize(2))
                        error('Matrix is not quadratic');
                    end
                    
                    for j = 1:length(fNames)    % with j-matrices each
                        try
                            randM = eval([random_shuffle_calc{:} '(R,randomRawIter)']); 
                        catch err
                            if(GraphVarError(err))
                                continue;
                            else
                                rethrow(err);
                            end
                        end
                        
                        if(is_dyn)
                            Out.(fNames{j}){i_dyn} = randM;
                        else
                            Out.(fNames{j}) = randM;
                        end
                    end
                end
                shuffelFiles{i,i_sub} = [result_path filesep 'RandomizedShuffel' filesep 'Shuffel_' subName '_'  num2str(i,'%06d')  '.mat'];
                save(shuffelFiles{i,i_sub},'-struct','Out');
            end
            
        end
        
    end
    
    if(~running)
        res = 0;
        return;
    end
end

%% ************************************************************************************
%% PART 2:
%% Do The Thresholding / Binarizer
if ~isempty(thresholds)
    threshTask = allTasks.getTask('Thresholds');     threshTask.start();
end

for threshold = thresholds
    tic
    typeTask = allTasks.getTask('Types');     typeTask.start();
    
    for type = types
        validSubID = 1;
        toDel = [];
        subTask = allTasks.getTask('Thresholding Subject');     subTask.start();
        
        for i_sub=1:nSub
            % ****************************
            % Check if Subject is in Excel
            % ****************************
            if(noCorr ~=1)
                k = strfind(files{i_sub}, filesep);
                
                ID_ = files{i_sub}(k(end)+filePos(1):end-filePos(2));
                if hasNumericalID
                    ID_ = str2double(ID_);
                end
                [~,loc1] = ismember(ID_, ID);
                if loc1 > 0               % Found in Excle Sheet so valid
                    loc(validSubID) = loc1;
                    validSubID = validSubID + 1;
                else                     % Not found delete
                    toDel = [toDel i_sub];
                end
            end
            
            % ****************************
            % Load Subject, delete not requested BrainAreas
            % ****************************
            FileCont = load (files{i_sub});
            if(~isfield(FileCont,MatrixName))
                error(['The field "' MatrixName '" has not been found: ' ]);
            end
            
            if isfield(FileCont,'is_dyn')
                is_dyn = FileCont.is_dyn;
            else
                is_dyn = 0;
            end
            
            
            if(is_dyn == 1)
                n_dyn = size(FileCont.(MatrixName),2);
            else
                n_dyn = 1;
            end
            
            for i_dyn = 1:n_dyn
                
                if(iscell(MatrixName))
                    MatrixName = MatrixName{:};
                end
                
                
                if(is_dyn)
                    R = FileCont.(MatrixName){i_dyn};
                else
                    R = FileCont.(MatrixName);
                end
                
                del = find(brain==0);
                R(del,:) = [];
                R(:,del) = [];
                
                
                
                % ****************************
                % Do the Threshholding
                % ****************************
                if(thresholdType == 1 )
                    W = threshold_proportional(R,threshold);
                elseif(thresholdType == 2)
                    W = threshold_absolute(R,threshold);
                elseif(thresholdType == 3)
                    if ~isfield(FileCont,pValueField)
                        errordlg('The PValue Matrix could not be found');
                        res = 0;
                        return;
                    end
                    FileCont.(pValueField)(del,:) = []; %% Delete Brain areas
                    FileCont.(pValueField)(:,del) = [];
                    W = R;
                    W(logical(FileCont.(pValueField)>threshold)) = 0;
                    n=size(W,1);                                %number of nodes
                    W(1:n+1:end)=0;                             %clear diagonal
                elseif(thresholdType == 4)
                    W = R;
                    n=size(W,1);                                %number of nodes
                    W(1:n+1:end)=0;                             %clear diagonal
                elseif(thresholdType == 5)
                    W = SICEDense(R,threshold);
                    
                end
                
                if(type == 1)
                    W(W~=0) = 1; %binarize
                else
                    
                    if weightAdjust_Thr == 1
                        W = abs(W);
                    elseif weightAdjust_Thr == 2
                        W(W<0) = 0;
                        
                    elseif ~isempty(W(W<0)) && continueWithNeg == 0
                        button = questdlg(['The density threshold of ' num2str(threshold) ' and subsequent densities contain negative weights. Do you want to continue'], 'Found negative Values', 'Continue', 'Cancel', 'Continue');
                        if strcmpi(button, 'Cancel')
                            res = 0;
                            return;
                        else
                            continueWithNeg = 1;
                        end
                        
                    end
                end
                VPData{i_sub,i_dyn} = W;
                
                subTask.newCycle([' ' num2str(i_sub) ' of ' num2str(nSub)]);
                clear W R;
            end % end dyn
        end % END Every Subject
        
        
        %% ************************************************************************************
        %% PART 3:
        %% USE Random Function to randomize already thresholded data
        %% Still in thresholds AND Type Loop
        ResultRand = cell(nSub, nRandom,n_dyn);
        if(doRandom && randomForType(type))
            randTask = allTasks.getTask('Randomize Subject');     randTask.start();
            
            if isParallel
                
                disp(repmat('#', 2, 60))
                disp([repmat('#', 1, 24) '  Progress  ' repmat('#', 1, 24)])
                disp([repmat('#', 1, 24) '  Display  ' repmat('#', 1, 25)])
                disp(repmat('#', 2, 60))
                disp('Press Ctrl-C to cancel. ')
                
                parfor i_sub=1:nSub
                    for i_dyn = 1:n_dyn
                        if(~checkGlobalRunning())
                            continue;
                        end
                        %TO BE REVIEWED WAIT WND
                        for i_random = 1:nRandom
                            % For every Subject do the selected random funciton
                            % i_random times
                            
                            try
                                randFuncHandle = str2func(randomFunction{:});
                                ResultRand{i_sub,i_random,i_dyn} = randFuncHandle(VPData{i_sub,i_dyn},randomIterations);
                            catch err
                                if(GraphVarError(err))
                                    continue;
                                else
                                    rethrow(err);
                                end
                            end
                            
                        end
                    end
                    disp(['Randomized Subject ' num2str(i_sub)])
                end % END EVERY SUBJECT
                
                
            else for i_sub=1:nSub
                    for i_dyn = 1:n_dyn
                        
                        %TO BE REVIEWED WAIT WND
                        for i_random = 1:nRandom
                            % For every Subject do the selected random funciton
                            % i_random times
                            
                            if(~running)
                                res = 0;
                                return;
                            end
                            
                            try
                                randFuncHandle = str2func(randomFunction{:});
                                ResultRand{i_sub,i_random,i_dyn} = randFuncHandle(VPData{i_sub,i_dyn},randomIterations);
                            catch err
                                if(GraphVarError(err))
                                    continue;
                                else
                                    rethrow(err);
                                end
                            end
                            
                            
                            randTask.newCycle([' ' num2str((i_sub-1)*nRandom+i_random) ' of ' num2str(nSub*nRandom)]);
                            
                        end
                    end %end dyn
                end % END EVERY SUBJECT
            end
            if(~running)
                res = 0;
                return;
            end
            
            for i_sub=1:nSub
                for i_dyn = 1:n_dyn
                    if(smallworldness&&nRandom>0)   % If we want smallworldnes do it with all the created random subs
                        if(type == 1)
                            ResultS{i_dyn,i_sub} = smallworldness_bu(VPData{i_sub},ResultRand(i_sub,:,i_dyn));
                        elseif(type == 2)
                            ResultS{i_dyn,i_sub} = smallworldness_wu(VPData{i_sub},ResultRand(i_sub,:,i_dyn));
                        end
                    end
                end
            end
            
            Result = ResultRand;
            Result(toDel,:) = [];
            save([result_path filesep 'GraphVars' filesep randomFunction{:} '_' num2str(threshold*10) '_' num2str(type) '.mat'], 'Result', '-v7.3')
            
            
            if (smallworldness&&nRandom>0)
                if(is_dyn)
                    Result = ResultS;
                    Result(toDel) = [];
                    if(type == 1)
                        save([result_path filesep 'GraphVars' filesep 'smallworldness_bu' '_' num2str(threshold*10) '_' num2str(type) '_per_SW.mat'],'Result', '-v7.3')
                    elseif(type == 2)
                        save([result_path filesep 'GraphVars' filesep 'smallworldness_wu' '_' num2str(threshold*10) '_' num2str(type) '_per_SW.mat'],'Result', '-v7.3')
                    end
                    
                    ResultS = cell2mat(reshape(ResultS, [1 1 size(ResultS)]));
                    if strcmp(DynamicGraphVar,'Select Dynamic')
                        button = questdlg('GraphVar detected dynamic input matrices but no dynamic summary measure was selected. Please select a dynamic measure.', 'Dynamic GraphVar','Cancel','Cancel');
                        if strcmpi(button, 'Cancel')
                            res = 0;
                            return;
                        end
                    elseif strcmp(DynamicGraphVar,'Variance over time')
                        Result = var(ResultS, [], 3);
                    elseif strcmp(DynamicGraphVar,'Standard Deviation')
                        Result = std(ResultS, [], 3);
                    elseif strcmp(DynamicGraphVar,'Periodicity')
                        Result = multidimfunc('periodicity',ResultS, 3);
                    elseif strcmp(DynamicGraphVar,'PointProcess: rate')
                        Result = multidimfunc('point_process_rate',ResultS, 3);
                    elseif strcmp(DynamicGraphVar,'PointProcess: interval')
                        Result = multidimfunc('point_process_interval',ResultS, 3);
                    elseif strcmp(DynamicGraphVar,'Dynamic community flexibility: only with MULTISLICE affiliation vector')
                        button = questdlg('It is not possible to use this dynamic measure with small worldness.', 'Dynamic GraphVar','Cancel','Cancel');
                        if strcmpi(button, 'Cancel')
                            res = 0;
                            return;
                        end
                    elseif strcmp(DynamicGraphVar,'Dynamic community promiscuity: only with MULTISLICE affiliation vector')
                        button = questdlg('It is not possible to use this dynamic measure with small worldness.', 'Dynamic GraphVar','Cancel','Cancel');
                        if strcmpi(button, 'Cancel')
                            res = 0;
                            return;
                        end
                    end
                    Result = reshape(Result, [size(Result, 1) size(Result, 2) size(Result, 4)]);
                    Result = squeeze(mat2cell(Result, size(Result, 1), size(Result, 2), ones(1, size(Result, 3))))';
                else
                    Result = ResultS;
                end
                Result(toDel) = [];
                if(type == 1)
                    save([result_path filesep 'GraphVars' filesep 'smallworldness_bu' '_' num2str(threshold*10) '_' num2str(type) '.mat'],'Result', '-v7.3')
                elseif (type == 2)
                    save([result_path filesep 'GraphVars' filesep 'smallworldness_wu' '_' num2str(threshold*10) '_' num2str(type) '.mat'],'Result', '-v7.3')
                end
            end
        end
        
        %% ************************************************************************************
        %% PART 4:
        %% DO THE NETWORK/GRAPH FUNCTION (incl. random)
        %% Still in thresholds AND Type Loop
        clear Result;   % Make sure no old Result is still in memory
        functionList = functions{type}; % Only Functions of the right Type
        graphTask = allTasks.getTask('Graph Function');     graphTask.start();
        for i_func = 1:size(functionList,1)
            graphTask.newCycle([' ' num2str(graphTask.actCycle+1) ' of ' num2str(graphTask.cycles)]);
            
            idx_1 = find(strcmp(functionList,'cost_efficiency_relative_bin'), 1);
            idx_2 = find(strcmp(functionList,'cost_efficiency_relative_wei'), 1);
            idx_ms = find(strcmp(functionList,'genlouvain_multislice'), 1);
            
            if ~isempty(ResultRand)
                extNSub = nSub + (nRandom*nSub);    % Add random subject to nSub *n_dyn
            else
                extNSub = nSub;
            end
            
            r_idx = 1;      % idx of random  within ONE subject
            i_extSub = 1;   % idx of subject (within there are many Random)
            
            subjectTask = allTasks.getTask('Subject');    subjectTask.cycles = extNSub; subjectTask.start();
            
            if 0     %bcteval(functionList{i_func})
                VPData_ = cell2mat(reshape(VPData, [1, 1, size(VPData)]));
                
                VPData_ = bsxfun(@times, VPData_, ~(eye(90)));
                Result_ = bcteval(functionList{i_func}, VPData_);
                for i_dyn = 1:n_dyn
                    for i_sub=1:nSub
                        Result{i_dyn,i_sub} = Result_(i_sub,i_dyn);
                    end
                end
                
                if ~isempty(ResultRand)
                    ResultRand_ = cell2mat(reshape(ResultRand, [1, 1, size(ResultRand)]));
                    ResultRandVar_ = bcteval(functionList{i_func}, ResultRand_);
                    for i_dyn = 1:n_dyn
                        for r_idx=1:nRandom
                            for i_sub=1:nSub
                                ResultRandVar{i_sub,r_idx,i_dyn} = ResultRandVar_(i_sub,r_idx,i_dyn);
                            end
                        end
                    end
                end
            else
                      
                %ResultMultiSubj = repmat(reshape(VPData, [size(VPData, 1) 1 size(VPData, 2)]), [1 n_multiply 1]);

                for i_sub=1:extNSub % For every Subject including Random
                    %TO BE REVIEWED WAIT WND


                    %% compute multislice community assignment functions one iteration
                    if ~isempty(idx_ms) && idx_ms ==  i_func   % If org. Subj
                        if (i_sub <= nSub) && n_multiply < 2
                            multislice_community_assignment{:,i_sub} = genlouvain_multislice((VPData{i_sub,:}));
                            Result(:,i_sub) = mat2cell(multislice_community_assignment{:,i_sub},ones(1,n_dyn));
                        elseif (i_sub <= nSub) && n_multiply > 1
                            for i_multiply= 1:n_multiply
                                multislice_community_assignment{i_sub,i_multiply,:} = genlouvain_multislice((VPData{i_sub,:}));
                                ResultMultiVar(i_sub,i_multiply,:) = mat2cell(multislice_community_assignment{i_sub,i_multiply,:},ones(1,n_dyn));
                            end

                        else % If rand sub
                            r_idx = idivide(int16(i_sub - 1), nSub);
                            i_extSub = mod(i_sub - 1, nSub) + 1;
                            ResultRandVar(i_extSub,r_idx,:) = mat2cell(genlouvain_multislice((ResultRand{i_extSub,r_idx,:})),ones(1,n_dyn));

                            multislice_community_assignment_random{i_extSub,r_idx,:} = genlouvain_multislice((ResultRand{i_extSub,r_idx,:}));
                            ResultRandVar(i_extSub,r_idx,:) = mat2cell(multislice_community_assignment_random{i_extSub,r_idx,:},ones(1,n_dyn));
                        end
                    end

                    %% compute regular functions
                    for i_dyn = 1:n_dyn
                        if(i_sub <= nSub)   % If org. Subj
                            if ~isempty(idx_1) && idx_1 ==  i_func
                                Result{i_dyn,i_sub} = cost_efficiency_relative_bin((VPData{i_sub,i_dyn}),threshold);
                            elseif ~isempty(idx_2) && idx_2 ==  i_func
                                Result{i_dyn,i_sub} = cost_efficiency_relative_wei((VPData{i_sub,i_dyn}),threshold);
                            elseif ~isempty(idx_ms) && idx_ms ==  i_func
                                multislice = 1;
                            else
                                try
                                    Result{i_dyn,i_sub} = eval([functionList{i_func} '(VPData{i_sub,i_dyn})']);
                                catch err
                                    if(GraphVarError(err))
                                        continue;
                                    else
                                        rethrow(err);
                                    end
                                end
                            end

                        else  % If rand sub

                            r_idx = idivide(int16(i_sub - 1), nSub);
                            i_extSub = mod(i_sub - 1, nSub) + 1;

                            if ~isempty(idx_1) && idx_1 ==  i_func
                                ResultRandVar{i_extSub,r_idx,i_dyn} = cost_efficiency_relative_bin((ResultRand{i_extSub,r_idx,i_dyn}),threshold);
                            elseif ~isempty(idx_2) && idx_2 ==  i_func
                                ResultRandVar{i_extSub,r_idx,i_dyn} = cost_efficiency_relative_wei((ResultRand{i_extSub,r_idx,i_dyn}),threshold);
                            elseif ~isempty(idx_ms) && idx_ms ==  i_func
                                multislice = 1;
                            else
                                try
                                    ResultRandVar{i_extSub,r_idx,i_dyn} = eval([functionList{i_func} '(ResultRand{i_extSub,r_idx,i_dyn})']);
                                catch err
                                    if(GraphVarError(err))
                                        continue;
                                    else
                                        rethrow(err);
                                    end
                                end
                            end
                        end

                        %TO BE REVIEWED WAIT WND
                        if(~running)
                            res = 0;
                            return;
                        end
                        subjectTask.newCycle([' ' num2str(i_sub) ' of ' num2str(extNSub)]);

                    end %dyn
                end % End Every Subject including Random
            end
            
            %% Normalize the graph measure of the original data with the mean of the same measure derived in random data
            if(normalize && ~isempty(ResultRand) && multislice ~= 1)
                dim = ndims(ResultRandVar(1,1));          %# Get the number of dimensions for your arrays
                for i_dyn = 1:n_dyn
                    for i = 1:size(Result,2)
                        M = cat(dim+1,ResultRandVar{i,:,i_dyn});
                        if any(mean(M,dim+1) == 0)
                            button = questdlg('Normalization error: some metrics derived from random networks result in zero which cannot be used for normalization.', 'Normalization Error','Cancel','Cancel');
                            if strcmpi(button, 'Cancel')
                                res = 0;
                                return;
                            end
                        end
                        Result{i_dyn,i} = Result{i_dyn,i}./mean(M,dim+1);
                    end
                end
            end
            
            if(n_multiply < 2)
                Result_tmp = Result;
            end
            
            %% save TxN matrix with the multislice modular assignments of orig. subjects and random networks
            if (multislice ~= 0)
                multislice_community_assignment(toDel) = [];
                save([result_path filesep 'GraphVars' filesep 'multislice_community_assignment_slicesXnodes_' num2str(threshold*10) '_' num2str(type) '.mat'],'multislice_community_assignment')
                if ~isempty(ResultRand)
                    multislice_community_assignment_random(toDel) = [];
                    save([result_path filesep 'GraphVars' filesep 'multislice_community_assignment_slicesXnodes_' num2str(threshold*10) '_' num2str(type) '-rand.mat'],'multislice_community_assignment_random')
                end
            end
            
            %% if dynamic: save the Result of every graph measure from the orig and random data per sliding window
            if(is_dyn) && multislice ~= 1
                Result(toDel) = [];
                save([result_path filesep 'GraphVars' filesep functionList{i_func} '_' num2str(threshold*10) '_' num2str(type) 'per_SW.mat'],'Result', '-v7.3')
                if ~isempty(ResultRand)
                    Result = ResultRandVar;
                    Result(toDel) = [];
                    save([result_path filesep 'GraphVars' filesep functionList{i_func} '_' num2str(threshold*10) '_' num2str(type) '-rand_per_SW.mat'],'Result', '-v7.3')
                end
                if(~running)
                    res = 0;
                    return;
                end
            elseif (~is_dyn) && multislice ~= 1
                %% if NOT dynamic: save the Result of every graph measure from the orig and random data
                Result(toDel) = [];
                save([result_path filesep 'GraphVars' filesep functionList{i_func} '_' num2str(threshold*10) '_' num2str(type) '.mat'],'Result', '-v7.3')
                if ~isempty(ResultRand)
                    for i_rand = 1:nRandom
                        Result = ResultRandVar(:,i_rand);
                        Result(toDel) = [];
                        Result = rot90(Result,1);
                        save([result_path filesep 'GraphVars' filesep functionList{i_func} '_' num2str(threshold*10) '_' num2str(type) '-rand' num2str(i_rand) '.mat'],'Result', '-v7.3')
                    end
                end
                if(~running)
                    res = 0;
                    return;
                end
            end
            
            if(is_dyn)
                %% Compute VARIANCE or OTHER dynamic summary measure to concatinate info of sliding windows
                if n_multiply < 2
                    Result = Result_tmp; % Result_tmp is the graph measure derived and saved above from the original data per sliding window
                    Result = cell2mat(reshape(Result, [1 1 size(Result)]));
                    
                    
                    if strcmp(DynamicGraphVar,'Select Dynamic')
                        button = questdlg('GraphVar detected dynamic input matrices but no dynamic summary measure was selected. Please select a dynamic measure.', 'Dynamic GraphVar','Cancel','Cancel');
                        if strcmpi(button, 'Cancel')
                            res = 0;
                            return;
                        end
                    elseif strcmp(DynamicGraphVar,'Variance over time')
                        Result = var(Result, [], 3);
                    elseif strcmp(DynamicGraphVar,'Standard Deviation')
                        Result = std(Result, [], 3);
                    elseif strcmp(DynamicGraphVar,'Periodicity')
                        Result = multidimfunc('periodicity',Result, 3);
                    elseif strcmp(DynamicGraphVar,'PointProcess: rate')
                        Result = multidimfunc('point_process_rate',Result, 3);
                    elseif strcmp(DynamicGraphVar,'PointProcess: interval')
                        Result = multidimfunc('point_process_interval',Result, 3);
                    elseif strcmp(DynamicGraphVar,'Dynamic community flexibility: only with MULTISLICE affiliation vector')
                        if isempty(idx_ms) || idx_ms > 1
                            button = questdlg('Please select the graph metric "MULTISLICE Louvian - affiliation vector" with this dynamic measure to derive the nodal flexibiltiy coefficient.', 'Dynamic GraphVar','Cancel','Cancel');
                            if strcmpi(button, 'Cancel')
                                res = 0;
                                return;
                            end
                        else
                            Result = multidimfunc('flexibility_help',Result, 3);
                        end
                    elseif strcmp(DynamicGraphVar,'Dynamic community promiscuity: only with MULTISLICE affiliation vector')
                        if isempty(idx_ms) || idx_ms > 1
                            button = questdlg('Please select the graph metric "MULTISLICE Louvian - affiliation vector" with this dynamic measure to derive the nodal promiscuity coefficient.', 'Dynamic GraphVar','Cancel','Cancel');
                            if strcmpi(button, 'Cancel')
                                res = 0;
                                return;
                            end
                        else
                            Result = multidimfunc_multislice('promiscuity_help',Result, 3, threshold, InterimResult_num);
                        end
                    end
                    
                    Result = reshape(Result, [size(Result, 1) size(Result, 2) size(Result, 4)]);
                    Result = squeeze(mat2cell(Result, size(Result, 1), size(Result, 2), ones(1, size(Result, 3))))';
                    
                elseif n_multiply > 1
                    tmpSize = size(ResultMultiVar, 2);
                    ResultMultiVar = cell2mat(reshape(ResultMultiVar, [1 1 size(ResultMultiVar)]));
                    if strcmp(DynamicGraphVar,'Dynamic community flexibility: only with MULTISLICE affiliation vector')
                        ResultMultiVar = multidimfunc('flexibility_help',ResultMultiVar, 5);
                    elseif strcmp(DynamicGraphVar,'Dynamic community promiscuity: only with MULTISLICE affiliation vector')
                        ResultMultiVar = multidimfunc_multislice('promiscuity_help',ResultMultiVar, 5, threshold, InterimResult_num);
                    end
                    
                    Result = mean(squeeze(ResultMultiVar),3);
                    Result = mat2cell(Result',ones(1,size(Result,2)),size(Result,1))';
               
                    
                end
                
                
                
                if(i_sub > nSub)
                    tmpSize = size(ResultRandVar, 2);
                    ResultRandVar = cell2mat(reshape(ResultRandVar, [1 1 size(ResultRandVar)]));
                    
                    if  strcmp(DynamicGraphVar,'Variance over time')
                        ResultRandVar = var(ResultRandVar, [], 5);
                    elseif strcmp(DynamicGraphVar,'Standard Deviation')
                        ResultRandVar = std(ResultRandVar, [], 5);
                    elseif strcmp(DynamicGraphVar,'Periodicity')
                        ResultRandVar = multidimfunc('periodicity',ResultRandVar, 5);
                    elseif strcmp(DynamicGraphVar,'PointProcess: rate')
                        ResultRandVar = multidimfunc('point_process_rate',ResultRandVar, 5);
                    elseif strcmp(DynamicGraphVar,'PointProcess: interval')
                        ResultRandVar = multidimfunc('point_process_interval',ResultRandVar, 5);
                    elseif strcmp(DynamicGraphVar,'Dynamic community flexibility: only with MULTISLICE affiliation vector')
                        ResultRandVar = multidimfunc('flexibility_help',ResultRandVar, 5);
                    elseif strcmp(DynamicGraphVar,'Dynamic community promiscuity: only with MULTISLICE affiliation vector')
                        ResultRandVar = multidimfunc_multislice('promiscuity_help',ResultRandVar, 5, threshold, InterimResult_num,1);
                    end
                    
                    ResultRandVar = squeeze(mat2cell(ResultRandVar, size(ResultRandVar, 1), size(ResultRandVar, 2),repmat(1, 1, size(ResultRandVar, 3)),repmat(1, 1, size(ResultRandVar, 4))));
                end
                
                %% IF results from MULTISLICE AFFILIATION VECTOR: Normalize the graph measure of the original data with the mean of the same measure derived in random data
                if(normalize && ~isempty(ResultRand) && multislice ~= 0)
                    dim = ndims(ResultRandVar(1,1));
                    
                    %                     if n_multiply > 1
                    %                         %#### AVERAGE OF ResultMultiVar: here = Result
                    %                     end
                    
                   for i = 1:size(Result,2)
                            M = cat(dim+1,ResultRandVar{i,:}); %%% DIMENSIONS DO NOT MATCH WITH MULTISLICE !!!!!!!!!!!!!!!!!!!!!!
                            Result{1,i} = Result{1,i}./mean(M,dim+1);
                   end
                end
                
                %% Save the dynamic summary measure of every orig and Random
                Result(toDel) = [];
                save([result_path filesep 'GraphVars' filesep functionList{i_func} '_' num2str(threshold*10) '_' num2str(type) '.mat'],'Result', '-v7.3')
                if ~isempty(ResultRand)
                    for i_rand = 1:nRandom
                        Result = ResultRandVar(:,i_rand);
                        Result(toDel) = [];
                        Result = rot90(Result,1);
                        save([result_path filesep 'GraphVars' filesep functionList{i_func} '_' num2str(threshold*10) '_' num2str(type) '-rand' num2str(i_rand) '.mat'],'Result', '-v7.3')
                    end
                end
                if(~running)
                    res = 0;
                    return;
                end
                
            end % End Dynamic Summary Measure
        end % End Functions
        
        clear Result ResultRandVar ResultS ResultMultiVar;
        typeTask.newCycle([' ' num2str(type) ' of ' num2str(2)]);
        
    end % End Type
    
    threshTask.newCycle([' ' num2str(find(thresholds == threshold)) ' of ' num2str(length(thresholds))]);
end
save([result_path filesep 'Settings.mat'],'loc')

res = 1;