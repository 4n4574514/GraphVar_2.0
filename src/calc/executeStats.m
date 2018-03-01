%  This file is part of GraphVar.
% 
%  Copyright (C) 2016 Lea Waller 
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

function [FileNames, LAB, N] ...
    = executeStats(allTasks, ...
                   functionList, thresholds, ...
                   Covariates, BetweenFactors, WithinID, WithinCovariates, NuisanceCovariates, AdditonalMLPredictors, ...
                   Interactions, ...
                   testTypeGraph, testTypeNetwork, testTypeML, nRandom, nRawRandom, nGraphRandom, ...
                   ConnectivityThr, ...
                   doML, doFeatSel, FeatSelThres, doHyperOpt, nHyperOptSteps, ...
                   modelType, nCVFolds, ...
                   Outcome, ...
                   doManual, mpar1, mpar2)

global workspacePath;
global running;  
global InterimResultsID;
global fid;

% LOAD WORKSPACE INFO
Workspace = load(fullfile(workspacePath,'Workspace.mat'));
[~, variableSheet] =  abs_rel_correct(Workspace.brainSheet, Workspace.variableSheet);

resultsPath = [workspacePath filesep 'results'];

loc = load([resultsPath filesep InterimResultsID filesep 'Settings.mat']);
loc = loc.loc;    %somehow this adds NeoData

dateTime = now;
logfile = [resultsPath filesep 'CorrResults' filesep 'Log' datestr(dateTime,'dd-mm-yyyy-HH-MM-SS') '.txt'];
fid = fopen(logfile,'w');

ImportSettings = load([workspacePath filesep 'ImportSettings.mat']);
userVar = ImportSettings.userVar;

fprintf(fid, 'Log created %s\r\n', datestr(dateTime, 'dd-mm-yyyy HH:MM:SS') );

NeoData = importSpreadsheet(variableSheet);
VariablesList = NeoData(1, :);
subjectList = NeoData(loc + 1, userVar); % 
NeoData = NeoData(loc + 1, :);


if doML
    actTask = allTasks.getTask('SVM');     actTask.start();
    actTask.contents
    
else
    actTask = allTasks.getTask('GLM');     actTask.start();
end

inputPath = fullfile(resultsPath, InterimResultsID, 'GraphVars');

% Prepare

N = 0;
LAB = {};

if doML
    RES = [];
    for i = 1:length(Outcome)
        IND = ismember(VariablesList, Outcome{i});
        RES = [RES find(IND)];
        LAB = [LAB VariablesList{IND}];
    end

    ACOV = [];
    for i = 1:length(AdditonalMLPredictors)
        IND = ismember(VariablesList, AdditonalMLPredictors{i});
        ACOV = [ACOV find(IND)];
        LAB = [LAB VariablesList{IND}];
    end
    
    NCOV = [];
    for i = 1:length(NuisanceCovariates)
        IND = ismember(VariablesList, NuisanceCovariates{i});
        NCOV = [NCOV find(IND)];
        LAB = [LAB VariablesList{IND}];
    end
else
    
    NCOV = [];
    for i = 1:length(NuisanceCovariates)
        IND = ismember(VariablesList, NuisanceCovariates{i});
        NCOV = [NCOV find(IND)];
    end

    COV = [];
    for i = 1:length(Covariates)
        IND = ismember(VariablesList, Covariates{i});
        COV = [COV find(IND)];
        LAB = [LAB VariablesList{IND}];
    end

    WCOV = [];
    for i = 1:length(WithinCovariates)
        IND = ismember(VariablesList, WithinCovariates{i});
        WCOV = [WCOV find(IND)];
        LAB = [LAB VariablesList{IND}];
    end

    BFAC = [];
    for i = 1:length(BetweenFactors)
        IND = ismember(VariablesList, BetweenFactors{i});
        BFAC = [BFAC find(IND)];
        LAB = [LAB VariablesList{IND}];
    end

    WID = [];
    if ~isempty(WithinID)
        IND = ismember(VariablesList, WithinID);
        WID = find(IND);
    end
    
    INT = Interactions;
    
    [PFUN, RFUN, NFUN, ...
        LAB, LLAB, LLEV, LASSIGN, LTYPE, ...
        MMEANS, J, N, DDF] = ...
            graphvar_glm(NeoData, NCOV, WID, WCOV, COV, BFAC, INT, LAB);
