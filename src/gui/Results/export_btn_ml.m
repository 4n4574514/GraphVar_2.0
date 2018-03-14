function [outputArg1,outputArg2] = export_btn_ml(hObject,handles, modelType, plotName, NXLAB, metricSelected)
%% Export data for machine learning plots  
% fetches output from current function called (i.e. plot chosen) 


  %% Export Regression plot data   
  if ~verLessThan('matlab', '8.3')
     if  any(regexp(modelType, 'classification$'))   
        switch plotName
                case 'ROC curve'  
                         
                           
                case 'Precision-Recall Curve'  
                     
                           
                case 'Confusion matrix'      
                    
                     
                case 'Feature Weights' 
                      
                        
                case 'Histogram (Permutation Performance)' 
                    
        end
    
    %% Export Regression plot data     
    elseif  any(regexp(Result.modelType, 'regression$'))  
        switch plotName   
                    case 'Scatter Plot'
                             

                    case 'Residuals Plot'
                              

                    case 'Feature Weights' 
                              

                case 'Histogram (Permutation Performance)' 
                           
        end 
    
    end
 
           
         
  else % 2014 or older 
         
  end
            




end

