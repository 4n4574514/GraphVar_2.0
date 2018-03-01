
function ML_ResultsPlots(hObject,handles)
% called inside Results_PlotView
% Prepares ML Results GUI and data 
% Plots classification and regression plots (ML) 

global result_path;
global result_folder;

[thresh,~,var,brain] = Results_Filters(hObject,handles);
handles.brainSelect = brain;

%% Disable specific buttons for Machine Learning Results View
        set(handles.VPBack ,'Enable','off');                       % VPBack
        set(handles.OpenVP ,'Enable','off');                       % OpenVP
        set(handles.VPForward ,'Enable','off') ;                   % VPForward
        set(handles.Open_PlotMatrix ,'Enable','off') ;             % Open_PlotMatrix
        
        %correction panel items...
        set(handles.correction_type ,'Enable','off')  ;
        set(handles.CorrectedAlpha ,'Enable','off')  ;
        set(handles.CorVar ,'Enable','off')     ;
        set(handles.CorGraph ,'Enable','off')    ;
        set(handles.CorThresh ,'Enable','off')    ;
        set(handles.CorBrain ,'Enable','off')  ;
        set(handles.btn_network ,'Enable','off') ;
        set(handles.HideNSig_Check,'Enable','off');
        %top
        set(handles.nSig ,'Enable','off')  ;
        set(handles.sigVars ,'Enable','off')  ;
        set(handles.mod_func ,'Enable','off') ;

        set(handles.export_btn,'Enable','on');
        set(handles.save_plot,'Enable','on');
        set(handles.Save ,'Enable','on') ;
        set(handles.Load ,'Enable','on') ;
        set(handles.AlphaLevel ,'Enable','on') ;
        set(handles.PValues ,'Enable','on') ;
   
%% Load in Results from Calculations         
% VARIABLES ONLY CASE

          if  isempty(handles.thresholds)
                Result = load( ...
                        [result_path filesep result_folder filesep handles.Files{1}], ...
                        'modelType'  );
                                    if any(regexp(Result.modelType, 'classification$'))
                                                         Result = load( ...
                                                         [result_path filesep result_folder filesep handles.Files{1}], ...
                                                         'modelType', 'nRandom', 'NXLAB', 'Y', 'YPRED', 'YNPRED', 'YLAB', 'YPRED_', 'YNPRED_', ...
                                                         'ACC_NP2', 'AUC_NP2', 'ACC_NPN2', 'AUC_NPN2',  ...
                                                         'ACC2', 'AUC2', 'ACC_N', 'AUC_N', ...
                                                         'PP', 'NP', 'PPC', 'NPC', 'W', 'NPW', 'PWF', 'XLAB', 'isHalf', 'Outcome', 'var_case');
                                                     
                                      Result.ACC = Result.ACC2; Result.AUC = Result.AUC2; Result.ACC_NP = Result.ACC_NP2;
                                      Result.AUC_NP = Result.AUC_NP2; Result.ACC_NPN = Result.ACC_NPN2; Result.AUC_NPN = Result.AUC_NPN2;           
                                                     
                                                     
                                    elseif any(regexp(Result.modelType, 'regression$'))
                                                         Result = load( ...
                                                         [result_path filesep result_folder filesep handles.Files{1}], ...
                                                         'modelType', 'nRandom', 'NXLAB', 'Y', 'YPRED', 'YNPRED', 'YLAB', 'YPRED_', 'YNPRED_', ...
                                                         'R', 'RR', 'RC', 'RRC',...                                                    
                                                         'PP', 'NP', 'PPC', 'NPC', 'W', 'NPW',  'PWF', 'XLAB', 'isHalf', 'Outcome', 'var_case' );          
                                    end
                                    
 % ALL OTHER CASES
          elseif ~isempty(handles.thresholds)
                     Result = load( ...
                        [result_path filesep result_folder filesep handles.Files{thresh(1), 1, 1, 1}], ...
                        'modelType'  );

                               if any(regexp(Result.modelType, 'classification$'))
                                     Result = load( ...
                                     [result_path filesep result_folder filesep handles.Files{thresh(1), 1, 1, 1}], ...
                                     'modelType', 'nRandom', 'NXLAB', 'Y', 'YPRED', 'YNPRED', 'YLAB',  'YPRED_', 'YNPRED_', ...
                                     'ACC_NP', 'AUC_NP',  'ACC_NPN', 'AUC_NPN',  ...
                                     'ACC', 'AUC', 'ACC_N', 'AUC_N', ...
                                     'PP', 'NP',  'PPC', 'NPC', 'W', 'NPW',  'PWF',  'XLAB',  'isHalf', 'Outcome', 'var_case');

                                elseif any(regexp(Result.modelType, 'regression$'))
                                     Result = load( ...
                                     [result_path filesep result_folder filesep handles.Files{thresh(1), 1, 1, 1}], ...
                                     'modelType', 'nRandom', 'NXLAB', 'Y', 'YPRED', 'YNPRED', 'YLAB', 'YPRED_', 'YNPRED_', ...
                                     'R', 'RR', 'RC', 'RRC', ...
                                     'PP', 'NP',  'PPC', 'NPC', ...
                                     'W', 'NPW', 'PWF', 'XLAB',  'isHalf', 'Outcome', 'var_case');
                              end
          end
          
% corrected feature list (nuisance vars in the end)
featurelist = get(handles.L_Graph,'String'); featurelist = {featurelist{2:end}} ;  
thresh = get(handles.L_thresh,'value');
   if  get(handles.L_Graph,'Value') == 1
             fun= 1:length(featurelist);
   else
             fun= get(handles.L_Graph,'Value') -1;
           
   end 
                 % No Thresholds Case (no graph metrics as features)
                 if isempty(handles.thresholds)  
                   filterFieldStrings{1} = handles.vars(var);
                   filterFieldStrings{4} = handles.BrainStrings(brain);

                 % Cases including graph metrics as feat. 
                 else     
                  filterFieldStrings{1} = handles.vars(var) ;
                  filterFieldStrings{3} = handles.thresholds(thresh); 
                  filterFieldStrings{4} = handles.BrainStrings(brain); 
                 end   
                       
%% Define Classification and Regression Plot Choices 
 axes(handles.ResultAxes2); % plot performance metrics to additional axes 
    if any(regexp(Result.modelType, 'classification$'))  % Parametric cases
               plots = {'Confusion matrix', 'ROC curve', 'Precision-Recall Curve', 'Feature Weights'};
                                    if  Result.nRandom > 0 % Permutation cases
                                                  plots = {'Confusion matrix', 'ROC curve',  'Precision-Recall Curve',  ...
                                                  'Feature Weights',  'Histogram (Permutation Performance)', };
                                    end
                                    
                % set function call for performance_class 
                if isempty(Result.NXLAB)
                     [~] =  metrics_class(handles, Result.YPRED_, [], Result.Y, Result.AUC, [], var, thresh, Result.var_case);
                elseif ~isempty(Result.NXLAB)
                     [~] = metrics_class(handles, Result.YPRED_, Result.YNPRED_, Result.Y, Result.AUC, Result.AUC_N, var, thresh, Result.var_case);
                end
    elseif any(regexp(Result.modelType, 'regression$'))  % Parametric cases
                             plots = {'Scatter Plot', 'Residuals Plot', 'Feature Weights'};
                                    if  Result.nRandom > 0  % Permutation cases
                                             plots = {'Scatter Plot', 'Residuals Plot',  ...
                                                          'Feature Weights', 'Histogram (Permutation Performance)'};
                                    end      
                                    
               % set function call for performance_reg 
               if isempty(Result.NXLAB)
                    [~] = metrics_reg(handles,Result.YPRED,Result.R, [], [], Result.Y, var, Result.var_case, thresh);
               elseif ~isempty(Result.NXLAB)
                   [~] = metrics_reg(handles, Result.YPRED,Result.R, Result.YNPRED, Result.RC, Result.Y, var, Result.var_case, thresh);
               end
    end

    set(handles.GroupTestChooser, 'String', plots);
    plotNames = get(handles.GroupTestChooser, 'String');
    plotSelected = get(handles.GroupTestChooser,'Value');
    plotName = plotNames(plotSelected);
    plotName = plotName{1};
    axes(handles.ResultAxes); 
    
    