end


% Run model
if isempty(thresholds)
    thresholds = 0;
end

YY = cell(numel(thresholds), 1);
if isempty(YY)
    YY = cell(1, 1);
end
YYLAB = cell(numel(thresholds), 1);

MEMLIMIT = 1e8 / 8;

FileNames = {};
iiFunc = 0;

for type = 1:4
    Y = [];
    aFunc = [];
    aThres = [];
    
    functionList_ = functionList{type};
    
    if ~isempty(functionList_)   
        nRandom_ = 1;
        if type == 3                                               %raw mat
            thresholds_ = ConnectivityThr;
            
            randPrefix = '_rand_';
            suffix = '';
            
            testType = testTypeNetwork(5:end);
            
            Network = load(fullfile(inputPath, 'MatrixSize-Network.mat'));
            ISHALF = Network.isHalf;
            
            nRandom_ = min(nRawRandom, nRandom);
        elseif type == 4
            thresholds_ = ConnectivityThr;
            suffix = '';
            testType = testTypeNetwork(5:end);
            randPrefix = '_rand_';
            nRandom_ = min(nRawRandom, nRandom);
            ISHALF = 0;
        else
            thresholds_ = thresholds * 10;
            suffix = ['_' num2str(type)];
            testType = testTypeGraph(7:end);
            randPrefix = '-rand';
            nRandom_ = min(nGraphRandom, nRandom);
            ISHALF = 0;
        end
        
        switch testType
            case 'permutation'
                nRandom_ = nRandom;
            case 'randNW'
                nRandom_ = max(nRandom_, 1);
        end
        
        if doML % ML case 
        else
            funcTask = allTasks.getTask('Variable'); 
            funcTask.cycles = length(functionList_);
            funcTask.start();
        end
        
        for iFunc = 1:length(functionList_)
            
            if doML % ML case 
            else
                funcTask.newCycle([' ' num2str(iFunc) ' of ' num2str(funcTask.cycles)]);
                thresTask = allTasks.getTask('Threshold'); 
                thresTask.cycles = length(thresholds_);
                thresTask.start();
            end
            
            iiFunc = [iiFunc iiFunc(end) + 1];
            for iThreshold = 1:length(thresholds_)
                
                if doML % ML case 
                else
                    thresTask.newCycle([' ' num2str(iThreshold) ' of ' num2str(thresTask.cycles)]);
                end
                
                thresholdStr = num2str(thresholds_(iThreshold)); 

                GraphVar = load(fullfile(inputPath, [functionList_{iFunc} '_' thresholdStr suffix '.mat']));
                DAT = GraphVar.Result;

                Y_ = reshape(cat(3, DAT{:}), [], numel(DAT))';
                    
                if type == 3  
                    YSZ_ = Network.matrix_size;
                else
                    YSZ_ = size(DAT{1});
                end
                
                if doML   % ML case 
                    if type < 3
                        YY{iThreshold} = cat(2, YY{iThreshold}, Y_);
                    else
                        if isempty(thresholds)
                            YY{1} = cat(2, YY{1}, Y_);
                        else
                            for jThreshold = 1:numel(thresholds)
                                YY{jThreshold} = cat(2, YY{jThreshold}, Y_);
                            end
                        end
                    end
                                
                   
                   YYLAB{iThreshold} = [YYLAB{iThreshold} ...
                        arrayfun(@(p) strcat(functionList_{iFunc}, '_', num2str(p)), 1:size(Y_, 2), 'UniformOutput', 0)];
                    
                else   % GLM case
                    if strcmp(testType, 'randNW') || strcmp(testType, 'permutation')
                        CS = ceil(MEMLIMIT / size(Y_, 1) / nRandom_);
                        NC = ceil(size(Y_, 2) / CS);
                        CHUNKS = reshape(1:(NC * CS), CS, []);

                        P  = zeros(numel(LASSIGN), size(Y_, 2));
                        NP = zeros(numel(LASSIGN), size(Y_, 2));

                        F  = zeros(numel(LASSIGN), size(Y_, 2));
                        NF = zeros(numel(LASSIGN), size(Y_, 2), nRandom_);

                        B  = zeros(numel(LASSIGN), size(Y_, 2));
                        NB = zeros(numel(LASSIGN), size(Y_, 2), nRandom_);
                        
                        SE = zeros(numel(LASSIGN), size(Y_, 2));

                        chunkTask = allTasks.getTask('Chunk');     
                        chunkTask.cycles = NC;
                        chunkTask.start();

                        for iChunk  = 1:NC
                            CHUNK = CHUNKS(:, iChunk);
                            CHUNK = CHUNK(CHUNK <= size(Y_, 2));

                            chunkTask.newCycle([' ' num2str(iChunk) ' of ' num2str(chunkTask.cycles)]);

                            switch testType
                                case 'permutation'
                                    [P(:, CHUNK), ...
                                     NP(:, CHUNK), ...
                                     F(:, CHUNK), ...
                                     NF(:, CHUNK, :), ...
                                     B(:, CHUNK), ...
                                     NB(:, CHUNK, :), ...
                                     SE(:, CHUNK)] = RFUN(Y_(:, CHUNK), nRandom_);
                                case 'randNW'
                                    YR = cat(3, Y_(:, CHUNK), zeros([size(Y_(:, CHUNK)), nRandom_]));
                                    for iRandomize = 1:nRandom_
                                        GraphVar = load(fullfile(inputPath, ...
                                            [functionList_{iFunc} '_' thresholdStr suffix ...
                                             randPrefix num2str(iRandomize) '.mat']));
                                        DAT = GraphVar.Result;

                                        YR_ = reshape(cat(3, DAT{:}), [], numel(DAT))';
                                        YR(:, :, iRandomize + 1) = YR_(:, CHUNK);
                                    end

                                    [P(:, CHUNK), ...
                                     NP(:, CHUNK), ...
                                     F(:, CHUNK), ...
                                     NF(:, CHUNK, :), ...
                                     B(:, CHUNK), ...
                                     NB(:, CHUNK, :), ...
                                     SE(:, CHUNK)] = NFUN(YR);
                            end
                        end

                        P = SHAPE(P);
                        NP = SHAPE(NP);

                        F = SHAPE(F);
                        NF = SHAPE(NF);

                        B = SHAPE(B);
                        NB = SHAPE(NB);
                        
                        SE = SHAPE(SE);

                        WRITE(iThreshold, iiFunc(end), functionList_{iFunc}, ...
                            P, NP, F, NF, B, NB, SE);
                        iiFunc = iiFunc(end);
                    else
                        Y = cat(2, Y, Y_);
                        YSZ{iFunc, iThreshold} = YSZ_;

                        aFunc = [aFunc repmat(iFunc, 1, size(Y_, 2))];
                        aThres = [aThres repmat(iThreshold, 1, size(Y_, 2))];

                        if numel(Y) > MEMLIMIT || ...
                                (iFunc == length(functionList_) && iThreshold == length(thresholds_))

                            [P, F, B, SE] = PFUN(Y);

                            for i = unique(aFunc)
                                for j = unique(aThres)
                                    IND = aFunc == i & aThres == j;

                                    if any(IND)
                                        YSZ_ = YSZ{i, j};

                                        P_ = SHAPE(P(:, IND));
                                        F_ = SHAPE(F(:, IND));
                                        B_ = SHAPE(B(:, IND));
                                        SE_ = SHAPE(SE(:, IND));

                                        STAT = B_;
                                        STAT(:, :, J > 1) = F_(:, :, J > 1);

                                        WRITE(j, iiFunc(i + 1), functionList_{i}, ...
                                            P_, [], F_, [], B_, [], SE_);
                                    end
                                end
                            end

                            Y = [];
                            YSZ = {};
                            aFunc = [];
                            iiFunc = iiFunc(end);
                            aThres = [];
                        end
                    end
                end
            end
        end
    end
