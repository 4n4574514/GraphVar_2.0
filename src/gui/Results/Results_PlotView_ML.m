
function Results_PlotView_ML(hObject,handles)
%% Plots results for classification and regression 
% called inside Results_PlotView
% Prepares ML Results GUI and data 
% Calls classification and regression plots functions (ML) 

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
                     [~] =  metrics_class(Result.YPRED_, [], Result.Y, Result.AUC, [], var, thresh, Result.var_case);
                elseif ~isempty(Result.NXLAB)
                     [~] = metrics_class(Result.YPRED_, Result.YNPRED_, Result.Y, Result.AUC, Result.AUC_N, var, thresh, Result.var_case);
                end
  elseif any(regexp(Result.modelType, 'regression$'))  % Parametric cases
                             plots = {'Scatter Plot', 'Residuals Plot', 'Feature Weights'};
                                    if  Result.nRandom > 0  % Permutation cases
                                             plots = {'Scatter Plot', 'Residuals Plot',  ...
                                                          'Feature Weights', 'Histogram (Permutation Performance)'};
                                    end      
                                    
               % set function call for performance_reg 
               if isempty(Result.NXLAB)
                    [~] = metrics_reg(Result.YPRED,Result.R, [], [], Result.Y, var, Result.var_case, thresh);
               elseif ~isempty(Result.NXLAB)
                   [~] = metrics_reg(Result.YPRED,Result.R, Result.YNPRED, Result.RC, Result.Y, var, Result.var_case, thresh);
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
                    
                    
                   % call ROC plots for different cases         
                        [TPR, FPR, AUC, PVAL] = roc_curve(PVal_selected, Result.YPRED, Result.Y, Result.AUC, Result.PP, Result.NP, Result.nRandom, 'blue', var, thresh); 
                        legend({ 'Full Model', sprintf('AUC: %0.3g', AUC), 'Chance Performance'});
                        set(handles.alt_metric ,'Visible','off') ;
                             if ~isempty(Result.NXLAB) % full model only 
                                 set(handles.alt_metric ,'Visible','on','Enable','on') ; 
                                 metric = {'Full & Nuisance Model', 'Full Model', 'Nuisance Only Model'};
                                 set(handles.alt_metric, 'String', metric);
                                 metricSelected = get(handles.alt_metric,'Value');
                                          cla reset  
                                          [TPR, FPR, AUC, PVAL]  = roc_curve(PVal_selected, Result.YPRED, Result.Y, Result.AUC, Result.PP, Result.NP, Result.nRandom, 'blue', var, thresh)
                                          hold on                   
                                          [TPR2, FPR2, AUC2, PVAL2]  = roc_curve(PVal_selected, Result.YNPRED, Result.Y, Result.AUC_N, Result.PPC(thresh), Result.NPC(thresh), Result.nRandom,'red', var, thresh)
                                          legend({'Full Model', sprintf('AUC: %0.3g', AUC), 'Chance Performance', 'Nuisance Model Only', sprintf('AUC: %0.3g', AUC2)});
                                          TPR = [TPR; TPR2]; FPR = [FPR; FPR2];  AUC = [AUC; AUC2]; PVAL = [PVAL; PVAL2];     
                                          grid minor % add grid as overwritten
                                        if metricSelected == 2 
                                                cla reset       
                                                [TPR, FPR, AUC, PVAL] = roc_curve(PVal_selected, Result.YPRED, Result.Y, Result.AUC, Result.PP, Result.NP, Result.nRandom, 'blue', var, thresh);
                                                legend({ 'Full Model', sprintf('AUC: %0.3g', AUC), 'Chance Performance'});
                                        elseif metricSelected == 3 
                                                cla reset
                                                [TPR, FPR, AUC, PVAL] = roc_curve(PVal_selected, Result.YNPRED, Result.Y, Result.AUC_N, Result.PPC, Result.NPC, Result.nRandom,'red',  var, thresh);
                                                legend({ 'Nuisance Only Model', sprintf('AUC: %0.3g', AUC), 'Chance Performance'});
                                        end  

                             end 
                                set(gca,'FontName', 'Courier');
                             % hovertext ROC
                                LAB = {'FPR', 'TPR'};
                                PlotType = 1;
                                PlotName = 'ROC';          
                                set(handles.ResultFig,'WindowButtonMotionFcn', ...
                                                        {@pressML,handles,PlotType, FPR, TPR, AUC, PVAL, LAB, PlotName});
                            
                case 'Precision-Recall Curve'  
                       cla reset                       
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
                    % call PR plots for different cases         
                       [PREC, RECALL, AUC] = pr_curve(Result.YPRED, Result.Y, 'blue', var, thresh); % transmit PR AUC (trapezoid method)
                           legend({ 'Full Model', sprintf('AUC: %0.3g', AUC)});
                          set(handles.alt_metric ,'Visible','off') ;
                                if ~isempty(Result.NXLAB)    
                                     set(handles.alt_metric ,'Visible','on','Enable','on') ; 
                                     metric = {'Full & Nuisance Model', 'Full Model', 'Nuisance Only Model'};
                                     set(handles.alt_metric, 'String', metric);
                                     metricSelected = get(handles.alt_metric,'Value');
                                              cla reset
                                              [PREC, RECALL, AUC] = pr_curve(Result.YPRED, Result.Y, 'blue', var, thresh);
                                              hold on 
                                              [PREC2, RECALL2, AUC2] = pr_curve(Result.YNPRED, Result.Y, 'red', var, thresh);
                                              PREC = [PREC; PREC2]; RECALL = [RECALL; RECALL2]; 
                                              legend({ 'Full Model', sprintf('AUC: %0.3g', AUC),  'Nuisance Only Model', sprintf( 'AUC: %0.3g', AUC2)});
                                              grid minor
                                            if metricSelected == 2 
                                                cla reset       
                                                [PREC, RECALL, AUC] = pr_curve(Result.YPRED, Result.Y, 'blue', var, thresh);
                                                legend({ 'Full Model', sprintf('AUC: %0.3g', AUC)});
                                            elseif metricSelected == 3 
                                                cla reset       
                                                [~, ~, AUC2]  = pr_curve(Result.YNPRED, Result.Y, 'red', var, thresh);
                                                legend({ 'Nuisance Only Model', sprintf('AUC: %0.3g', AUC2)});
                                            end          
                                end     
                             
                                LAB = {'RECALL', 'PREC'};
                                PlotType = 1;     %ie plot with line or trend 
                                PlotName = 'PR'; 
                                set(handles.ResultFig,'WindowButtonMotionFcn', ...
                                {@pressML,handles,PlotType, RECALL, PREC, [], [], LAB, PlotName});   

                case 'Confusion matrix'
                       cla reset
                       
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
                            colormap(handles.ResultAxes,'default');
                            cmap=  colormap([1 0 0; 0 1 0]);
                            colormap(handles.ResultAxes, cmap)
                            
                          % call confusion matrix plots for different cases  
                          [c_mat] = c_matrix(Result.YPRED_,[], Result.Y, Result.YLAB, var, thresh, Result.var_case);     
                          if ~isempty(Result.NXLAB)   
                                     clear metric 
                                     clear metricSelected
                                     cla reset
                                     metric = {'Full model','Nuisance Only Model', 'N/A'};
                                     set(handles.alt_metric, 'String', metric);
                                     metricSelected = get(handles.alt_metric,'Value');
                                     set(handles.alt_metric ,'Visible','on','Enable','on') ;
                                           if metricSelected == 1
                                           [c_mat] = c_matrix(Result.YPRED_,[], Result.Y, Result.YLAB, var, thresh, Result.var_case);  
                                           elseif metricSelected == 2
                                           [c_mat2] =  c_matrix([], Result.YNPRED_, Result.Y, Result.YLAB, var, [], Result.var_case);
                                           elseif metricSelected == 3
                                         %under construction (side by side)
                                           end          
                          end      
         
                case 'Feature Weights'                      % set same for Regression and Classification 
                  cla reset

                 % call feature weights plots (incl. NxN dimensions)
                  [W_S, SLAB, P_VAL_S, PlotType] = feat_weights(handles, featurelist, Result.XLAB, Result.W, Result.PWF, ...
                      Result.NPW, Result.nRandom, fun, Result.isHalf, thresh, var, Result.var_case, Result.Outcome);
                   
                  % set hovertext for feature weights conditional on
                  % display choice 
                   if PlotType == 4
                      set(handles.ResultFig,'WindowButtonMotionFcn', ...
                        {@pressML,handles,PlotType, W_S, SLAB, P_VAL_S, [], [], []});       
                   elseif PlotType == 3
                      set(handles.ResultFig,'WindowButtonMotionFcn', ...
                        {@pressML,handles,PlotType, W_S, P_VAL_S, SLAB, [], [], []}); 
                   end
           
              
               case 'Histogram (Permutation Performance)'  % set Classification 
                      cla reset
                      
                    set(gca,'FontName', 'Courier'); 
                    set(handles.L_Graph,'String',{'All' featurelist{:}},'Enable','inactive', 'Value', 1); 
                    set(handles.L_brain,'String',handles.BrainStrings, 'Enable','inactive'); 
                    set(handles.L_thresh,'String',handles.thresholds, 'Enable','on'); 
                     if isempty(handles.thresholds)  && isempty(strmatch( 'corr_area', featurelist)) 
                         set(handles.L_brain,'String',[], 'Enable','off'); 
                     end 

                    set(handles.CorrectedAlpha ,'Enable','off')  ;
                    set(handles.alt_metric ,'Visible','on','Enable','on') ; 

                      if  any(regexp(Result.modelType, 'classification$'))
                            metric = {'Area Under Curve (AUC)', 'Accuracy', 'Error'};
                            % different if nuisance
                      elseif any(regexp(Result.modelType, 'regression$'))
                            metric = []; 
                            set(handles.alt_metric ,'Visible','off') ; 
                            % different if nuisance
                      end

                    set(handles.alt_metric, 'String', metric);
                    metricSelected = get(handles.alt_metric,'Value');
                   
                     
              % call histogram plot classification 
                   [PVAL, MET, MET_perm] =  histogram(handles, metricSelected, Result.AUC, Result.ACC, Result.AUC_NP, Result.ACC_NP, 'blue', 'c', ...
                          Result.nRandom, Result.modelType, var, Result.var_case, thresh);
                          legend({ 'Full Model (Distribution)',  sprintf('Actual Metric P-Val (Full Model): %0.3g', PVAL), 'Significance Threshold (Full Model)', 'Actual Metric (Full Model)' });  
                              if ~isempty(Result.NXLAB) 
                               hold on 
                             [PVAL2, MET2, MET_perm2] =  histogram(handles, metricSelected, Result.AUC_N, Result.ACC_N, Result.AUC_NPN, Result.ACC_NPN, 'red', 'm', ...
                                   Result.nRandom, Result.modelType, var, Result.var_case, thresh); 
                                legend({ 'Full Model (Distribution)',  sprintf('Actual Metric P-Val: %0.3g', PVAL)      , 'Significance Threshold (Full Model)', 'Actual Metric (Full Model)', ...
                                              'Nuisance Model Only (Distribution)',   sprintf('Actual Metric P-Val (Nuisance Model Only) : %0.3g', PVAL2)     , 'Significance Threshold (Nuisance Model Only)', 'Actual Metric (Nuisance Only Model)'});
        
                              end
                              
                            % L = (length(MET_perm)) -1;
                            % N = NaN(L,1);
                            % MET = [MET; N];

                              
                              
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
                                % hovertext settings scatter plot
                                LAB = {'Predicted', 'Actual'};
                                PlotType = 1;
                                PlotName = 'SC';
                                set(handles.ResultFig,'WindowButtonMotionFcn', ...
                                {@pressML,handles,PlotType, PRED, Y, [], [], LAB, PlotName});
                  
                 
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
                                % hovertext settings residuals plot
                                LAB = {'Predicted', 'Std. Residual'};
                                PlotType = 1;
                                PlotName = 'RS'; 
                                set(handles.ResultFig,'WindowButtonMotionFcn', ...
                                {@pressML,handles,PlotType, PRED, RSDL, [], [], LAB, PlotName});
                                
                case 'Feature Weights'                      % set same for Regression and Classification 
                  cla reset
                  [W_S, SLAB, P_VAL_S, PlotType] = feat_weights(handles, featurelist, Result.XLAB, Result.W, Result.PWF, ...
                      Result.NPW, Result.nRandom, fun, Result.isHalf, thresh, var, Result.var_case, Result.Outcome);
                   
                  %% set hovertext for feature weights conditional on
                  % display choice 
                   if PlotType == 4
                      set(handles.ResultFig,'WindowButtonMotionFcn', ...
                        {@pressML,handles,PlotType, W_S, SLAB, P_VAL_S, [], [], []});       
                   elseif PlotType == 3
                      set(handles.ResultFig,'WindowButtonMotionFcn', ...
                        {@pressML,handles,PlotType, W_S, P_VAL_S, SLAB, [], [], []}); 
                   end
         
                   
                case 'Histogram (Permutation Performance)'  % for Regression
                  cla reset         
                  
                   set(gca,'FontName', 'Courier'); 
                    set(handles.L_Graph,'String',{'All' featurelist{:}},'Enable','inactive', 'Value', 1); 
                    set(handles.L_brain,'String',handles.BrainStrings, 'Enable','inactive'); 
                    set(handles.L_thresh,'String',handles.thresholds, 'Enable','on'); 
                     if isempty(handles.thresholds)  && isempty(strmatch( 'corr_area', featurelist)) 
                         set(handles.L_brain,'String',[], 'Enable','off'); 
                     end 

                    set(handles.CorrectedAlpha ,'Enable','off')  ;
                    set(handles.alt_metric ,'Visible','on','Enable','on') ; 

                      if  any(regexp(Result.modelType, 'classification$'))
                            metric = {'Area Under Curve (AUC)', 'Accuracy', 'Error'};
                            % different if nuisance
                      elseif any(regexp(Result.modelType, 'regression$'))
                            metric = []; 
                            set(handles.alt_metric ,'Visible','off') ; 
                            % different if nuisance
                      end

                    set(handles.alt_metric, 'String', metric);
                    metricSelected = get(handles.alt_metric,'Value');
                    
                 % call histogram plot classification 
                  [PVAL, MET, MET_perm] =  histogram(handles, metricSelected, Result.R, [], Result.RR, [], 'blue', 'c', ...
                          Result.nRandom, Result.modelType, var, Result.var_case, thresh);
                          legend({ 'Full Model (Distribution)',  sprintf('Actual Metric P-Val (Full Model): %0.3g', PVAL), 'Significance Threshold (Full Model)', 'Actual Metric (Full Model)' });  
                              if ~isempty(Result.NXLAB) 
                               hold on 
                          [PVAL2, MET2, MET_perm2] =   histogram(handles, metricSelected, Result.RC, [], Result.RRC, [], 'red', 'm', ...
                                   Result.nRandom, Result.modelType, var, Result.var_case, thresh);
                               
                                legend({ 'Full Model (Distribution)',  sprintf('Actual Metric P-Val (Full Model): %0.3g', PVAL)      , 'Significance Threshold (Full Model)', 'Actual Metric (Full Model)', ...
                                              'Nuisance Model Only (Distribution)',   sprintf('Actual Metric P-Val (Nuisance Only Model): %0.3g', PVAL2)     , 'Significance Threshold (Nuisance Model Only)', 'Actual Metric (Nuisance Only Model)'});
                               
                              end
         end
