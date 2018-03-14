%% Residuals (Regression)
function [RSDL, PRED] = residuals_plot(handles, featurelist, PRED, Y, LineColor, var, RSDL1, PRED1, var_case, thresh)
% outcome field enable
% features field disable
% threshold field enable
% brain strings field disable


set(handles.L_Graph,'String',{'All' featurelist{:}},'Enable','inactive', 'Value', 1); 
if isempty(handles.thresholds)  && isempty(strmatch( 'corr_area', featurelist))
    set(handles.L_brain,'String',[], 'Enable','off');
end
set(handles.correction_type ,'Enable','off', 'Value', 1)  ;

% fetch if multiple outcome     
    if LineColor == 'r' || var_case == 1 
        PRED = PRED(:, var);     
        else 
        PRED = PRED(:, thresh, var);  
       
    end

Y = Y(:, var); 

% Residual: observed - predicted 
RSDL = Y - PRED;

A1 = scatter(PRED,RSDL,'o');
set(A1,'LineWidth', 3);
set(A1, 'MarkerFaceColor', LineColor); 
set(A1, 'MarkerEdgeColor', LineColor); 
title('Residuals','FontSize',14); % Adds title
xlabel('Predicted','FontSize',12); % Adds label on the x axis
ylabel('Standardized Residual','FontSize',12); % Adds label on the y axis

H1 = refline([0]);
set (H1, 'Color', 'r');

grid minor; %optional
set(gca,'FontName', 'Courier');

if ~isempty(RSDL1)
RSDL = [RSDL1, RSDL];
PRED = [PRED1, PRED];    
end 

LAB = {'Predicted', 'Std. Residual'};
PlotType = 1;
PlotName = 'RS'; 
set(handles.ResultFig,'WindowButtonMotionFcn', ...
{@pressML,handles,PlotType, PRED, RSDL, [], [], LAB, PlotName});
end