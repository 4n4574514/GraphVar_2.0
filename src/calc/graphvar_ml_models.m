function [PNAME, HYPO, HYP, TRAIN, TEST, STAT, LAB_CONV] = graphvar_ml_models(modelType, nHyperOptSteps, doManual)
% set up model types (and their settings) 
% inputs: modelType (user selection from dropdown menu) 
%            nHyperOptSteps (number of hyperoptimisation steps 
% predefine types of scales for hyperparameter optimisation 
% if model selection is manual, parameters change with user selection of
% modelType

HYPlog_ = logspace(-2, 3, nHyperOptSteps);          
    if doManual 
        HYP01_ = 1; % set generic, doesnt matter since not called 
        else
        HYP01_ = linspace(0, 1, nHyperOptSteps + 1); 
        HYP01_ = HYP01_(2:end);
    end 

LAB_CONV = [];

function [P] = LSVC_TEST(X, Y, M)
% linear support vector classification 
% inputs are design matrix with features (X)
%                actual label (Y) and struct of model (M)
% outputs: probability scores for classification 
    [~, ~, P] = svmpredict(Y, X, M, '-q -b 0');        
    P = P(:, end) ;                                         
end

function [P] = LSVC_TEST_PROB(X, Y, M)     
% linear support vector classification (probabilistic)
% inputs are design matrix with features (X)
%                actual label (Y) and struct of trained model (M)
% outputs: probability scores for classification 
   [~, ~,  P] = svmpredict(Y, X, M, '-q -b 1')     ;
    P = P(:, end);
end

function [C] = ELNET_COEF(M)
% ElasticNet (glmnet) coefficients 
% inputs struct of trained model 
% outputs: probability scores for classification 
    C = glmnetPredict(M.fit, [], M.lambda, 'coefficients');
    C = C(2:end);
end

function [PRED_] = LAB_CONV1(PRED)   
% conversion from probability values to class labels 
% where decision is at 0 
    PRED_ =  zeros(size(PRED));
    PRED_(PRED > 0) = 2; 
    PRED_(PRED_ <= 0) = 1;
end

function [PRED_] = LAB_CONV2(PRED)   
% conversion from probability values to class labels 
% where decision is at 0.5
    PRED_ =  zeros(size(PRED));
    PRED_(PRED > 0.5) = 2; PRED_(PRED_  <= 0.5) = 1;
end


%% set up outputs for different model types (cases) 
if strcmp(modelType, 'LinSVM classification')                
    PNAME = {'C'};
    HYPO = [HYPlog_(:)];
    HYP = [10];
    TRAIN = @(X, Y, P) svmtrain(Y, X, ['-s 0 -t 0 -c 1 -n' ' ' num2str(P(1)) ' '  '-b 0 -q']);
    TEST = @LSVC_TEST;
    LAB_CONV = @LAB_CONV1;
    STAT = @roc;
    %     COEF = @(M) M.SVs' * M.sv_coef;
    
elseif strcmp(modelType, 'LinSVM probabilistic classification')         
    PNAME = {'C'};
    HYPO = [HYPlog_(:)];
    HYP = [10];
    TRAIN = @(X, Y, P) svmtrain(Y, X, ['-s 0 -t 0 -c 1 -n' ' ' num2str(P(1)) ' '  '-b 1 -q']);
    TEST = @LSVC_TEST_PROB;
    LAB_CONV = @LAB_CONV2;
    STAT = @roc;
%     COEF = @(M) M.SVs' * M.sv_coef;

elseif strcmp(modelType, 'LinSVM regression')                          
    PNAME = {'Nu'};
    HYPO = [HYP01_(:)];
    HYP = [0.5];
    TRAIN = @(X, Y, P) svmtrain(Y, X, ['-s 4 -t 0 -c 1 -n' ' ' num2str(P(1)) ' '  '-b 0 -q']);
    TEST = @LSVC_TEST;
    STAT = @(Y, YPRED) corr(Y, YPRED, 'tail', 'right'); 
%     COEF = @(M) M.SVs' * M.sv_coef;

elseif strcmp(modelType, 'ElasticNet classification')                   
    PNAME = {'Lambda', 'Alpha'};
    HYPO = [HYPlog_(:) HYP01_(:)];
    HYP = [0.01 0.5];
    TRAIN = @(X, Y, P) struct('fit', glmnet(X, Y, 'binomial', struct('alpha', P(2), 'nlambda', 1, 'lambda', P(1))), 'lambda', P(1));
    TEST = @(X, Y, M) glmnetPredict(M.fit, X, M.lambda, 'response', 0);
    LAB_CONV = @LAB_CONV2;
    STAT = @roc;
%  COEF = @ELNET_COEF;

elseif strcmp(modelType, 'ElasticNet regression')                      
    PNAME = {'Lambda', 'Alpha'};
    HYPO = [HYPlog_(:) HYP01_(:)];
    HYP = [0.01 0.5];
    TRAIN = @(X, Y, P) struct('fit', glmnet(X, Y, 'gaussian', struct('alpha', P(2), 'nlambda', 1, 'lambda', P(1))), 'lambda', P(1));
    TEST = @(X, Y, M) glmnetPredict(M.fit, X, M.lambda, 'response', 0);
    STAT = @(Y, YPRED) corr(Y, YPRED, 'tail', 'right'); 
% COEF = @ELNET_COEF;
end

end