%% Define Classification and Regression Plot Inputs 
if  any(regexp(Result.modelType, 'classification$'))
        switch plotName
                case 'ROC curve'
                    cla reset       
                    grid minor
                    [TPR, FPR, AUC, PVAL] = ROC_curve(handles, featurelist, Result.YPRED, Result.Y, Result.AUC, Result.PP, Result.NP, Result.nRandom, 'blue', [], [], var, thresh); 
                    legend({ 'Full Model', sprintf('AUC: %0.3g', AUC), 'Chance Performance'});
                    set(handles.alt_metric ,'Visible','off') ;
                    % fetch outputs of current function called 
                         if ~isempty(Result.NXLAB)
                             set(handles.alt_metric ,'Visible','on','Enable','on') ; 
                             metric = {'Full & Nuisance Model', 'Full Model', 'Nuisance Only Model'};
                             set(handles.alt_metric, 'String', metric);
                             metricSelected = get(handles.alt_metric,'Value');
                                      cla reset  
                                       [TPR, FPR, AUC, PVAL]  = ROC_curve(handles, featurelist, Result.YPRED, Result.Y, Result.AUC, Result.PP, Result.NP, Result.nRandom, 'blue', [], [], var, thresh);
                                      hold on 
                                       [TPR2, FPR2, AUC2, PVAL2]  = ROC_curve(handles, featurelist, Result.YNPRED, Result.Y, Result.AUC_N, Result.PPC(thresh), Result.NPC(thresh), Result.nRandom,'red', TPR, FPR, var, thresh);
                                      legend({'Full Model', sprintf('AUC: %0.3g', AUC), 'Chance Performance', 'Nuisance Model Only', sprintf('AUC: %0.3g', AUC2)});
                                      grid minor     
                                    if metricSelected == 2 
                                          cla reset       
                                          grid minor
                                           [TPR, FPR, AUC, PVAL] = ROC_curve(handles, featurelist, Result.YPRED, Result.Y, Result.AUC, Result.PP, Result.NP, Result.nRandom, 'blue', [], [], var, thresh);
                                            legend({ 'Full Model', sprintf('AUC: %0.3g', AUC), 'Chance Performance'});
                                    elseif metricSelected == 3 
                                          cla reset
                                          grid minor
       
                                        [TPR2, FPR2, AUC2, PVAL2] = ROC_curve(handles, featurelist, Result.YNPRED, Result.Y, Result.AUC_N, Result.PPC, Result.NPC, Result.nRandom,'red', [], [], var, thresh);
                                         legend({ 'Nuisance Only Model', sprintf('AUC: %0.3g', AUC2), 'Chance Performance'});
                                    end  
                                     
                         end 
                      
                         
                case 'Precision-Recall Curve'  
                      cla reset
                       [PREC, RECALL, AUC] = PR_curve(handles, featurelist, Result.YPRED, Result.Y, 'blue', [], [], var, thresh); % transmit PR AUC (trapezoid method)
                           legend({ 'Full Model', sprintf('AUC: %0.3g', AUC)});
                          set(handles.alt_metric ,'Visible','off') ;
                                if ~isempty(Result.NXLAB)    
                                     set(handles.alt_metric ,'Visible','on','Enable','on') ; 
                                     metric = {'Full & Nuisance Model', 'Full Model', 'Nuisance Only Model'};
                                     set(handles.alt_metric, 'String', metric);
                                     metricSelected = get(handles.alt_metric,'Value');
                                              cla reset
                                              [PREC, RECALL, AUC] = PR_curve(handles, featurelist, Result.YPRED, Result.Y, 'blue', [], [], var, thresh);
                                              hold on 
                                             [PREC2, RECALL2, AUC2] = PR_curve(handles, featurelist, Result.YNPRED, Result.Y, 'red', PREC, RECALL, var, thresh);
                                               legend({ 'Full Model', sprintf('AUC: %0.3g', AUC),  'Nuisance Only Model', sprintf( 'AUC: %0.3g', AUC2)});
                                             if metricSelected == 2 
                                                  cla reset
                                              [PREC, RECALL, AUC] = PR_curve(handles, featurelist, Result.YPRED, Result.Y, 'blue', [], [], var, thresh);
                                                  legend({ 'Full Model', sprintf('AUC: %0.3g', AUC)});
                                            elseif metricSelected == 3 
                                                 cla reset
                                              [PREC2, RECALL2, AUC2]  =PR_curve(handles, featurelist, Result.YNPRED, Result.Y, 'red', [], [], var, thresh);
                                                  legend({ 'Nuisance Only Model', sprintf('AUC: %0.3g', AUC2)});
                                            end          
                                end     
                               grid minor 
  
                case 'Confusion matrix'
                       cla reset
                          [c_mat] = c_matrix(handles, featurelist, Result.YPRED_,[], Result.Y, Result.YLAB, var, thresh, Result.var_case);     
                          if ~isempty(Result.NXLAB)   
                                     clear metric 
                                     clear metricSelected
                                     cla reset
                                     metric = {'Full model','Nuisance Only Model', 'N/A'};
                                     set(handles.alt_metric, 'String', metric);
                                     metricSelected = get(handles.alt_metric,'Value');
                                     set(handles.alt_metric ,'Visible','on','Enable','on') ;
                                           if metricSelected == 1
                                           [c_mat] = c_matrix(handles, featurelist, Result.YPRED_,[], Result.Y, Result.YLAB, var, thresh, Result.var_case);  
                                           elseif metricSelected == 2
                                           [c_mat2] =  c_matrix(handles, featurelist, [], Result.YNPRED_, Result.Y, Result.YLAB, var, [], Result.var_case);
                                           elseif metricSelected == 3
                                           %under construction (side by side)
                                           end          
                          end      
         
                case 'Feature Weights'                     % set same for Regression and Classification 
                      cla reset
              [FEATURE, WEIGHTS, P_VALUES_P, P_VALUES_NP] =  feat_weights(handles, featurelist, Result.XLAB, Result.W, Result.PWF, Result.NPW, Result.nRandom, fun, Result.isHalf, thresh, var, Result.var_case, Result.NXLAB, Result.Outcome);

              
               case 'Histogram (Permutation Performance)'  % set same for Regression and Classification 
                      cla reset
                   [PVAL, MET, MET_perm] =  histogram(handles, featurelist, Result.AUC, Result.ACC, Result.AUC_NP, Result.ACC_NP, 'blue', 'c', ...
                          Result.nRandom, Result.modelType, var, Result.var_case, thresh, Result.NXLAB);
                          legend({ 'Full Model (Distribution)',  sprintf('Actual Metric P-Val (Full Model): %0.3g', PVAL), 'Significance Threshold (Full Model)', 'Actual Metric (Full Model)' });  
                              if ~isempty(Result.NXLAB) 
                               hold on 
                             [PVAL2, MET2, MET_perm2] =  histogram(handles, featurelist, Result.AUC_N, Result.ACC_N, Result.AUC_NPN, Result.ACC_NPN, 'red', 'm', ...
                                   Result.nRandom, Result.modelType, var, Result.var_case, thresh, Result.NXLAB); 
                                legend({ 'Full Model (Distribution)',  sprintf('Actual Metric P-Val: %0.3g', PVAL)      , 'Significance Threshold (Full Model)', 'Actual Metric (Full Model)', ...
                                              'Nuisance Model Only (Distribution)',   sprintf('Actual Metric P-Val (Nuisance Model Only) : %0.3g', PVAL2)     , 'Significance Threshold (Nuisance Model Only)', 'Actual Metric (Nuisance Only Model)'});
        
                              end
        end
    
