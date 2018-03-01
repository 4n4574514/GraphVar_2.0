function [A, P, SE] = roc(Y, YP, varargin)      
% inputs: Y (Actual), YP (Predicted)
% adjusted function from (source ? file exchange - Lea)
% PP and R should be per nThresholds (!) 

    Y = Y == max(Y);
    
    
%     [~, nThresh] = size(YP); %%% correct for multiple thresholds 
    
    [~, I1] = sort(YP);
    FPR = cumsum(Y(I1)) / sum(Y(I1));
    TPR = cumsum(~Y(I1)) / sum(~Y(I1));
    
    [~, I2] = unique(YP(I1));
    
    FPR = [0; FPR(I2); 1];   % index exceeds dimensions (dynamic, multiple thresh)
    TPR = [0; TPR(I2); 1];
    
    A = 0.5 * sum( ...
        (FPR(2:end) - FPR(1:end-1)) .* ...
        (TPR(2:end) + TPR(1:end-1)));
    
    Q1 = A / (2 - A);
    Q2 = (2 * A ^ 2) / (1 + A);
    
    N1 = sum(Y == 0);
    N2 = sum(Y ~= 0);
    
    VAR = (A * (1 - A) + ...
        (N2 - 1) * (Q1 - A ^ 2) + ...
        (N1 - 1) * (Q2 - A ^ 2)) / N1 / N2; 
    SE = sqrt(VAR);
%     
%     [C, D] = meshgrid(Z1, Z2);
%     M = 0.5 * (C == D) + (C > D);
%     
%     C = sum(M, 1) / N1;
%     D = sum(M, 2)' / N2;
%     
%     T = sum(M(:)) / (N1 * N2);
    
    if ~isempty(varargin) 
        [A2, ~, SE2] = roc(Y, varargin{1});
        A = A - A2;
        P = 1 - normcdf(A - A2, 0, sqrt(SE ^ 2 + SE2 ^ 2));
    else
        P = 1 - normcdf(A, 0.5, SE);
    end
    
%     
%     T1 = sum(I1(Y == 1));
%     T2 = sum(I1(Y ~= 1));
% 
%     
%     YPS = YP(I2);
%     
% %     tp = cumsum(Y == 1) / sum(Y == 1);
% 
% 
% 
%     NQ = N1;
%     if T2 > T1
%         NQ = N2;
%     end
% 
%     U = N1 * N2 + NQ * (NQ + 1) / 2 - max(T1, T2);
% 
%     A = U / sum(Y == 1) / sum(Y ~= 1);
%     
%     P = 1.0;
end