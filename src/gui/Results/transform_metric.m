
function [MET_perm, MET] = transform_metric (metricSelected, met1, met2, met1_perm, met2_perm, thresh, var, plotcolor, var_case)
%% transforms selected actual and null distribution metrics for histogram
% metricSelected: user selection of metric displayed (value)
% met1: actual performance metric (C: accuracy, R: R2) 
% met2: actual performance metric (C: AUC)
% met1_perm: permutation performance metric
% met2_perm: permutation performance metric
% var: prediction outcome user selection (if multiple)
% plotcolor: color of current plot (distriguish nuisance case)
% var_case: determine if variable only features 


    if plotcolor == 'c' && ~var_case 
        if metricSelected == 1
            MET = met1(:, thresh, var);   
            MET_perm = met1_perm(:, thresh, :, var);
        elseif metricSelected == 2 
            MET = met2(:, thresh, var);     
            MET_perm = met2_perm(:, thresh, :, var);
        elseif metricSelected == 3 
            MET = 100 - met2(:, thresh, var);     
            MET_perm = 100 - met2_perm(:, thresh, :, var);
        end 
        
    % nuisance or variable only case     
    elseif plotcolor == 'm'  || var_case  
        if metricSelected == 1
            MET = met1(:, var);  
            MET_perm = met1_perm(:, :, var);
        elseif metricSelected == 2 
            MET = met2(:, var);     
            MET_perm = met2_perm(:, :, var);
        elseif metricSelected == 3 
            MET = 100 - met2(:, var);     
            MET_perm = 100 - met2_perm(:, :, var);
        end                  
           
    end
end