end

% save ML results
if doML
    if strcmp(testTypeML, 'do_ml_parametric')
        nRandom = 0;
    end

var_case = isempty(loc);       % define variable only case to fetch features from sheet 
if var_case == 1                 % variables only  
     NeoData = importSpreadsheet(variableSheet);
     NeoData =  NeoData(2:end, :);
end   

% set var_case as a conditional for no thresholds  
var_case = isempty(loc) ||  (~any(thresholds) && ~isempty(ConnectivityThr));


% multiple outcome cue 
% multiple outcome cue 
for iY = 1:length(Outcome)                                                 % check transmitted dimensions PP and NP, R
    RES_ = RES (iY);
    
     if any(regexp(modelType, 'classification$'))         
%            
               if ~var_case
                   if ~isempty(NCOV)  

            % conversion from cell to char is not possible (handedness)            
                       
                       [Y(:, :, iY), YPRED(:, :, iY), YNPRED(:, iY), YLAB(:, iY), YPRED_(:, :, iY), YNPRED_(:, iY), ...
            ACC_NP(:,:, :, iY), AUC_NP(:,:, :, iY), ACC_NP2, AUC_NP2, ...
            ACC_NPN(:, iY), AUC_NPN(:, iY), AUC_NPN2, ACC_NPN2, ...
            ACC(:, :, iY), AUC(:, :, iY), ACC2, AUC2, ACC_N(:, iY), AUC_N(:, iY), ...
            R(:, :, iY), RR(:, :, :, iY), RR2(:, :, iY), RC(:, iY), RRC, ...
            PP(:, :, iY), NP(:, :, iY), PPC, NPC, ...
            W(:, :, iY), NPW(:, :, iY), PWF(:, :,  iY) ,  YYLAB_, NXLAB] = ...
                      graphvar_ml(allTasks, NeoData, RES_, ACOV, NCOV, LAB, YY, YYLAB, ...
                    var_case, modelType, nCVFolds, nRandom, ...
                    doFeatSel, FeatSelThres, doHyperOpt, nHyperOptSteps, doManual, mpar1, mpar2, Outcome);
                
                   else %no nuisance 
                  [Y(:, :, iY), YPRED(:, :, iY), YNPRED, YLAB(:, iY), YPRED_(:, :, iY), YNPRED_, ...
            ACC_NP(:,:, :, iY), AUC_NP(:,:, :, iY), ACC_NP2, AUC_NP2, ...
            ACC_NPN, AUC_NPN, AUC_NPN2, ACC_NPN2, ...
            ACC(:, :, iY), AUC(:, :, iY), ACC2, AUC2, ACC_N, AUC_N, ...
            R(:, :, iY), RR(:, :, :, iY), RR2(:, :, iY), RC, RRC, ...
            PP, NP, PPC, NPC, ...
            W(:, :, iY), NPW(:, :, iY), PWF(:, :,  iY) ,  YYLAB_, NXLAB] = ...
                      graphvar_ml(allTasks, NeoData, RES_, ACOV, NCOV, LAB, YY, YYLAB, ...
                    var_case, modelType, nCVFolds, nRandom, ...
                    doFeatSel, FeatSelThres, doHyperOpt, nHyperOptSteps, doManual, mpar1, mpar2, Outcome);      
                           
                   end      
              
          else %var_case == 1 works
                       if ~isempty(NCOV)  
                        [Y(:, :, iY), YPRED(:, :,  iY), YNPRED(:, iY), YLAB(:, iY), YPRED_(:, :,iY), YNPRED_(:, iY), ...
                ACC_NP(:, :, iY), AUC_NP(:,:, iY), ACC_NP2(:, :, iY), AUC_NP2(:, :, iY), ...
                ACC_NPN(:, :, iY), AUC_NPN(:, :, iY), AUC_NPN2(:, :, iY), ACC_NPN2(:, :, iY), ...
                ACC(:, :, iY), AUC(:,:, iY), ACC2(:,:,  iY), AUC2(:, iY), ACC_N(:, iY), AUC_N(:, iY), ...
                R(:, :,  :, iY), RR(:, :, :, iY), RR2(:, :, iY), RC(:, iY), RRC(:, :, iY), ...
                PP, NP, PPC, NPC, ...
                W(:, :,  iY), NPW(:, :,  iY), PWF(:, :,  iY) ,  YYLAB_, NXLAB] = ...
                          graphvar_ml(allTasks, NeoData, RES_, ACOV, NCOV, LAB, YY, YYLAB, ...
                        var_case, modelType, nCVFolds, nRandom, ...
                        doFeatSel, FeatSelThres, doHyperOpt, nHyperOptSteps, doManual, mpar1, mpar2, Outcome);   
                       else%no nuisance
                           
                             [Y(:, iY), YPRED(:, iY), YNPRED, YLAB(:, iY), YPRED_(:,iY), YNPRED_, ...
                ACC_NP, AUC_NP, ACC_NP2(:,:, iY), AUC_NP2(:,:, iY), ...
                ACC_NPN, AUC_NPN, AUC_NPN2, ACC_NPN2, ...
                ACC, AUC, ACC2(:, iY), AUC2(:, iY), ACC_N, AUC_N, ...
                R(:, iY), RR(:, :, iY), RR2(:, :, iY), RC, RRC, ...
                PP, NP, PPC, NPC, ...
                W(:, iY), NPW(:, iY), PWF(:, iY) ,  YYLAB_, NXLAB] = ...
                          graphvar_ml(allTasks, NeoData, RES_, ACOV, NCOV, LAB, YY, YYLAB, ...
                        var_case, modelType, nCVFolds, nRandom, ...
                        doFeatSel, FeatSelThres, doHyperOpt, nHyperOptSteps, doManual, mpar1, mpar2, Outcome);

                       end       
              end 
       
     else %regression results
        if isempty(NCOV)
              [Y(:, iY), YPRED(:, :,  iY), YNPRED, YLAB, YPRED_, YNPRED_, ...
            ACC_NP, AUC_NP, ACC_NP2, AUC_NP2, ACC_NPN, AUC_NPN, AUC_NPN2, ACC_NPN2, ...
            ACC, AUC, ACC2, AUC2, ACC_N, AUC_N, ...
            R(:, :,  iY), RR(:, :, :, iY), RR2(:, :, iY), RC, RRC, ...
            PP(:, :,  iY), NP(:, :,  iY), PPC, NPC, ...
            W(:, :,  iY), NPW(:, :,  iY), PWF(:, :,  iY) ,  YYLAB_, NXLAB] = ...
                      graphvar_ml(allTasks, NeoData, RES_, ACOV, NCOV, LAB, YY, YYLAB, ...
                    var_case, modelType, nCVFolds, nRandom, ...
                    doFeatSel, FeatSelThres, doHyperOpt, nHyperOptSteps, doManual, mpar1, mpar2, Outcome); 
     else % nuisance case   
                   
            [Y(:, iY), YPRED(:, :,  iY), YNPRED(:, iY), YLAB, YPRED_, YNPRED_, ...
            ACC_NP, AUC_NP, ACC_NP2, AUC_NP2, ACC_NPN, AUC_NPN, AUC_NPN2, ACC_NPN2, ...
            ACC, AUC, ACC2, AUC2, ACC_N, AUC_N, ...
            R(:, :,  iY), RR(:, :, :, iY), RR2(:, :, iY), RC(:, iY), RRC(:, :, iY), ...
            PP(:, :,  iY), NP(:, :,  iY), PPC(:, :,  iY), NPC(:, :,  iY), ...
            W(:, :,  iY), NPW(:, :,  iY), PWF(:, :,  iY) ,  YYLAB_, NXLAB] = ...
                      graphvar_ml(allTasks, NeoData, RES_, ACOV, NCOV, LAB, YY, YYLAB, ...
                    var_case, modelType, nCVFolds, nRandom, ...
                    doFeatSel, FeatSelThres, doHyperOpt, nHyperOptSteps, doManual, mpar1, mpar2, Outcome)      
       end 
      end
