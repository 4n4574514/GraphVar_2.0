%% Scatter Plot (Regression)
function [Y, PRED, R2] = scatter_plot(handles, featurelist, PRED, Y, R, LineColor, thresh, Y1, PRED1, var, var_case)

% outcome field enable
% features field disable
% threshold field enable
% brain strings field disable

set(handles.L_Graph,'String',{'All' featurelist{:}},'Enable','inactive', 'Value', 1);  
set(handles.L_thresh,'Max',1,'Min',0);
set(handles.AlphaLevel ,'Enable','off')  ;
if isempty(handles.thresholds)  && isempty(strmatch( 'corr_area', featurelist))
    set(handles.L_brain,'String',[], 'Enable','off');
end


    if LineColor == 'r' || var_case == 1 
        PRED = PRED(:, var);
        R = R(:, var); 
        else 
        PRED = PRED(:, thresh, var);  
        R = R(:, thresh, var); 
    end

Y = Y(:, var); 


A1 = scatter(PRED,Y,'o');
set(A1,'LineWidth', 3);
set(A1, 'MarkerFaceColor', LineColor); 
set(A1, 'MarkerEdgeColor', LineColor); 
xlim([0 max(PRED)]);
ylim([0 max(Y)]);                % correct axis limits so plot allows border visual
title('Predicted vs Actual','FontSize',14); % Adds title
xlabel('Predicted Value','FontSize',12); % Adds label on the x axis
ylabel('Actual Value','FontSize',12); % Adds label on the y axis

     if length(handles.thresholds) > 1                   % check if R2 calculated correctly
            if thresh == 1 
                R2 = (R(:,  1)).^2;
            else
                R2 = R.^2;                  
            end
     else
      R2 = R.^2;
    end

hold on
S1 = sprintf('R2 (Full Model): %0.5f', R2);
AXL = max([max(Y) max(PRED)]); AXL = AXL + (AXL*0.2);

%least-squares line on the scatter plot.
ylim ([0 AXL]);
xlim ([0 AXL]);
h1 = lsline;
set(h1(1),'color',LineColor, 'LineStyle','--');
% set(gca,'FontName', 'Courier');

if ~isempty(Y1)
Y = [Y1;Y];
PRED = [PRED1; PRED];
set(h1(2),'color','b', 'LineStyle','--');
end

%hovertext
LAB = {'Predicted', 'Actual'};
PlotType = 1;
PlotName = 'SC';
set(handles.ResultFig,'WindowButtonMotionFcn', ...
{@pressML,handles,PlotType, PRED, Y, [], [], LAB, PlotName});
end