
function  [PREC, RECALL, AUC] = pr_curve(handles, featurelist, PRED, Y, linecolor, var, thresh)
%% PR Curve Plot (Classification)
% Preps and plots Receiver Operating Characteristic curve 
% Input arguments %%%%% 
% handles:GUI handles
% featurelist: list of features used in prediction
% PRED: Predicted Outcome 
% Y: Actual Measure 
% 
     
% reset feature listbox AND brain areas listbox
set(handles.HideNSig_Check,'Enable','off');
set(handles.L_Graph,'String',{'All' featurelist{:}},'Enable','inactive', 'Value', 1); 
set(handles.L_thresh,'String',handles.thresholds, 'Enable','on');
set(handles.L_brain,'String',handles.BrainStrings, 'Enable','inactive');
if isempty(handles.thresholds)  
   set(handles.L_brain,'String',[], 'Enable','off');
end
%threshold can only select 1 value maximum   
set(handles.L_thresh,'Max',1,'Min',0);
set(handles.PValues,'Enable', 'Off'); 
set(handles.AlphaLevel ,'Enable','off')  ;


if ~(length(PRED) == length(Y))
   PRED = PRED(:, thresh, var);
   
else
  PRED = PRED(:, var); 
end 
Y= Y(:, var);

UY = unique(PRED);
PREC = zeros(length(UY), 1);
RECALL = zeros(length(UY), 1);

    for iY = 1:length(UY)
        PRED_ = (PRED > UY(iY)) + 1;
        [TP, FN, FP, ~] = conf_mat(Y, PRED_);

        P = TP + FN;
        PREC(iY) = TP / (TP + FP);
        RECALL(iY) = TP / P;
    end

C1a = plot(RECALL, PREC, 'LineWidth', 1);
set(C1a, 'Color', linecolor);
hold on
C1 = plot(RECALL, PREC, 'o');
set(C1,'LineWidth', 2);
set(C1, 'Color', linecolor); 

AUC = trapz(RECALL, PREC);  %AUC PR calculated manually 
xlim([0 1.05]);
ylim([0 1.05]);                 % correct axis limits so plot allows border visual

xlabel({''; 'Recall (TPR)'; ''});
ylabel({'Precision (PPV)'; ''});
title({'Precision-Recall Curve'; ''});
grid minor

end
