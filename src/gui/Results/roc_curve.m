
function [TPR, FPR, AUC, P_VAL] = roc_curve(handles, featurelist, PRED, Y, AUC, PP, NP, nRandom, linecolor, var, thresh)
%% ROC Curve Plot (Classification)
% Preps and plots Receiver Operating Characteristic curve 
% handles:GUI handles
% featurelist: list of features used in prediction
% PRED: Predicted Outcome 
% Y: Actual Measure 
% AUC: Area under the curve 
% PP: Parametric P-Value for ROC
% NP: Non Parametric P-Value for ROC 
% nRandom: number of permutations
% linecolor: color of plot lines 
% var: current user selected prediction target (if multiple)
% thresh: current user selected threshold 

% reset feature listbox AND brain areas listbox
set(handles.HideNSig_Check,'Enable','off');
set(handles.L_Graph,'String',{'All' featurelist{:}},'Enable','inactive', 'Value', 1); 
set(handles.L_thresh,'String',handles.thresholds, 'Enable','on');
set(handles.L_brain,'String',handles.BrainStrings, 'Enable','inactive');
    if isempty(handles.thresholds)  && ~any(strcmp( 'corr_area', featurelist))
        set(handles.L_brain,'String',[], 'Enable','off');
    end
set(handles.L_thresh,'Max',1,'Min',0);
set(handles.AlphaLevel ,'Enable','off')  ;

% Correction Panel
set(handles.CorrectedAlpha ,'Enable','off')  ;
set(handles.correction_type ,'Enable','on')  ;
set(handles.correction_type,'String','P-Value Type','Enable','on');
set(handles.PValues ,'Enable','off')  ;
pval_type = {'Parametric P-Val', 'Permutation P-Val'};
set(handles.correction_type, 'String', pval_type);
PVal_selected = get(handles.correction_type,'Value');

% fetch user selected, avoid conflict 
if ~(length(PRED) == length(Y))
   PRED = PRED(:, thresh, var);
   AUC = AUC(:, thresh, var);
else
  PRED = PRED(:, var); 
  AUC = AUC(:, var); 
   
end 
Y= Y(:, var);
UY = unique(PRED);
TPR = zeros(length(UY), 1); % true positive rate
FPR = zeros(length(UY), 1); % false positive rate

    for iY = 1:length(UY)
        PRED_ = (PRED > UY(iY)) + 1;
        [TP, FN, FP, TN] = conf_mat(Y, PRED_);
        P = TP + FN;
        N = FP + TN;

        TPR(iY) = TP / P;
        FPR(iY) = 1 - TN / N;
    end

hold on
C1 = plot(FPR, TPR, 'LineWidth', 1);
C1b = plot(FPR, TPR, 'o');
set(C1b,'LineWidth', 2);
set(C1, 'Color', linecolor)
set(C1b, 'Color', linecolor);

xlim([0 1.05]);
ylim([0 1.05]);                
% correct axis limits so plot allows border visual
% plot "chance level" line (ie. 50%)
CC =  plot ([0 1],[0 1], '--');  
set(CC, 'Color', 'g');

xlabel({''; 'False Positive Rate (1- Specificity)'; ''});
ylabel({'True Positive Rate (Sensitivity)'; ''});
title({'Receiver operating characteristic (ROC)'; ''  });

S1 = sprintf ('Area Under Curve: %0.3f', AUC);
legend(  ([C1, C1b, CC]), { S1, 'Full Model', 'Chance Performance'});


% fix hover tool show p values (ROC function) for 1. parametric 2. permutation
P_VAL = [];
    if PVal_selected == 1
       P_VAL = PP; % Result. Parametric ROC Pval
    elseif PVal_selected == 2
       P_VAL = NP;
           if nRandom < 1 
                  cla reset
                  text(0.4, 0.5, 'No permutation values available.');
               return
           end
    end 
                                     

end