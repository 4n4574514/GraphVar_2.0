
function [W, P_VAL, PlotType] = matrix_weights(handles, W, P_VAL, CORRECTION, isHalf)
%% feature weights (for classification or regression) for matrix display only
% exception(also nxn features such as edge_betweenness)
% nested inside feature_weights function 
% displays feature weights for correlation matrix alone
% handles: GUI input
% W: feature weights 
% P_VAL: p values for feature weights 
% CORRECTION: user selection of alpha correction mode
% isHalf: if mirror connectivity matrix (true), if full matrix (false)


    set(handles.alt_metric ,'Visible','off') ;
    
    %HIDE STAT BASED ON NON SIGNIFICANT PVALS
    handles.PlotType = 4; 
    ALPHA = str2num(get(handles.AlphaLevel, 'String'));
    
     if CORRECTION  ==  2  || CORRECTION == 3 || CORRECTION == 5 || CORRECTION  == 6  % any of the correction cases  
     Results_doCorrection(handles,[],P_VAL, ALPHA);
     elseif CORRECTION  ==  1  || CORRECTION  == 4 
     set(handles.CorrectedAlpha,'String',num2str(ALPHA));
     end 
     
        set(handles.HideNSig_Check, 'Enable', 'on')
            if(get(handles.HideNSig_Check,'Value') ==1)   %index NON significant, turn to NaN
                PVAL_NS = P_VAL > str2num(get(handles.CorrectedAlpha, 'String'));
                W(PVAL_NS) = nan;
                P_VAL(PVAL_NS) = nan;
            end

    [W] = shape_ml(handles,W, isHalf);
    [P_VAL] = shape_ml(handles,P_VAL, isHalf);

    % switch between PVAL and Weights display 
    if  get(handles.PValues, 'Value') == 1
        STAT = P_VAL;
    else
        STAT = W;
   end

    mask = ~isnan(STAT);                     
    WP = imagesc(STAT);
    set(WP, 'AlphaData', mask);
    axis ij

    h = colorbar;
    set(h,'fontsize',10);
    hold on
    
    if ischar(handles.BrainStrings{1})
     S1 = regexprep(handles.BrainStrings,'_',' ');
    else
     S1 = handles.BrainStrings;                % causes issue with numerical brainstring 
    end 
        
        
    set(handles.ResultAxes, 'YTick', 1:length(S1), ...
    'YTickLabel', S1);


if ~verLessThan('matlab', '9.1')  && ~ismac 
    set(handles.ResultAxes, 'XTick', 1:length(S1), ...
    'XTickLabel', S1);
    xtickangle(60);
else
    %set(txt1,'FontSize',5,'FontName','Helvetica');
end
    set(gca,'FontSize',5,'FontName','Helvetica');

    
    % transmit info hovertext
    PlotType = 3;
    PlotName = 'WM';
    
end