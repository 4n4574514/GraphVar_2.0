
function [RSDL, PRED] = residuals_plot(handles, featurelist, PRED, Y, linecolor, var, RSDL1, PRED1, var_case, thresh)
%% Residuals (Regression) plot
% plots standardized residuals
% handles: user selections in GUI 
% featurelist: list of features used in prediction
% PRED: predicted values
% Y: actual values
% linecolor: input of plot line color (diff. 2nd run/nui) 
% var: prediction outcome user selection (if multiple)
% RSDL1: residual values (2nd run)
% PRED1: predicted values (2nd run)
% var_case: determine if variable only feature mode 
% thresh: current user selected network threshold

set(handles.L_Graph,'String',{'All' featurelist{:}},'Enable','inactive', 'Value', 1); 
if isempty(handles.thresholds)  && isempty(strmatch( 'corr_area', featurelist))
    set(handles.L_brain,'String',[], 'Enable','off');
end
set(handles.correction_type ,'Enable','off', 'Value', 1)  ;

% fetch if multiple outcome     
    if linecolor == 'r' || var_case == 1 
        PRED = PRED(:, var);     
        else 
        PRED = PRED(:, thresh, var);  
       
    end

Y = Y(:, var); 

% Residual: observed - predicted 
RSDL = Y - PRED;

A1 = scatter(PRED,RSDL,'o');
set(A1,'LineWidth', 3);
set(A1, 'MarkerFaceColor', linecolor); 
set(A1, 'MarkerEdgeColor', linecolor); 
title('Residuals','FontSize',14); 
xlabel('Predicted','FontSize',12); 
ylabel('Standardized Residual','FontSize',12);

H1 = refline(0);
set (H1, 'Color', 'r');

if ~isempty(RSDL1)
RSDL = [RSDL1, RSDL];
PRED = [PRED1, PRED];    
end 

grid minor; %optional
set(gca,'FontName', 'Courier');

end