elseif  any(regexp(Result.modelType, 'regression$'))
        switch plotName   
                case 'Scatter Plot'
                   cla reset
                        [Y, PRED, R] = scatter_plot(handles, featurelist, Result.YPRED, Result.Y, Result.R, 'b', thresh, [], [], var, Result.var_case); 
                          set(handles.alt_metric ,'Visible','off') ;
                               legend({'Full Model', sprintf('R2: %0.3g', R)});
                                grid minor
                                if ~isempty(Result.NXLAB)    
                                    set(handles.alt_metric ,'Visible','on','Enable','on') ; 
                                    metric = {'Full & Nuisance Model', 'Full Model', 'Nuisance Only Model'};
                                    set(handles.alt_metric, 'String', metric);
                                    metricSelected = get(handles.alt_metric,'Value');
                                                cla reset
                                               [Y, PRED, R] =  scatter_plot(handles, featurelist, Result.YPRED, Result.Y, Result.R, 'b', thresh, [], [], var, Result.var_case);
                                                hold on 
                                               [Y2, PRED2, R2] =    scatter_plot(handles, featurelist, Result.YNPRED, Result.Y, Result.RC, 'r', thresh, Y, PRED, var, Result.var_case);
                                                legend({'Full Model', sprintf('R2: %0.3g', R), 'Nuisance Model Only', sprintf('R2: %0.3g', R2)});
                                                grid minor
                                            if metricSelected == 2 
                                                  cla reset
                                                  [Y, PRED, R] =  scatter_plot(handles, featurelist, Result.YPRED, Result.Y, Result.R, 'b', thresh, [], [], var, Result.var_case);
                                                   legend({'Full Model', sprintf('R2: %0.3g', R)});
                                                   grid minor
                                            elseif metricSelected == 3 
                                                  cla reset
                                                 [Y2, PRED2, R2] =    scatter_plot(handles, featurelist, Result.YNPRED, Result.Y, Result.RC, 'r', thresh, [], [], var, Result.var_case);
                                                  legend({'Nuisance Only Model', sprintf('R2: %0.3g', R2)});
                                                  grid minor
                                            end          
                                end      
                  
                 
                case 'Residuals Plot'
                  cla reset
                      [RSDL, PRED] = residuals_plot(handles, featurelist, Result.YPRED, Result.Y, 'b', var, [], [], Result.var_case, thresh);
                          legend({ 'Full Model', 'Zero Line'});
                          set(handles.alt_metric ,'Visible','off') ;
                              grid minor
                                if ~isempty(Result.NXLAB)   
                                    set(handles.alt_metric ,'Visible','on','Enable','on') ; 
                                    metric = {'Full & Nuisance Model', 'Full Model', 'Nuisance Only Model'};
                                    set(handles.alt_metric, 'String', metric);
                                    metricSelected = get(handles.alt_metric,'Value');
                                                 cla reset
                                            [RSDL, PRED] = residuals_plot(handles, featurelist, Result.YPRED, Result.Y, 'b', var, [], [], Result.var_case, thresh);
                                                hold on 
                                            [RSDL2, PRED2] = residuals_plot(handles, featurelist, Result.YNPRED, Result.Y, 'r', var, RSDL, PRED, Result.var_case, thresh);
                                              legend({ 'Full Model', 'Zero Line', 'Nuisance Model Only'});
                                               grid minor
                                            if metricSelected == 2 
                                                cla reset
                                             [RSDL, PRED] = residuals_plot(handles, featurelist, Result.YPRED, Result.Y, 'b', var, [], [], Result.var_case, thresh);
                                                  legend({ 'Full Model', 'Zero Line'});
                                                  grid minor
                                            elseif metricSelected == 3 
                                                  cla reset
                                            [RSDL2, PRED2] = residuals_plot(handles, featurelist, Result.YNPRED, Result.Y, 'r', var, [], [], Result.var_case, thresh);
                                                  legend({ 'Nuisance Model Only', 'Zero Line'});
                                                  grid minor
                                            end          
                                end      
                                
                case 'Feature Weights'                      % set same for Regression and Classification 
                  cla reset
                  [FEATURE, WEIGHTS, P_VALUES_P, P_VALUES_NP] = feat_weights(handles, featurelist, Result.XLAB, Result.W, Result.PWF, Result.NPW, Result.nRandom, fun, Result.isHalf, thresh, var, Result.var_case, Result.NXLAB, Result.Outcome);
                
                  
                case 'Histogram (Permutation Performance)'  % set same for Regression and Classification 
                  cla reset               
                  [PVAL, MET, MET_perm] =  histogram(handles, featurelist, Result.R, [], Result.RR, [], 'blue', 'c', ...
                          Result.nRandom, Result.modelType, var, Result.var_case, thresh, Result.NXLAB);
                          legend({ 'Full Model (Distribution)',  sprintf('Actual Metric P-Val (Full Model): %0.3g', PVAL), 'Significance Threshold (Full Model)', 'Actual Metric (Full Model)' });  
                              if ~isempty(Result.NXLAB) 
                               hold on 
                          [PVAL2, MET2, MET_perm2] =   histogram(handles, featurelist, Result.RC, [], Result.RRC, [], 'red', 'm', ...
                                   Result.nRandom, Result.modelType, var, Result.var_case, thresh, Result.NXLAB);
                               
                                legend({ 'Full Model (Distribution)',  sprintf('Actual Metric P-Val (Full Model): %0.3g', PVAL)      , 'Significance Threshold (Full Model)', 'Actual Metric (Full Model)', ...
                                              'Nuisance Model Only (Distribution)',   sprintf('Actual Metric P-Val (Nuisance Only Model): %0.3g', PVAL2)     , 'Significance Threshold (Nuisance Model Only)', 'Actual Metric (Nuisance Only Model)'});
                               
                              end
         end
end     
             
axes(handles.ResultAxes);   % switch back to main ResultAxes 

%%  Export ML Results to CSV or Excel Spreadsheet %%%%%%%%% 
         % DATA.Properties.VariableNames = {'Variable1', 'Variable2'} 
         % if unequal, use padcat 
         % simplify script (!) => for loops 

