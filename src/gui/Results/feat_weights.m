function [W_S, SLAB, P_VAL_S, PlotType] = feat_weights(handles, featurelist, XLAB, W, PPW, NPPW, nRandom, fun, isHalf, thresh, var, var_case, Outcome)
%% feature weights (for classification or regression)
% handles: GUI input
% featurelist: list of features
% W: feature weights 
% PPW: parametric p values for feature weights
% NPPW: non- parametric p values for feature weights
% nRandom: number of permutations
% fun: current user choice of feature 
% isHalf: if mirror connectivity matrix (true), if full matrix (false)
% thresh: current user choice of network threshold
% var: current user choice of prediction outcome variable
% var_case: if variable only (true), if other case (false)
% Outcome: prediction outcome variable (strings list)

colormap default
set(handles.HideNSig_Check,'Enable','on');
set(handles.L_Graph,'String',{'All' featurelist{:}},'Enable','on'); 

if ~var_case 
    W = W(:, thresh, var);
    PPW = PPW(:, thresh , var);
    NPPW = NPPW(:, thresh, var);
else % var only 
    W = W(:,var);
    PPW = PPW(:, var);
    NPPW = NPPW(:, var);
end

        if isempty(handles.thresholds)  && isempty(strmatch( 'corr_area', featurelist))
        set(handles.L_brain,'String',[], 'Enable','off');
        end

    sel_feat = featurelist(fun);        % user selection of features (GVars field)
    set(handles.alt_metric ,'Visible','off') ;
    colormap(handles.ResultAxes,'default')

    % bring back correction panels to get p values (parametric weights)
    set(handles.CorrectedAlpha ,'Enable','on')  ;
    set(handles.CorGraph ,'Enable','on')  ;
    set(handles.CorThresh ,'Enable','on')  ;
    set(handles.CorBrain ,'Enable', 'off', 'Value', 1);
    set(handles.btn_network ,'Enable','on') ;
    set(handles.CorVar, 'Enable', 'off', 'Value', 1); % no need to correct for outcome var (only 1) 

        if  isempty(get(handles.L_thresh, 'String')) 
        set(handles.CorThresh, 'Enable', 'off', 'Value', 2); 
        end 

    set(handles.correction_type ,'Enable','on')  ;
    set(handles.correction_type,'String','P-Value Type','Enable','on');
    set(gca,'FontSize',10,'FontName','Helvetica');

    if nRandom > 0 
        pval_type = {'None  (Parametric)', 'Bonferroni correction (Parametric)', 'FDR - correction (None not applicably) (Parametric)', ...
        'Random Networks/Groups (Permutation)', 'Random Networks/Groups(Bonferroni) (Permutation)', ....
        'Random Networks/Groups(FDR) (Permutation)'};   
   else
        pval_type = {'None  (Parametric)', 'Bonferroni correction (Parametric)', 'FDR - correction (None not applicably) (Parametric)', ...
        'Random Networks/Groups (Permutation) --- NA ', 'Random Networks/Groups(Bonferroni) (Permutation) --- NA', ....
        'Random Networks/Groups(FDR) (Permutation) --- NA '};   
    end
    
   if any(strcmp(sel_feat, 'corr_area')) 
                   middle = {' vs '};
                   N = length(handles.BrainStrings);
                  % if isHalf
                 if ischar(handles.BrainStrings{1})             
                   BS = reshape(strcat({handles.BrainStrings{repmat(1:N, N, 1)}}, middle, {handles.BrainStrings{repmat(1:N, N, 1)'}}), N, N)';
                 else 
                   % convert numeric into string 
                    BS  = cellfun(@num2str, handles.BrainStrings, 'UniformOutput', false);
                    BS = reshape(strcat({BS{repmat(1:N, N, 1)}}, middle, {BS{repmat(1:N, N, 1)'}}), N, N)';
                    
                 end 
                 %transform 
                   [a, b] = size(BS);
                   AA = rand(a,b);
                   AK = ~triu(AA);
                   BS = BS(AK)';
                   CML_index = cellfun(@(x)~isempty(strfind(x,'corr_area_')), XLAB);
                   XLAB(CML_index) = [];
                   XLAB = [XLAB BS];               
    end
   
    %switch between Parametric and Non Parametric P-Value for Weights 
    set(handles.correction_type, 'String', pval_type);
    CORRECTION = get(handles.correction_type,'Value');
        if  CORRECTION == 1 || CORRECTION == 2 || CORRECTION == 3
           P_VAL = PPW;
        elseif CORRECTION == 4 || CORRECTION == 5 || CORRECTION == 6
           P_VAL= NPPW;
        end 
        
    % sort by absolute value (in descending order) => for Data Export 
    [~,ORDER] = sort((abs(W)),'descend' );
    WEIGHTS = [];
    WEIGHTS= W(ORDER);
    
   
    if var_case && ~any(strcmp(sel_feat, 'corr_area'))  % variables only 
       XLAB = featurelist; 
       
    elseif var_case && any(strcmp(sel_feat, 'corr_area'))  % variables + corr    
%           if ~isempty(NCOV)  % corr matrix with nuisance
             XLAB = [XLAB featurelist{(length(Outcome)+1):end}];

    else 
        % all other cases, feature names are fine 
          XLAB  =  XLAB ;
          
    end 
     
    FEATURE = []; % fix output for matrix only  
    P_VALUES_P = [];
    P_VALUES_NP = [];
   
%% CORR_MATRIX ONLY 
    if (any(strcmp(sel_feat, 'corr_area'))   &&  (length(sel_feat) == 1)  || any(cellfun(@(x)~isempty(strfind(x,'edge')), XLAB)) )
         % index raw matrix weights & pvals
       
            if ~any(cellfun(@(x)~isempty(strfind(x,'edge')), XLAB))
                RM_index = cellfun(@(x)~isempty(strfind(x,'vs')), XLAB);
            else
                RM_index = cellfun(@(x)~isempty(strfind(x,'edge')), XLAB);
            end
            SLAB = XLAB(RM_index);
            W =  W(RM_index);  
            P_VAL = P_VAL(RM_index); 
               [W_S, P_VAL_S, PlotType] = matrix_weights(handles, W, P_VAL, CORRECTION, isHalf); %call nested function
               SLAB =[]; 
 
%% SELECTED FEATURES              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else   
        
    sel_feat = regexprep(sel_feat, 'corr_area', 'vs');
    RM_I= zeros([1 numel(sel_feat) ]); % Index of selected features 
        for i = 1:length(sel_feat)
  
            RM_I = cellfun(@(x)~isempty(strfind(x,sel_feat{i})), XLAB);
            W_S =  W(RM_I); % selected weights 
            P_VAL_S=  P_VAL(RM_I); % selected pvals
            SLAB =  XLAB(RM_I); % selected label 

            SF_PVAL{i, :} = P_VAL_S; % transform, cat  
            SF{i, :} =  W_S;
            SL{i, :} =  SLAB;  
        end

        W_S = cell2mat(SF) ;        
        P_VAL_S = cell2mat(SF_PVAL);
        SL =[(SL{:})]; SLAB= SL(:,:).';
       
        
        
%% Alpha Level Correction 
        handles.PlotType = 4; % temp plotType
        alpha = str2num(get(handles.AlphaLevel, 'String'));
            if CORRECTION  ==  2  || CORRECTION == 3 || CORRECTION== 5 || CORRECTION  == 6  % any of the correction cases  
                Results_doCorrection(handles,[],P_VAL,alpha);
               elseif CORRECTION == 1 || CORRECTION == 4 
                alpha = Results_doCorrection(handles,[], P_VAL,alpha);
            end 
            
        
%% Hide Non Significant (Keep structure)
    if(get(handles.HideNSig_Check,'Value') ==1)   %index NON significant, turn to NaN
            PVAL_NS = P_VAL_S > str2num(get(handles.CorrectedAlpha, 'String'));
            P_VAL_S(PVAL_NS) = nan;  % non sig weight   
            W_S(PVAL_NS) = nan;
            
    end

%% show  pvals  (instead of weights)
        if  get(handles.PValues, 'Value') == 1
            STAT = P_VAL_S;
          else
            STAT = W_S ;
        end    

    L_STAT =length(STAT); % length of STAT before transformation
        if L_STAT ~= 0 
          [P_VAL_S, ~] = shape_plot(P_VAL_S, SLAB);
          [W_S, ~] = shape_plot(W_S, SLAB);
          [STAT, SLAB] = shape_plot(STAT, SLAB); 
        end

   
%% Plot Selected Features 
    mask = ~isnan(STAT) ;
    WP = imagesc(STAT);   %  or pcolor(STAT)
    set(WP, 'AlphaData', mask)

    if L_STAT == 1   % only 1 feature displayed 
        imagesc(STAT);
        WPT = text(0.8, 1, sprintf('1 Feature Selected (!)   Result: %0.3f', STAT));
        set(WPT, 'FontWeight', 'bold');
        set(WPT, 'FontSize', 18);
    end
    
    
    WPCB= colorbar;
    set(WPCB,'fontsize',10);
    FL= num2str(L_STAT);
    xlabel(sprintf('Features Displayed: %s ', FL)); % show weights displayed
    set(gca,'XTick',[], 'YTick', []); % remove ticks
    set(gca,'FontName', 'Courier');
        if  get(handles.PValues, 'Value') == 1
            title('Feature Weight P-Values')     
        else
            title('Feature Weights') 
        end
    
%  if length(XLAB) == length(ORDER) 
%      FEATURE= XLAB(ORDER); 
%      FEATURE= FEATURE(:,:).';   
%         P_VALUES_P=  P_VAL(ORDER);
%     if nRandom > 0 
%            P_VALUES_NP =  NPPW(ORDER);
%         else 
%            P_VALUES_NP =  [];
%     end 
%  else 
%      % fix, exceptions 
%  end 
    
    PlotType = 4;    
    %PlotName = 'W'; 
    
    end