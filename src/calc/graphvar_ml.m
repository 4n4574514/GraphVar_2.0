
function [Y, YPRED, YNPRED, YLAB, YPRED_, YNPRED_, ...
ACC_NP, AUC_NP, ACC_NP2, AUC_NP2, ACC_NPN, AUC_NPN, AUC_NPN2, ACC_NPN2, ...
ACC, AUC, ACC2, AUC2, ACC_N, AUC_N, ...
R, RR, RR2, RC, RRC, ...
PP, NP, PPC, NPC, ...
W, NPW, PWF, XXLAB, NXLAB] = graphvar_ml(allTasks, NeoData, RES, APRED, NPRED, LAB, XX, XLAB, ...
var_case, modelType, nCVFolds, nPermutations, ...
doFeatSel, outerFeatSelThres, ...
doHyperOpt, nHyperOptSteps, doManual, mpar1, mpar2, Outcome)

% graphvar_ml runs inside executeStats 
% executes classification or regression model build and some evaluation metrics 

% set up and fetch model types 
[~, HYPO, HYP, TRAIN, TEST, STAT, LAB_CONV] = graphvar_ml_models(modelType, nHyperOptSteps, doManual); 

   % feed in manually entered parameters 
   if doManual == 1               
      HYP = [mpar1];
        if ~isempty(mpar2)
             HYP = [mpar1, mpar2];
        end
   end
 
    % feature selection
    if doFeatSel                                                            
        featSelHYP = linspace(0, 1, nHyperOptSteps + 1);
        featSelHYP = featSelHYP(2:end);
        HYPO = [HYPO (1:nHyperOptSteps)'];
    end

   
    %% Dummy coding
    % AX: additional variables
    % NX: nuisance variables
  
        [AX, AXLAB] = DUMMY_CODE(APRED, numel(Outcome));                      
        [NX, NXLAB] = DUMMY_CODE(NPRED, numel(Outcome) + numel(APRED)) ;         
   
     
    function [X, XLAB] = DUMMY_CODE(PRED, INC)
        X = [];
        XLAB = {};
     
     
        for i_ = 1:length(PRED)
            if ischar(NeoData{1, PRED(i_)})
                [VALUES, NLEVELS, STRLEVELS] = graphvar_factor(NeoData(:, PRED(i_)));

                for LEVEL = 1:NLEVELS
                    DUMMY = double(VALUES == LEVEL);
                    X = [X DUMMY(:)];
                    LEVEL_ = [LAB{i_ + INC} '_' STRLEVELS{LEVEL}];
                    XLAB   = [XLAB LEVEL_];
                end
            else
                VALUES_ = [NeoData{:, PRED(i_)}];
                X = [X VALUES_(:)]; 
                XLAB = [XLAB LAB{i_ + INC}];
                
            end
        end
    end
     
    
     XXLAB = [XLAB{1} AXLAB NXLAB];

%% Fetch label (Y) 
% in order to run multiple outcomes in a cue 

     function [Y_] = getY(NeoData, RES)    
             if any(regexp(modelType, 'classification$'))
               Y_ = cell(size(NeoData, 1), length(RES)); 
               Y_ = NeoData(:, RES);
               
           ischar(Y_{1})
               if  ~ischar(Y_{1})
                   Y_ = cell2mat(Y_);              
                   YLAB = num2str(unique(Y_));
               else
                   [YLAB, ~, Y_] = unique(Y_);
               end           
             else 
                Y_ = zeros(size(NeoData, 1), length(RES));     
                Y_ = cell2mat(NeoData(:, RES));   
                YLAB = []; % works for classification, not reg.
             end 
     end

    [Y] = getY(NeoData, RES);
    [a, ~]= size(Y);
    YX = ones(a, 1);
    
    YPRED = zeros([1 numel(XX)]);
    CVFolds = mod(1:size(Y, 1), nCVFolds) + 1;
 
    [YPRED, W, NN] = FIT(Y);   
    
    YNPRED = [];
    % Y predicted using only nuisance variables         
    if ~isempty(NPRED)
        [YNPRED, ~] = FIT_(NX, Y);
    end


%% Unique class labels (Outcome Variable)
%     Y_ = cell(size(NeoData, 1), 1) ;
% 
%     for i = 1:length(RES)
%         if i > 1
%             Y_ = strcat(Y_, ',');
%         end
%         Y_ = strcat(Y_, LAB{i}, '_', NeoData(:, RES(i)));
%     end
% 
%     [YLAB, ~, Y] = unique(Y_);
                       %multi-label case
%     for LEVEL = 2:numel(YLAB)
%         DUMMY = double(Y == LEVEL);
%         DUMMY(Y == 1) = -1;
%         YX = [YX DUMMY(:)];
%     end

    R  = zeros([1 numel(XX)]);
    PP = zeros([1 numel(XX)]);    % parametric p value ROC
    RC = []; % nuisance R 
    PPC = [];  % nuisance permutation p 

    permTask = allTasks.getTask('Permutation');
    permTask.cycles = nPermutations;
    permTask.start();
    
    RR = zeros([1 numel(XX) nPermutations]); % randomized correlation between Y and Ypredicted in permutation
    RRC = zeros([1 nPermutations]);  
    RR2 = zeros([1 nPermutations]); % R2 permutation case, Vars only
    ACC_NP = zeros([1 numel(XX) nPermutations]);                          %permuted accuracy full model
    AUC_NP = zeros([1 numel(XX) nPermutations]);                          %permuted AUC full model
    ACC_NPN = zeros([1  nPermutations]);                        % permuted accurary nuisance model
    AUC_NPN = zeros([1  nPermutations]);                        % permuted AUC nuisance model

    
    ACC_NP2 = zeros([1 nPermutations]);   % ACC permutation case, Vars only
    AUC_NP2 = zeros([1 nPermutations]); % AUC permutation case, Vars only
    ACC_NPN2 = zeros([1 nPermutations]);   % ACC permutation case, Vars only
    AUC_NPN2 = zeros([1 nPermutations]); % AUC permutation case, Vars only

    AUC  = zeros([1 numel(XX)]);
    ACC = zeros([1 numel(XX)]);
    ACC2 = [];
    AUC2 = [];
 
    YPRED_ = zeros([1 numel(XX)]);
    YNPRED_ = [];
    ACC_N = [];
    AUC_N = [];
    PWF = [];
    RW = zeros([NN numel(XX) nPermutations]);        % randomized predictor weights
    NPC = zeros([1 numel(XX)]); %non parametric nuisance 

%% Functions  
%% Core function 
     %% Main K Fold CV Algorithm
    % Inputs:
    % -- X: design matrix (with features)
    % -- Y: actual label (for classification)
    %        actual continous values (regression)
    % Outputs:
    % --- YPRED: predicted probabilities (classification)
    % --- WEIGHTS: weight of features used based on Haufe method
    
    function [YPRED, WEIGHTS] = FIT_(X, Y)
   
        YPRED = zeros(size(Y, 1), 1);
        WEIGHTS = zeros(size(X, 2), nCVFolds);   

        for iCVFold = 1:nCVFolds
           % fprintf('Running Cross-Validation Fold %d.\n', iCVFold)
            
            outerTrainIndex = CVFolds ~= iCVFold;
            outerTestIndex = CVFolds  == iCVFold;

            outerTrainX = X(outerTrainIndex, :);
            outerTestX = X(outerTestIndex, :);

            outerTrainY = Y(outerTrainIndex);
            outerTestY = Y(outerTestIndex);

            middleCVFolds = mod(1:size(outerTrainX, 1), nCVFolds) + 1;                       %training set of outer loop = entire set
            middleCVFolds = middleCVFolds(randperm(size(outerTrainX, 1)));

            if doHyperOpt                                                                     % NEED adjustment for SVM v elastic net ?

                HYPC = mat2cell(HYPO, size(HYPO, 1), ones(1, size(HYPO, 2)));
                HYPC = allcomb(HYPC{:});                                      % HyperParameter combinations

                AA = zeros(nHyperOptSteps, size(HYPC, 1));


                for iMiddleCVFold = 1:nCVFolds                                               
                    middleTrainIndex = middleCVFolds ~= iMiddleCVFold;
                    middleTestIndex = middleCVFolds  == iMiddleCVFold;

                    middleTrainX = outerTrainX(middleTrainIndex, :);
                    middleTestX = outerTrainX(middleTestIndex, :);

                    middleTestX = bsxfun(@minus, middleTestX, mean(middleTrainX));
                    middleTestX = bsxfun(@rdivide, middleTestX, std(middleTrainX));

                    middleTrainX = zscore(middleTrainX);                   %correct

                    middleTrainY = outerTrainY(middleTrainIndex);
                    middleTestY = outerTrainY(middleTestIndex);

                    selectedFeatures = false(nHyperOptSteps, size(X, 2));
                    fprintf('Executing nested cross-validation (Hyperparameter Optimization) %d.\n', iMiddleCVFold)

                    %% Feature selection
                    % prune features based on relative threshold

                    if doFeatSel
                        for iFeatSelStep = 1:nHyperOptSteps
                            featSelThres = featSelHYP(iFeatSelStep);
                            I = 1:size(Y, 1); I = I(outerTrainIndex); I = I(middleTrainIndex);
                            selectedFeatures_ = FEATSEL(X, I, featSelThres);
                            selectedFeatures(iFeatSelStep, selectedFeatures_) = 1;                              
                        end
                    end


                    try
                        for iHyperComb = 1:size(HYPC, 1)                                               
                            middleTrainX_ = middleTrainX;
                            middleTestX_ = middleTestX;

                            if doFeatSel
                                middleTrainX_ = middleTrainX_(:, selectedFeatures(HYPC(iHyperComb, end), :));
                                middleTestX_ = middleTestX_(:, selectedFeatures(HYPC(iHyperComb, end), :));
                            end

                            M = TRAIN(middleTrainX_, middleTrainY, HYPC(iHyperComb, :));
                            middlePredY =  TEST(middleTestX_, middleTestY, M);

                            AA(iMiddleCVFold, iHyperComb) = corr(middleTestY, middlePredY);
                        end
                    catch
                    end
                end

                [~, I] = max(median(AA, 1)); 

                if doFeatSel
                    outerFeatSelThres = featSelHYP(HYPC(I, end));
                end

                HYP = HYPC(I, :);    
            end
            selectedFeatures = 1:size(X, 2);

            if doFeatSel
                I = 1:size(Y, 1); I = I(outerTrainIndex);
                selectedFeatures = FEATSEL(X, I, outerFeatSelThres);                   %
            end

            % apply scaling from train to test
            outerTestX = bsxfun(@minus, outerTestX, mean(outerTrainX)) ;
            outerTestX = bsxfun(@rdivide, outerTestX, std(outerTrainX));
            
            % scaling using zscore (normalisation)
            outerTrainX = zscore(outerTrainX);     

            if doFeatSel
                    outerTrainX_ = outerTrainX(:, selectedFeatures);
                    outerTestX = outerTestX(:, selectedFeatures);
            else
                    outerTrainX_ = outerTrainX;
            end

            M = TRAIN(outerTrainX_, outerTrainY, HYP);
            [outerPredY] = TEST(outerTestX, outerTestY, M);
            YPRED(outerTestIndex) = outerPredY;
            
            % calculate feature weights 
            [outerTrainPredY] = TEST(outerTrainX_, outerTrainY, M);
            WEIGHTS(:, iCVFold) = atanh(corr(outerTrainPredY, outerTrainX));        
        end
        
        % average across outer folds 
        WEIGHTS = mean(WEIGHTS, 2);

    end
    %% END OF CORE ALGORITHM
    
    
%% Feature Thresholding (Inner fold from core algorithm)
% performs feature thresholding based (relative) ie. Whelan, 2014 approach
    
    function selectedFeatures = FEATSEL(X, I, featSelThres)
        middleTrainX = X(I, :);
        innerCVFolds = mod(1:size(middleTrainX, 1), nCVFolds) + 1;
        innerCVFolds = innerCVFolds(randperm(size(middleTrainX, 1)));
        middlePredX = zeros(size(middleTrainX));

        for iInnerCVFold = 1:nCVFolds
            innerTrainIndex = innerCVFolds ~= iInnerCVFold;
            innerTestIndex = innerCVFolds  == iInnerCVFold;
          
            innerTrainX = middleTrainX(innerTrainIndex, :);
            [B, ~] = tlstsq(YX(I(innerTrainIndex), :), innerTrainX);         
            middlePredX(innerTestIndex, :) = tdot(YX(I(innerTestIndex), :), B);
            
           fprintf('Executing nested cross-validation (Feature Selection) %d.\n', iInnerCVFold)
      
            
        end

        ZmiddlePredX = zscore(middlePredX);
        predPerf = sum(ZmiddlePredX .* middlePredX, 1);
        [~, I] = sort(predPerf);
        selectedFeatures = I(1:numel(I) > (1 - featSelThres) * size(I, 2));
    end   

           
%%  Prediction function 
function [YPRED, XWEIGHT, NN] = FIT(Y)                                     
        NN = size(XX{1}, 2) + size(AX, 2) + size(NX, 2);
        YPRED = zeros([size(Y, 1) numel(XX)]);
        XWEIGHT = zeros([NN numel(XX)]);
        for iThreshold = 1:numel(XX)
            X = cat(2, XX{iThreshold}, AX, NX);
            [YPRED(:, iThreshold), XWEIGHT(:, iThreshold)] = FIT_(X, Y); 
        end
end

%%  Calculates AUC and P-Value for prediction (from conf. matrix)
    function [ACC] = accuracy(Y, YPRED)             
        [TP, FN, FP, TN] = conf_mat(Y, YPRED);
        P = TP + FN; 
        N = FP + TN;
        % calculate percentage accuracy
        ACC = ( (TP + TN)/ (P + N) ) *100;    
    end
    

%% additional calculations 
    %% Permutation mode
    for iPermutation = 1:nPermutations
        permTask.newCycle([' ' num2str(iPermutation) ' of ' num2str(nPermutations)]);
        
        % output to display permutation execution
         fprintf('Running Permutation # %d.\n', iPermutation) 
         
         YPERM = Y(randperm(size(Y, 1))); % permute Y

        if ~isempty(NPRED)
            [YNPRED_PERM, ~] = FIT_(NX, YPERM);
                     if any(regexp(modelType, 'classification$'))
                    [YNPRED_PERM_] = LAB_CONV(YNPRED_PERM);
                     end
            [RRC(:, iPermutation), ~] = corr(Y, YNPRED_PERM); % using only nuisance variables
            if var_case == 1
                [YNPRED_PERM, ~] = FIT_(NX, YPERM);
                [RRC2(:, iPermutation), ~] = corr(Y, YNPRED_PERM);
            end
        end

        
        % calculate 
        
        [YPRED_PERM, RW(:, :, iPermutation), ~] = FIT(YPERM);
        [RR(:, :, iPermutation), ~] = corr(Y, YPRED_PERM); 
        
       
        % no thresh case
        if var_case 
            [RR2(:, iPermutation), ~] = corr(Y, YPRED_PERM);
        end

        % conversion
        if any(regexp(modelType, 'classification$'))
            [YPRED_PERM_] = LAB_CONV(YPRED_PERM);

            % determine 6/7 cases
            if  ~var_case 
                for iThresh = 1: numel(XX)
                    % fix this
                    ACC_NP(:, iThresh, iPermutation) = accuracy(Y, YPRED_PERM_(:, iThresh));              
                    AUC_NP(:, iThresh, iPermutation) = roc(Y, YPRED_PERM(:, iThresh));
                end
                if ~isempty(NPRED)
                    ACC_NPN(:, iPermutation) = repmat(accuracy(Y, YNPRED_PERM_), [1  1]);                             
                    AUC_NPN(:, iPermutation) = repmat(roc(Y, YNPRED_PERM), [1  1]);           %check if correct
                end
                % for variable only case
            elseif   var_case
                ACC_NP2(:, iPermutation) = accuracy(Y, YPRED_PERM_(:));             % non parametric
                AUC_NP2(:, iPermutation) = roc(Y, YPRED_PERM(:));
                if ~isempty(NPRED)
                    ACC_NPN2(:, iPermutation) = accuracy(Y, YNPRED_PERM_(:));    % non parametric nuisance
                    AUC_NPN2(:, iPermutation) = roc(Y, YNPRED_PERM(:));
                end
            end
        end  %end classification   
        
    end %end permutation
    
    if any(regexp(modelType, 'classification$'))
        [YPRED_] = LAB_CONV(YPRED);
        
        if var_case == 1
            ACC2 = accuracy(Y, YPRED_);
            AUC2 = roc(Y, YPRED); 
        end
        
        for iThresh = 1: numel(XX)
            ACC(:, iThresh) = accuracy(Y, YPRED_(:, iThresh));
            AUC(:, iThresh) = roc(Y, YPRED(:, iThresh));
        end
        
        if ~isempty(NPRED)
            [YNPRED_] = LAB_CONV(YNPRED);
            ACC_N = accuracy(Y, YNPRED_);
            AUC_N = roc(Y, YNPRED);
        end
    end

    
     if ~isempty(NPRED)                                                  
        [RC, ~] = corr(Y, YNPRED);
        Z = (atanh(R) - atanh(RC)) / sqrt(2 / (length(Y) - 3)); % z statistic            
        PPC = 1 - normcdf(Z);                                   % p value
     end

    if nPermutations >= 1 
%         if ~isempty(NPRED)       
%             % if there are nuisance variables
%              for iThresh = 1: numel(XX)
%              RZ(:, iPermutation, iThresh) = bsxfun(@minus, atanh(RR(:, iThresh)), atanh(RRC)) / sqrt(2 / (length(Y) - 3)) % compare randomized correlations in a nonparametric way
%              NPC = 1 - mean(bsxfun(@gt, Z, RZ), 3);
%              end
%         end
    end
    
   
    WW = tanh(W);
    WDF = size(Y, 1) - 2;
    WT = WW .* sqrt(WDF) ./ (1 - WW .^ 2);
    PWF = 1 - tcdf(WT, WDF);  % parametric weights p val
     for iThresh = 1: numel(XX)
    [R(:, iThresh), PP(:, iThresh) ] = STAT(Y, YPRED(:, iThresh));              % correlation between Y and Ypredicted, and parametric p-value
     end
    NP = 1 - mean(bsxfun(@gt, R, RR), 3);            % nonparametric test for correlation 
    NPW = mean(bsxfun(@gt, abs(W), abs(RW)), 3); % nonparametric test for weights    
   

end
