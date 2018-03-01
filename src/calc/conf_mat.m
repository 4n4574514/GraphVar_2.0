function [TP, FN, FP, TN, c_mat, c_met] = conf_mat(Y, PRED)                              
% replaced native MATLAB confusion function
% confusion matrix calculations
% inputs:         Y:  actual values (or labels) 
%            PRED:   predicted values (or labels)
    
n_class = length(unique(Y));
c_mat = zeros(n_class);

    for i=1:n_class
        for j=1:n_class
            val = (Y == i) & (PRED == j);
            c_mat(i, j) = sum(val);
        end
    end                                                      
     
%% binary case -----------------> 

    if n_class == 2 
        TP = c_mat(1, 1);                          
        FN = c_mat(1, 2);
        FP = c_mat(2, 1);
        TN = c_mat(2, 2);

        P = TP + FN; 
        N = FP + TN;

        %accuracy
        ACC = ( (TP + TN)/ (P + N) ) * 100 ;                    
        %error rate 
        ERR = 100 - ACC;
        %positive predictive rate 
        PPV = (TP/ (TP + FP) ) * 100;
        %true positive rate
        TPR = (TP/P) * 100;
        %f-score
        F1 = (2 *( (PPV*TPR)/(PPV + TPR) )  )/100;    
        %true negative rate
        TNR = (TN/ N) * 100;
        
        AUC = nan;
        MCC = nan;
        %area under curve 
         if nargout > 4   
            AUC = roc(Y, PRED);
            % Matthews correlation coefficient/ Phi coefficient  
            MCC = (  ((TP*TN)- (FP*FN))) / (sqrt (  (TP + FP)*(TP + FN)*(TN + FP)*(TN + FN)  )) ; 
         end
        % binary confusion metrics (combined table)  
       c_met = [ACC ERR PPV TPR TNR F1 AUC MCC];
                   
%% multiclass case  
% currently only binary 1-v-1 classification is implemented 
   elseif n_class >= 2 

     % Calculating metrics (ie M. Sokolova et al, 2009)  (per class/corrected) 
     % Implement in next version 
     
    end 
 
end
    
    