% fetch output of current function called   
if get(handles.export_btn, 'Value') == 1
  if ~verLessThan('matlab', '8.3')
     if  any(regexp(Result.modelType, 'classification$'))    %% CLASSIFICATION DATA 
        switch plotName
                case 'ROC curve'  
                           if ~isempty(Result.NXLAB)     
                               DATA = padcat([TPR2(1:length(TPR))], [FPR2(1:length(TPR))], [TPR2(length(TPR):end)], [FPR2(length(TPR):end)], ...
                                   [AUC], [AUC2], [PVAL], [PVAL2]);
                               DATA = table( [DATA(:,1)], [DATA(:,2)], [DATA(:,3)], [DATA(:,4)], [DATA(:,5)], [DATA(:,6)], [DATA(:,7)], [DATA(:,8)] );
                                   
                           else
                                    DATA = padcat([TPR],[FPR], [AUC], [PVAL] ); 
                                    DATA = table( [DATA(:,1)], [DATA(:,2)], [DATA(:,3)], [DATA(:,4)]  );
                                 if Result.nRandom > 0 
                                     DATA.Properties.VariableNames = {'TPR', 'FPR', 'AUC', 'PVAL_PN'};
                                 else 
                                     DATA.Properties.VariableNames =  {'TPR'  'FPR' 'AUC' 'PVAL_P'};
                                 end
                           end
                           
                case 'Precision-Recall Curve'  
                       if ~isempty(Result.NXLAB)     
                               DATA = padcat([PREC2(1:length(PREC))], [RECALL2(1:length(PREC))], [PREC2(length(PREC):end)], [RECALL2(length(PREC):end)], [AUC], [AUC2]);
                               DATA = table(   [DATA(:,1)], [DATA(:,2)], [DATA(:,3)], [DATA(:,4)], [DATA(:,5)], [DATA(:,6)] );
                               DATA.Properties.VariableNames =  {'PREC' 'RECALL' 'PREC_Nui' 'RECALL_Nui' 'AUC' 'AUC_Nui'};                 
                       else
                               DATA = padcat([PREC], [RECALL], [AUC]);
                               DATA = table( [DATA(:,1)], [DATA(:,2)], [DATA(:,3)] );
                               DATA.Properties.VariableNames =  {'PREC' 'RECALL' 'AUC'};   
                       end
                           
                case 'Confusion matrix'      %% fix to combine for nuisance 
                     if ~isempty(Result.NXLAB)  &&   metricSelected == 3               
                        DATA = table([c_mat], [c_mat2]);                    
                     else
                         DATA = table([c_mat]);
                       
                     end
                     
                case 'Feature Weights' 
                        if Result.nRandom > 0 
                       DATA = table([FEATURE], [WEIGHTS], [P_VALUES_P], [P_VALUES_NP]);                     
                        else
                       DATA = table([FEATURE], [WEIGHTS], [P_VALUES_P]);             
                        end      
                        
            case 'Histogram (Permutation Performance)' 
                     if ~isempty(Result.NXLAB) 
                      DATA = padcat( [PVAL], [MET], [MET_perm], [PVAL2], [MET2], [MET_perm2]); 
                      DATA = table( [DATA(:,1)], [DATA(:,2)], [DATA(:,3)], [DATA(:,4)], [DATA(:,5)], [DATA(:,6)] );
                      DATA.Properties.VariableNames =  {'PVAL' 'MET' 'MET_perm', 'PVAL_Nui' 'MET_Nui' 'MET_perm_Nui',}; 
                     else
                      DATA = padcat( [PVAL], [MET], [MET_perm] );
                      DATA = table( [DATA(:,1)], [DATA(:,2)], [DATA(:,3)] );
                      DATA.Properties.VariableNames =  {'PVAL' 'MET' 'MET_perm'}; 
                     end
        end
      
    elseif  any(regexp(Result.modelType, 'regression$'))  %% REGRESSION DATA 
        switch plotName   
                    case 'Scatter Plot'
                              if ~isempty(Result.NXLAB)          
                                  DATA = padcat([Y2(1:length(PRED))], [PRED2(1:length(PRED))], [Y2(length(PRED)+1:end)], [PRED2(length(PRED)+1:end)], [R(:, thresh)], [R2]); 
                                  DATA = table( [DATA(:,1)], [DATA(:,2)], [DATA(:,3)], [DATA(:,4)], [DATA(:,5)], [DATA(:,6)] );
                                  DATA.Properties.VariableNames =  {'Actual', 'Predicted', 'Actual_Nui', 'Predicted_Nui', 'R2', 'R2_Nui'};               
                              else
                                 % error on PC J multiple thresholds 
                                  DATA = padcat([Y], [PRED], [R]); 
                                  DATA = table( [DATA(:,1)], [DATA(:,2)], [DATA(:,3)]);
                                  DATA.Properties.VariableNames =  {'Actual', 'Predicted', 'R2'};               
                              end

                    case 'Residuals Plot'
                               if ~isempty(Result.NXLAB)         
                                  DATA = padcat([RSDL2(:,1)], [PRED2(:,1)], [RSDL2(:,2)], [PRED2(:,2)]); 
                                  DATA = table( [DATA(:,1)], [DATA(:,2)], [DATA(:,3)], [DATA(:,4)] );
                                  DATA.Properties.VariableNames =  {'SD_Resid', 'Predicted', 'SD_Resid_Nui', 'Predicted_Nui'};               
                             else
                                  DATA = padcat([RSDL], [PRED]); 
                                  DATA = table( [DATA(:,1)], [DATA(:,2)] );
                                  DATA.Properties.VariableNames =  {'SD_Resid', 'Predicted'};               
                               end

                    case 'Feature Weights' 
                                if Result.nRandom > 0 
                                   DATA = table([FEATURE], [WEIGHTS], [P_VALUES_P], [P_VALUES_NP]);   
                                else
                                    DATA = table([FEATURE], [WEIGHTS], [P_VALUES_P]);
                                end

                case 'Histogram (Permutation Performance)' 
                             if ~isempty(Result.NXLAB) 
                                  DATA = padcat( [PVAL], [MET], [MET_perm], [PVAL2], [MET2], [MET_perm2]); 
                                  DATA = table( [DATA(:,1)], [DATA(:,2)], [DATA(:,3)], [DATA(:,4)], [DATA(:,5)], [DATA(:,6)] );
                                  DATA.Properties.VariableNames =  {'PVAL' 'MET' 'MET_perm', 'PVAL_Nui' 'MET_Nui' 'MET_perm_Nui',}; 
                             else
                                  DATA = padcat( [PVAL], [MET], [MET_perm] );
                                  DATA = table( [DATA(:,1)], [DATA(:,2)], [DATA(:,3)] );
                                  DATA.Properties.VariableNames =  {'PVAL' 'MET' 'MET_perm'}; 
                             end
        end 
    
    end
 
            if ~verLessThan('matlab', '8.3')
                [fname, ~] = uiputfile({'.xlsx'; '.csv'}); % Type in name of file.
                 writetable(DATA, fname);
            else %2014a or older
                 % do custom solution later  
            end
         
  else % Matlab versions below 2013b dont have table funct.
         % Solution for export data, older matlab versions 
  end
            
end

guidata(hObject, handles);


%% Plot Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ROC Curve Plot (Classification)
function [TPR, FPR, STAT, P_VAL] = ROC_curve(handles, featurelist, PRED, Y, AUC, PP, NP, nRandom, LineColor, TPR1, FPR1, var, thresh)
% Preps and plots Receiver Operating Characteristic curve 
% Input arguments %%%%% 
% handles:GUI handles
% featurelist: list of features used in prediction
% PRED: Predicted Outcome 
% Y: Actual Measure 
% AUC: Area under the curve 
% PP: Parametric P-Value for ROC
% NP: Non Parametric P-Value for ROC 
% Input mode: Full model or Nuisance Model (based on nuisance covariates only)

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
set(C1, 'Color', LineColor)
set(C1b, 'Color', LineColor);

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
STAT = AUC;                                        

% hovertext set
LAB = {'FPR', 'TPR'};
PlotType = 1;
PlotName = 'ROC';
 %optional, add choice later
set(gca,'FontName', 'Courier');

   TPR = [TPR1; TPR];
   FPR = [FPR1; FPR];

    % STAT and P_VAL overwritten 
      set(handles.ResultFig,'WindowButtonMotionFcn', ...
{@pressML,handles,PlotType, FPR, TPR, STAT, P_VAL, LAB, PlotName}); 