end 




%% save Results if graph metrics in combo 
    if var_case == 0  

        for iThres = 1:numel(thresholds)
            ResultML = struct();
             if isempty(ConnectivityThr)
               ISHALF = [];
               else
               % keep as is
            end
        ResultML.isHalf= ISHALF; 

            ResultML.var_case = var_case;
            ResultML.modelType = modelType;
            ResultML.nCVFolds = nCVFolds;
            ResultML.nRandom = nRandom;
            ResultML.hasNCOV = ~isempty(NCOV);
           
            ResultML.XLAB = YYLAB_;  
            ResultML.NXLAB = NXLAB; 
            ResultML.YLAB = YLAB;
           
             ResultML.ACC =  ACC;
             ResultML.AUC  = AUC;
             ResultML.ACC_N = ACC_N;
             ResultML.AUC_N = AUC_N;

    %     permutation 
            ResultML.ACC_NP = ACC_NP;
            ResultML.AUC_NP = AUC_NP;
            ResultML.ACC_NPN = ACC_NPN;
            ResultML.AUC_NPN = AUC_NPN;

            ResultML.Outcome = Outcome;
            ResultML.Y = Y;
            ResultML.YPRED = YPRED; 
            ResultML.YNPRED = YNPRED; 
            ResultML.YPRED_ = YPRED_;
            ResultML.YNPRED_ = YNPRED_;

            ResultML.R = R;
            ResultML.RR = RR;
            ResultML.RC = RC;
            ResultML.RRC = RRC;


            ResultML.PP = PP;
            ResultML.NP = NP;

            ResultML.PPC = PPC;
            ResultML.NPC = NPC;
         
            ResultML.W = W;
            ResultML.NPW = NPW;
            ResultML.PWF = PWF;

               FileNames{iThres, 1, 1, 1} = ...
                ['ML' '_' ...
                 num2str(thresholds(iThres)) '.mat'];                                                        
            save(fullfile(resultsPath, 'CorrResults', ...
                FileNames{iThres, 1, 1, 1}), '-struct', 'ResultML');
        end