end     
             
axes(handles.ResultAxes);   % switch back to main ResultAxes 


if get(handles.export_btn, 'Value') == 1
    export_btn_ml(hObject,handles, Result.modelType, plotName, Result.NXLAB, metricSelected)
end






%% hover text function for ML plots 
function pressML(~,~,handles,PlotType,LineX,LineY,LineStat,LineP, LAB, PlotName)
% display hover text in overlay box for live plot metrics 


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

BoxSize = [diff(X) / 3.5 diff(Y) / 7];
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
 
    if  any(isnan(LineP))
          show = false;  % hide if missing permutation P-values
    end
    
    if show
        
        LineStr = sprintf('%s : %05f\n%s : %05f\n', LAB{1}, LineX(X_, Y_, Z), LAB{2}, LineY(X_, Y_, Z));
       
             if strcmp(PlotName, 'PR') || strcmp(PlotName, 'SC') || strcmp(PlotName, 'RS')
               S =  [LineStr];     
             else
                STATStr = [sprintf('\nAUC: %05f\n', LineStat(1))];
                PStr  = ['P_Val: ' sprintf('%05f\n', LineP(1))];
            if length(LineP) > 1
                STATStr = [sprintf('\nAUC: %05f', LineStat(1)), '      ',sprintf('AUC(Nui): %05f\n', LineStat(2)) ];  
                PStr  = ['P_Val: ' sprintf('%05f', LineP(1)), '    ','P_Val(Nui): ' sprintf('%05f\n', LineP(2))];
            end              
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
    WT= num2str( LineX(Indices(1), Indices(2)));  % weight
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