%% PR Curve Plot (Classification)
function  [PREC, RECALL, AUC] = PR_curve(handles, featurelist, PRED, Y, LineColor, PREC1, RECALL1, var, thresh)
% Preps and plots Receiver Operating Characteristic curve 
% Input arguments %%%%% 
% handles:GUI handles
% featurelist: list of features used in prediction
% PRED: Predicted Outcome 
% Y: Actual Measure 
% Input mode: Full model or Nuisance Model (based on nuisance covariates only) 
     
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
set(C1a, 'Color', LineColor);
hold on
C1 = plot(RECALL, PREC, 'o');
set(C1,'LineWidth', 2);
set(C1, 'Color', LineColor); 

AUC = trapz(RECALL, PREC);  %AUC PR calculated manually 
xlim([0 1.05]);
ylim([0 1.05]);                 % correct axis limits so plot allows border visual

xlabel({''; 'Recall (TPR)'; ''});
ylabel({'Precision (PPV)'; ''});
title({'Precision-Recall Curve'; ''});

% fix hover tool -- p values
LAB = {'RECALL', 'PREC'};
PREC = [PREC1; PREC];
RECALL = [RECALL1; RECALL];

PlotType = 1;     %ie plot with line or trend 
PlotName = 'PR'; 
set(handles.ResultFig,'WindowButtonMotionFcn', ...
{@pressML,handles,PlotType,RECALL, PREC, [], [], LAB, PlotName});   

%% Confusion Matrix Plot (Classification)
function [c_mat] = c_matrix(handles, featurelist, PRED_, NPRED_, Y, YLAB, var, thresh, var_case)
%visualize confusion matrix (summed across k folds)
%representing all instances
set(handles.HideNSig_Check,'Enable','off');
set(handles.correction_type, 'Value', 1);
set(handles.L_Graph,'String',{'All' featurelist{:}},'Enable','inactive', 'Value', 1); 
set(handles.L_brain,'String',handles.BrainStrings, 'Enable','inactive');
set(handles.L_thresh,'String',handles.thresholds, 'Enable','on');
    if isempty(handles.thresholds)  && isempty(strmatch( 'corr_area', featurelist))
       set(handles.L_brain,'String',[], 'Enable','off');
    end
set(handles.AlphaLevel ,'Enable','off') ;
set(handles.PValues ,'Enable','off') ;
set(handles.L_thresh,'Max',1,'Min',0);
colormap(handles.ResultAxes,'default')

YLAB = YLAB(:, var);
if ~isempty(NPRED_) 
    PRED_ = NPRED_(:, var);
elseif var_case == 1 
    PRED_ = PRED_(:, var);  
else 
    PRED_ = PRED_(:, thresh, var);
end 
Y= Y(:, var);
[~,~,~,~, c_mat] = conf_mat(Y, PRED_);

%c_mat percentages of overall
c_mat_PC = (c_mat)/(length(PRED_)) *100;
cmap=  colormap([1 0 0; 0 1 0]);
colormap(handles.ResultAxes, cmap)
AI = [1 0; 0 1];
A = imagesc(AI);
%A = imagesc(c_mat);
A.AlphaData = .2;
hold on
x1 = [0 3];
y1 = [1.5 1.5];
x2 = [1.5 1.5];
y2 = [0 3];
GLH = plot(x1,y1,'Color','black','LineStyle','-');
GLV = plot(x2,y2,'Color','black','LineStyle','-');
set(GLH, 'LineWidth', 2);
set(GLV, 'LineWidth', 2);

textStrings = num2str(c_mat(:),'%0.2f');                            
%# Create strings from the matrix values
textStrings2 = num2str(c_mat_PC(:),'%0.2f');
textStrings = strtrim(cellstr(textStrings)) ;                       
%# Remove any space padding
textStrings2 = strtrim(cellstr(textStrings2));
textStrings2 = strcat({'( '},textStrings2,{'  % )'});
textStrings3 = {'TP'; '';''; 'FP'};
textStrings4 = {'FN';'';''; 'TN'};

[x,y] = meshgrid(1:length(unique(Y)));                                      
%# Create x and y coordinates for the strings

text(x(:),y(:),textStrings(:),   ...                         
    'HorizontalAlignment','center');
text(x(:),y(:)+0.1,textStrings2(:),   ...                        
    'HorizontalAlignment','center');
text(1.42, 1.5, textStrings3, 'FontWeight', 'bold');
text(1.55, 1.5, textStrings4, 'FontWeight', 'bold');

S1 = char(YLAB(1)); S1 = regexprep(S1,'_',' ');
S2 = char(YLAB(2)); S2 = regexprep(S2,'_',' ');

set(gca,'XTick',1:length(unique(Y)),...
'XTickLabel',{S1, S2, S1, S2});
xlabel('predicted class');
ylabel('actual class');


if ~verLessThan('matlab', '9.1') && ~ismac 
    set(gca, 'YTick',1:length(unique(Y)), ...
    'YTickLabel',{S1, S2, S1, S2},...
    'TickLength',[0 0])
    xlabel('predicted class');
    ylabel('actual class');
    YLP = get(gca,'YLabel');
    set(YLP,'Position',get(YLP,'Position') + [0.02 0 0]);  
   
    YLP = get(gca,'YLabel');
    ytickangle(90);
    set(gca,'FontName', 'Courier');
else % MATLAB <2016a
    txt1 = text(0.47 , 1.2  , S1);
    txt2 = text(0.47 , 2.2  , S2);
    set(txt1, 'Rotation', 90);
    set(txt2, 'Rotation', 90);
    set(gca, 'YTick', []);

end

     if ~verLessThan('matlab', '8.3')
           handles.PlotTable = table( [c_mat]);
         else
           handles.PlotTable = [c_mat];
     end

title('Confusion Matrix (Summed over Folds)');

%% Feature Weights Plot (Classification OR Regression)   
function [FEATURE, WEIGHTS, P_VALUES_P, P_VALUES_NP] = feat_weights(handles, featurelist, XLAB, W, PPW, NPPW, nRandom, fun, isHalf, thresh, var, var_case, NCOV, Outcome)
% Setting up GUI options

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

% outcome field enable
% features field disable
% threshold field enable
% brain strings field disable
    
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
    if any(strcmp(sel_feat, 'corr_area'))   &&  (length(sel_feat) == 1) 
         % index raw matrix weights & pvals
            RM_index = cellfun(@(x)~isempty(strfind(x,'vs')), XLAB);
            SLAB = XLAB(RM_index);
            W =  W(RM_index);  
            P_VAL = P_VAL(RM_index); 
                corr_weights(handles, W, P_VAL, CORRECTION, isHalf, SLAB); %call nested function
 
%% SELECTED FEATURES 
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
          [P_VAL_S, ~] = SHAPE_PLOT(P_VAL_S, SLAB);
          [W_S, ~] = SHAPE_PLOT(W_S, SLAB);
          [STAT, SLAB] = SHAPE_PLOT(STAT, SLAB);
       
        end

   
%% Plot Selected Features 
    mask = ~isnan(STAT);  
    WP = imagesc(STAT);     %  or pcolor(STAT)
    set(WP, 'AlphaData', mask);

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
    
 if length(XLAB) == length(ORDER) 
     FEATURE= XLAB(ORDER); 
     FEATURE= FEATURE(:,:).';   
        P_VALUES_P=  P_VAL(ORDER);
    if nRandom > 0 
           P_VALUES_NP =  NPPW(ORDER);
        else 
           P_VALUES_NP =  [];
    end 
 else 
     % fix, exceptions 
 end 
      
    PlotType = 4;
    PlotName = 'W'; 
    set(handles.ResultFig,'WindowButtonMotionFcn', ...
    {@pressML,handles,PlotType, W_S, SLAB, P_VAL_S, [], [], PlotName});         
    end
 