%% Save Results if VARIABLES only 
 elseif var_case == 1
        ResultML = struct();
        
        %same ML results..
        ResultML.var_case = var_case;
        ResultML.modelType = modelType;
        ResultML.nCVFolds = nCVFolds;
        ResultML.nRandom = nRandom;
        ResultML.hasNCOV = ~isempty(NCOV);

       
        ResultML.XLAB = YYLAB_;  
        ResultML.NXLAB = NXLAB; 
        ResultML.YLAB = YLAB;
        if isempty(ConnectivityThr)
           ISHALF = [];
           else
           % keep as is
        end
        ResultML.isHalf= ISHALF; 
        
         ResultML.ACC_N = ACC_N;
         ResultML.AUC_N = AUC_N;
         ResultML.ACC2 = ACC2; 
         ResultML.AUC2 = AUC2;

        %permutation 
        ResultML.ACC_NP2= ACC_NP2;
        ResultML.AUC_NP2= AUC_NP2;
        ResultML.ACC_NPN2= ACC_NPN2;
        ResultML.AUC_NPN2= AUC_NPN2;

        ResultML.XLAB = YYLAB;                  %result label 
        
        ResultML.Y = Y;
        ResultML.YPRED = YPRED;
        ResultML.YNPRED = YNPRED;
        
        ResultML.R = R;
        ResultML.PP = PP;
        ResultML.NP = NP;
  
        ResultML.Outcome = Outcome;
        ResultML.Y = Y; 
        ResultML.YPRED = YPRED; 
        ResultML.YNPRED = YNPRED; 
        ResultML.YPRED_ = YPRED_; 
        ResultML.YNPRED_ = YNPRED_; 
        
        ResultML.R = R;     
        ResultML.RC = RC; 
        ResultML.RR = RR2;  
        ResultML.RRC = RRC;                                
       
        ResultML.PP = PP;
        ResultML.NP = NP;
        ResultML.PPC = PPC;
        ResultML.NPC = NPC;
        
        ResultML.W = W;
        ResultML.NPW = NPW;
        ResultML.PWF = PWF;
         
         FileNames{1} = ...                                                  
            ['ML' '_' '.mat']; 
         
        save(fullfile(resultsPath, 'CorrResults', ...
            FileNames{1}), '-struct', 'ResultML');

    end
  end

