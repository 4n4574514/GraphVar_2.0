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
end