%% Feature Weights (Corr Matrix Alone) 
function corr_weights(handles, W, P_VAL, CORRECTION, isHalf, SLAB)
% nested inside feature_weights function 
% displays feature weights for correlation matrix alone
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

    [W] = SHAPE_ML(handles,W, isHalf);
    [P_VAL] = SHAPE_ML(handles,P_VAL, isHalf);

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
    PlotName = 'W';
    set(handles.ResultFig,'WindowButtonMotionFcn', ...
    {@pressML,handles,PlotType, W, P_VAL, [], [], PlotName});         
       
%% Histogram Plot (Classification OR Regression) 
function [PVAL, MET, MET_perm] = histogram(handles, featurelist, MET1, MET2, MET1_PERM, MET2_PERM, PlotColor, PlotColor2, nRandom, modelType, var, var_case, thresh, NCOV)
% Plots Histogram for Classifier for Regressor metric 
% inputs: GUI handles, list of features, actual metric, permuted metric, 
%            plotcolors for full and nuisance model, 
%            number of permutations, modelType, nuisance conditional
set(gca,'FontName', 'Courier'); 
set(handles.L_Graph,'String',{'All' featurelist{:}},'Enable','inactive', 'Value', 1); 
set(handles.L_brain,'String',handles.BrainStrings, 'Enable','inactive'); 
set(handles.L_thresh,'String',handles.thresholds, 'Enable','on'); 
    if isempty(handles.thresholds)  && isempty(strmatch( 'corr_area', featurelist)) 
     set(handles.L_brain,'String',[], 'Enable','off'); 
    end 
    
set(handles.CorrectedAlpha ,'Enable','off')  ;
set(handles.alt_metric ,'Visible','on','Enable','on') ; 

    if  any(regexp(modelType, 'classification$'))
         metric = {'Area Under Curve (AUC)', 'Accuracy', 'Error'};
        % different if nuisance
    elseif any(regexp(modelType, 'regression$'))
        metric = []; 
        set(handles.alt_metric ,'Visible','off') ; 
        % different if nuisance
    end

set(handles.alt_metric, 'String', metric);
metricSelected = get(handles.alt_metric,'Value');


% fetch actual and permuted metric for different formats   
   if  any(regexp(modelType, 'classification$'))      
      [MET_perm, MET] = transform_metric (metricSelected, MET1, MET2, MET1_PERM, MET2_PERM, thresh, var, PlotColor2, var_case);
   else  
      [MET_perm, MET] = transform_metric (metricSelected, MET1, [], MET1_PERM, [], thresh, var, PlotColor2, var_case);
   end
   
 % determine if needs transformation 
[~, b] = size( MET_perm);
if b > 1
 MET_perm = MET_perm(:,:).';
end

   
total = [MET_perm; MET];

% calculate pval
D  = MET- MET_perm;
s=sign(D);
i_pos=sum(s(:)==1);
i_neg=sum(s(:)==-1);
% compare actual with null distr. 
PVAL = (i_neg+1) /(nRandom+1);                 
%Corrected Alpha Level", user can choose significance
np = str2num((get(handles.AlphaLevel, 'String'))) *100;       
vs=sort(total,'descend');
n=round(numel(total)*np/100)+1;
CPVal=vs(n);

% older versions

A=  histfit(total, nRandom);
%A = histogram(total)
 
hold on
set(A(1),'facecolor', PlotColor); set(A(2),'Visible','off');
% XL = get(gca, 'XLim');
% YL = get(gca, 'YLim');
% YL = YL(2);

BW = [];

if  any(regexp(modelType, 'classification$'))
   title('Classification performance (permutation distribution)');  
    if  metricSelected == 1
         xlim ([0 1]);
         XL = get(gca, 'XLim');
         BW = (XL(2)/nRandom)*100;   % adjust bin width
         xlab = xlabel('Area Under Curve'); 
    elseif metricSelected == 2
         xlim ([0 100]);       
         xlab = xlabel('Accuracy'); 
    elseif  metricSelected == 3
         xlim ([0 100]);
         xlab = xlabel('Error Percentage');  % fix x axis 
         
    end
else % regression 
      xlim ([0 1]);
      xlab = xlabel('R Squared'); 
      title('Regression performance (permutation distribution)');
      XL = get(gca, 'XLim');
      BW = (XL(2)/nRandom)*100; 

end 

if ~verLessThan('matlab', '8.3')
    XL = get(gca, 'XLim');
    if isempty(BW)
      BW = XL(2)/nRandom;   % adjust bin width
    end
    set(A(1), 'BarWidth', BW) ;
else
    %set(A(1), 'BarWidth', BW) ;
end

hold on

ylabel('Frequency');
%sig margin full model
sig= line([CPVal, CPVal], [ylim], 'Color', PlotColor2, 'LineStyle', ':', 'LineWidth', 2) ;   % older MATLAB

% real classifier
pline= line([MET MET],[ylim], 'Color', PlotColor, 'LineStyle', '--', 'LineWidth', 2);
y_lim = get(gca, 'YLim');
set(gca,'FontName', 'Courier'); % change font (optional)

L = (length(MET_perm)) -1;
N = NaN(L,1);
MET = [MET; N];


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

%% Performance Metrics Classification
function [c_met] = metrics_class(handles, PRED_, NPRED_, Y,  AUC, AUC_N, var, thresh, var_case)
% Classification performance metrics 
% inputs; PRED_: predicted class
%                 Y:   actual class

if var_case == 0
PRED_ = PRED_(:, thresh, var);
AUC= AUC(:,var);
    if ~isempty(NPRED_)
    AUC_N = AUC_N(:,var);
    end
else
AUC = AUC(var);
PRED_ = PRED_(:, var);
    if ~isempty(NPRED_)
        AUC_N = AUC_N(var);
    end
end 
Y= Y(:, var);

 if ~isempty(NPRED_)
 NPRED_ = NPRED_(:, var);
 end

[~,~,~,~, ~, c_met] = conf_mat(Y,PRED_);
c_met(7) = AUC;  % shouldnt have to do this, why are they different , what about accuracy? 

if ~isempty(NPRED_)
[~,~,~,~, ~, c_met2] = conf_mat(Y, NPRED_);
c_met2(7) = AUC_N;
c_met = [c_met; c_met2]; %combine
% replace AUC value with results AUC & nuisance also 
end

c_met = transpose(c_met);
[r, c] = size(c_met);                                           % dimensions

%# text location and labels
[xloc, yloc] = meshgrid(1:c,1:r);
xloc = xloc(:); yloc = yloc(:);
str = strtrim(cellstr( num2str(c_met(:),'%.3g') ));
str2 = {'%'; '%'; '%'; '%'; '%'; ''; ' ';' '};
str3 = {'%'; '%'; '%'; '%'; '%'; ''; ''; ''; '%'; '%'; '%'; '%'; '%'; ''; ''; ''};

mask =  c_met > 100;                                     
h = imagesc(1:c, 1:r, ones(size(c_met)));
set(h, 'AlphaData', mask);

set(gca,'XTick',1:8,...
'XTickLabel',{'Full','Nuisance'}); 