%GLM PART 

function [P_] = SHAPE(P)                                              
    if ISHALF
        P_ = zeros([YSZ_ numel(LASSIGN) size(P, 3)]);
        for q = 1:numel(LASSIGN)
            
            for p = 1:size(P, 3)     
                PS = zeros(YSZ_);    
                PS(~triu(ones(size(P_, 1)))) = P(q, :, p);      
                
                PS = PS + PS';     

                P_(:, :, q, p) = PS;
            end
        end
    else
        P_ = reshape(tt(P), [YSZ_ numel(LASSIGN) size(P, 3)]);
    end
end


% save GLM results
function WRITE(iThres, iFunc, FUNC, ...
                P, NP, F, NF, B, NB, SE)
    for k = 1:LASSIGN(end)
        LAB_ = LAB{k};
        LAB_ = strrep(LAB_, '*', '_x_');
        
        FileNames{iThres, iFunc, k, 1} = ...
            [FUNC '_' ...
             num2str(thresholds_(iThres)) '_' ...
             LAB_ '.mat'];

        KIND = LASSIGN == k;

        Result = struct();
        
        Result.N = N;
        Result.J = J(KIND);
        Result.DDF = DDF;
        Result.P = P(:, :, KIND);
        Result.F = F(:, :, KIND);
        Result.B = B(:, :, KIND);
        Result.SE = SE(:, :, KIND);
        
        Result.NP = 0;
        Result.NF = 0;
        Result.NB = 0;
        if ~isempty(NP) && ~isempty(NF) && ~isempty(NB)
            Result.NP = NP(:, :, KIND);
            Result.NF = NF(:, :, KIND, :);
            Result.NB = NB(:, :, KIND, :);
        end
        
        Result.LAB  = LLAB(KIND);
        Result.TYPE  = LTYPE(KIND);

        MMEAN = MMEANS(KIND);
        LLEV_ = LLEV(KIND);
        MIND = ~cellfun(@isempty, MMEAN);
        MMEAN = MMEAN(MIND);
        
        Result.LEV = 0;
        Result.LLEV = 0;
        Result.MEAN = 0;
        if ~isempty(MMEAN)
            Result.LEV  = MMEAN;
            Result.LLEV = LLEV_;
            Result.MEAN = Result.B(:, :, MIND);
        end

        save(fullfile(resultsPath, 'CorrResults', ...
            FileNames{iThres, iFunc, k, 1}), '-struct', 'Result');
    end
end

end