if ~verLessThan('matlab', '9.1') && ~ismac  % matlab 2016a or newer
  set(gca,'YTick', 1:r, ...
  'YTickLabel', {'Accuracy' 'Error' 'PPV/Prec' 'TPR/Sens.' 'TNR/Spec.' 'F1' 'AUC', 'MCC'});
  ytickangle(90);
  set(gca, 'FontSize', 8)
else
 % custom ylabel
          set(gca,'YTick', 1:r, ...
          'YTickLabel', {'ACC' 'ERR' 'PPV' 'TPR' 'TNR' 'F1' 'AUC', 'MCC'});
          set(gca, 'FontSize', 8)     
  % set(gca, 'YTick', []);
end

%# plot grid
xv1 = repmat((2:c)-0.5, [2 1]); xv1(end+1,:) = NaN;
xv2 = repmat([0.5;c+0.5;NaN], [1 r-1]);
yv1 = repmat([0.5;r+0.5;NaN], [1 c-1]);
yv2 = repmat((2:r)-0.5, [2 1]); yv2(end+1,:) = NaN;
line([xv1(:);xv2(:)], [yv1(:);yv2(:)], 'Color','k', 'HandleVisibility','off')

%# plot text
text(xloc, yloc, str, 'FontSize', 10 , 'HorizontalAlignment','center');

if isempty(NPRED_)
text(xloc+0.3, yloc, str2, 'FontSize', 10 , 'HorizontalAlignment','center');
else 
text(xloc+0.3, yloc, str3, 'FontSize', 10 , 'HorizontalAlignment','center');
end

t = title('Performance Metrics');

%% Performance Metrics Regression 
function [reg_tab] = metrics_reg(handles, PRED,R, NPRED, RC, Y, var, var_case, thresh)
% Classification performance metrics 
% inputs; PRED_: predicted values
%                 Y:   actual values
%                 R:   correlation 

if var_case == 0
PRED = PRED(:, thresh); 
%PRED = PRED(:, thresh, var); % conflict during multiple outcomes resolved
R = R(:, thresh, var);
elseif isempty(NPRED) 
PRED = PRED(:, var);
R = R(:, var);   
else    
PRED = PRED(:, var);
R = R(:, var);
end 
Y = Y(:, var);

% Coefficient of Determination (R Squared)
R2 = (R)^2 ;

n = length(PRED);

% RMSE or RMSD (Root Mean Squared Error or Deviation of Prediction)
RMSE = sqrt( sum((PRED- Y) .^ 2) / n ) ;

% RSE (relative standard error)  = (STD error/STD mean) *100
RSE =  sum((PRED - Y).^ 2) / sum((mean(Y) - Y).^ 2) ;

% Mean Absolute Error (MAE)  --Mean absolute percentage error
MAE = sum(abs(PRED - Y)) / n ;

% Relative Absolute Error (RAE)
RAE = (sum(    abs(PRED - Y)    ))     /   (sum(abs((mean(Y)) - Y))) ;      

NRMSD = (RMSE/(max(Y)- min(Y))) *100        ;  

% Coefficient of variation of the RMSD, CV(RMSD)
%CVRMSD = RMSE/(mean(Y)) ;
%combine into 1 table
reg_tab = [R2;RAE;RMSE;NRMSD;RSE;MAE];

if  ~isempty(NPRED)                                                          
    NPRED = NPRED(:, var);
 
    RMSE_N = sqrt( sum((NPRED- Y) .^ 2) / n ) ;
    RSE_N =  sum((NPRED - Y).^ 2) / sum((mean(Y) - Y).^ 2) ;    
    MAE_N = sum(abs(NPRED - Y)) / n ;
    
    RAE_N =  (sum(    abs(NPRED - Y)    ))     /   (sum(abs((mean(Y)) - Y)));
    NRMSD_N =        (RMSE_N/(max(Y)- min(Y))) *100;    
    R2_N = (RC(:, var))^2;   % atm RC only has 1 threshold
    
    reg_tab_N = [R2_N;RAE_N;RMSE_N;NRMSD_N;RSE_N;MAE_N];
    reg_tab = [reg_tab, reg_tab_N];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[r, c] = size(reg_tab) ;                                    
% text location and labels
[xloc, yloc] = meshgrid(1:c,1:r);
xloc = xloc(:); yloc = yloc(:);
str = strtrim(cellstr( num2str(reg_tab(:),'%.3g') ));
str2 = {''; ''; ''; '%'; '%'; '%'};
str3 = {''; ''; ''; '%'; '%'; '%'; ''; ''; ''; '%'; '%'; '%';};  

mask = reg_tab > 100;                                              
h = imagesc(1:c, 1:r, ones(size(reg_tab)));
set(h, 'AlphaData', mask);
                                       
% depends binary or multiclass metrics case...
set(gca,'XTick',1:6,...
'XTickLabel',{'Full','Nuisance'});

if ~verLessThan('matlab', '9.1') && ~ismac 
set(gca,'YTick', 1:r, ...
'YTickLabel', {'R2' 'RAE' 'RMSE' 'NRMSE' 'RSE' 'MAE'});
ytickangle(90);
 set(gca,'FontName', 'Courier');
else
% custom ylabel
set(gca,'YTick', 1:r, ...
'YTickLabel', {'R2' 'RAE' 'RMSE' 'NRMSE' 'RSE' 'MAE'});
 set(gca,'FontName', 'Courier');
    % set(gca, 'YTick', []);
end

%# plot grid
xv1 = repmat((2:c)-0.5, [2 1]); xv1(end+1,:) = NaN;
xv2 = repmat([0.5;c+0.5;NaN], [1 r-1]);
yv1 = repmat([0.5;r+0.5;NaN], [1 c-1]);
yv2 = repmat((2:r)-0.5, [2 1]); yv2(end+1,:) = NaN;
line([xv1(:);xv2(:)], [yv1(:);yv2(:)], 'Color','k', 'HandleVisibility','off')

 %# plot text
text(xloc, yloc, str, 'FontSize', 10 , 'HorizontalAlignment','center');
if isempty(NPRED) 
   text(xloc+0.3, yloc, str2, 'FontSize', 10 , 'HorizontalAlignment','center');
else
   text(xloc+0.3, yloc, str3, 'FontSize', 10 , 'HorizontalAlignment','center');
end

% ylabel('groups')
t = title('Performance Metrics');
set(t, 'FontSize', 10);

%% hover text function for ML
function pressML(o,e,handles,PlotType,LineX,LineY,LineStat,LineP, LAB, PlotName)

axes(handles.ResultAxes);
handles = guidata(handles.ResultFig);

Point3D = get(handles.ResultAxes, 'CurrentPoint');
Point = Point3D(1, 1:2);

X = get(handles.ResultAxes,'XLim');
Y = get(handles.ResultAxes,'YLim');
if (Point(1) > X(2) || Point(1) < X(1)) || (Point(2) > Y(2) || Point(2)< Y(1))
    return
end

if ~ishandle(handles.box) || ~strncmpi(get(get(get(handles.box,'Parent'),'Parent'),'Name'), 'Results', 7)
    handles.box = rectangle('Position',[0,0,1,1],'FaceColor','white');
    handles.htext = text(0,0,'','FontUnits','pixels','FontSize',12,'FontWeight','bold','Interpreter','none');
    guidata(handles.ResultFig, handles);
end

BoxSize = [diff(X) / 4 diff(Y) / 7];
BoxPoint = Point;
if Point(1) > X(1) + diff(X) / 2
    BoxPoint(1) = BoxPoint(1) - BoxSize(1);
end
if Point(2) > Y(1) + diff(Y) / 2
    BoxPoint(2) = BoxPoint(2) - BoxSize(2);
end

set(handles.box, 'Position', ...
    [BoxPoint BoxSize]);

show = false;

if PlotType == 1    %ROC, PR, Scatter, Residuals 
    Z = nan;
    show = true;

    EDIST = sqrt((Point(1) - LineX) .^ 2 + (Point(2) - LineY) .^ 2);
    [DX, IX] = min(EDIST(:));
    if abs(DX) < 1 / 25
        [X_, Y_, Z] = ind2sub(size(EDIST), IX);
    end

  if ~isfinite(Z)
        show = false;
 end
    if show
        LineStr = sprintf('%s : %05f\n%s : %05f\n', LAB{1}, LineX(X_, Y_, Z), LAB{2}, LineY(X_, Y_, Z));
        STATStr = [sprintf('\nAUC: %05f\n', LineStat(:, :, Z))];
        PStr  = ['P_Val: ' sprintf('%05f\n', LineP(:, :, Z))]; 
             if strcmp(PlotName, 'PR') || strcmp(PlotName, 'SC') || strcmp(PlotName, 'RS')
               S =  [LineStr];     
             else
               S =  [LineStr STATStr PStr ''];
             end
        set(handles.htext, ...
            'String', S, ...    
            'Position', BoxPoint + [diff(X) / 500 diff(Y) / 18]);
    end

elseif PlotType == 2
         % not used 
       
         
elseif PlotType == 3 % Feature Weights (corr_area)
   
    Indices = round(Point);
    YStr = handles.BrainStrings{Indices(2)}; %Yaxis
    XStr = handles.BrainStrings{Indices(1)}; %Xaxis
    WT= num2str( LineX(Indices(1), Indices(2))); % weight
    P_Val  =  num2str( LineY(Indices(1), Indices(2)));
    [YStr XStr WT P_Val];
        if isnan( LineX(Indices(2), Indices(1)))
            show = false;
        else
               S =  {YStr, XStr ,['WEIGHT: ' WT], ['PVAL:' P_Val]};
               show = true;
                set(handles.htext, ...
                'String', S , ...     
                'Position', BoxPoint + [diff(X) / 500 diff(Y) / 18]);
                show = true;
       end
   
elseif PlotType == 4 % Feature Weights (non corr_area)
   
     Indices = round(Point);
     PStr = (num2str( LineStat(Indices (2), Indices(1))));
     Stat = num2str( LineX(Indices(2), Indices(1)));
     SLAB=  char(LineY(Indices(2), Indices(1)));
         if isnan( LineX(Indices(2), Indices(1)))  % or is white 
               show = false;
         else
               S =  {SLAB, ['WEIGHT: ' Stat], ['PVAL: ' PStr]};
               set(handles.htext, ...
              'String', S , ...                                    
              'Position', BoxPoint + [diff(X) / 500 diff(Y) / 18]);                  
               show = true;
         end

end        
        
if show
    set(handles.htext, 'Visible', 'on');
    set(handles.box, 'Visible', 'on');
else
    set(handles.htext, 'Visible', 'off');
    set(handles.box, 'Visible', 'off');
end

%% Reshape Corr Matrix (Feature Weights)
function [STAT] = SHAPE_ML(handles,STAT, isHalf)
% Transforms Weights or P-value scores to corr matrix size
    if isHalf == 1
        %transform to fit brainstring x brainstring
        STAT_ = zeros(length(handles.BrainStrings), length(handles.BrainStrings));
        P_ = zeros(length(handles.BrainStrings), length(handles.BrainStrings));
        STAT_(~triu(ones(size(P_, 1)))) =  STAT(:, 1);    %fill in values
        STAT = STAT_ + STAT_' ;
    else
        STAT = reshape (STAT, [], length(handles.BrainStrings)); %keep non full corr matrix
    end

%% Reshape Feature Weights Values and Labels
function [STAT, SLAB] = SHAPE_PLOT(STAT, SLAB)
A = length(STAT);
A = length (SLAB);
 if A >=  10          
        if A >=  10     
            DW = 10;
        end

        if  A >= 500
        DW = 100;
        end

        C = mod(A, DW);
        R =  A - C;
        T = R/DW;
        STAT1 = STAT(1:R);
        STAT2 = STAT(R+1:end);   %remainder

        STAT3 = NaN(DW,1);
        STAT3= padcat(STAT2, STAT3);
        STAT3 = STAT3(:,1);
        STAT1 = [STAT1; STAT3];
        STAT = reshape (STAT1, DW, (T+1));


        SLAB2 = (cell((DW - C), 1));
        SLAB2(:) = {'NaN'};
        SLAB1 = [SLAB(1:end); SLAB2(1:end)];
        SLAB = reshape (SLAB1, DW, (T+1));     
 end
  
 
function [MET_perm, MET] = transform_metric (metricSelected, MET1, MET2, MET1_PERM, MET2_PERM, thresh, var, PlotColor2, var_case)
% transforms selected actual and null distribution metrics for histogram

%[~, b] = size(MET1);
    if PlotColor2 == 'c' && ~var_case %nuisance case 
        if metricSelected == 1
            MET = MET1(:, thresh, var);    % Accuracy OR R2
            MET_perm = MET1_PERM(:, thresh, :, var);
        elseif metricSelected == 2 
            MET = MET2(:, thresh, var);      % ie Area Under Curve 
            MET_perm = MET2_PERM(:, thresh, :, var);
        elseif metricSelected == 3 
            MET = 100 - MET2(:, thresh, var);      % ie Error 
            MET_perm = 100 - MET2_PERM(:, thresh, :, var);
        end 
        
         
    elseif PlotColor2 == 'm'  || var_case                                           %nuisance case or variable only 
        if metricSelected == 1
            MET = MET1(:, var);   % Accuracy OR R2
            MET_perm = MET1_PERM(:, :, var);
        elseif metricSelected == 2 
            MET = MET2(:, var);     % ie Area Under Curve 
            MET_perm = MET2_PERM(:, :, var);
        elseif metricSelected == 3 
            MET = 100 - MET2(:, var);    % ie Error 
            MET_perm = 100 - MET2_PERM(:, :, var);
        end                  
           
    end
  
% function [MET_perm, MET] = transform_metric_R (metricSelected, MET1, MET2, MET1_PERM, MET2_PERM, thresh, var, PlotColor2, var_case)    
%     
%      if PlotColor2 == 'c' && ~var_case %nuisance case 
%         if metricSelected == 1
%             MET = MET1(:, thresh, var);    % Accuracy OR R2
%             MET_perm = MET1_PERM(:, thresh, :, var);
%         elseif metricSelected == 2 
%             MET = MET2(:, thresh, var);      % ie Area Under Curve 
%             MET_perm = MET2_PERM(:, thresh, :, var);
%         elseif metricSelected == 3 
%             MET = 100 - MET2(:, thresh, var);      % ie Error 
%             MET_perm = 100 - MET2_PERM(:, thresh, :, var);
%         end 
%         
%          
%     elseif PlotColor2 == 'm'  || var_case                                           %nuisance case or variable only 
%         if metricSelected == 1
%             MET = MET1(:, var);   % Accuracy OR R2
%             MET_perm = MET1_PERM(:, :, var);
%         elseif metricSelected == 2 
%             MET = MET2(:, var);     % ie Area Under Curve 
%             MET_perm = MET2_PERM(:, :, var);
%         elseif metricSelected == 3 
%             MET = 100 - MET2(:, var);    % ie Error 
%             MET_perm = 100 - MET2_PERM(:, :, var);
%         end                  
%            
%     end


