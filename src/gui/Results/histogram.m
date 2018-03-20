
function [PVAL, MET, MET_perm] = histogram(handles, metricSelected, MET1, MET2, MET1_PERM, MET2_PERM, plotcolor, plotcolor2, nRandom, modelType, var, var_case, thresh)
%% Histogram Plot (Classification OR Regression) 
% Plots Histogram for Classifier for Regressor metric 
%
% handles: user selections in Results GUI 
% metricSelected: performance metric user choice 
% MET1: first metric (actual performance - overall)
% MET2: second metric (actual performance - overall) i.e. ACC
% MET1_PERM: first metric (permutation distribution - overall) i.e. random
% MET2_PERM: second metric (permutation distribution - overall)i.e. random
% plotcolor: color of full model plot 
% plotcolor2: color of nuisance only model plot 
% nRandom: number of permutations
% modelType: i.e. classification v. regression
% var: prediction outcome user selection (if multiple)
% var_case: determine if variable only feature mode 
% thresh: current user selected network threshold 


% fetch transformed actual and permuted metric for different formats   
   if  any(regexp(modelType, 'classification$'))      
      [MET_perm, MET] = transform_metric (metricSelected, MET1, MET2, MET1_PERM, MET2_PERM, thresh, var, plotcolor2, var_case);
   else  
      [MET_perm, MET] = transform_metric (metricSelected, MET1, [], MET1_PERM, [], thresh, var, plotcolor2, var_case);
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
set(A(1),'facecolor', plotcolor); set(A(2),'Visible','off');
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
         xlabel('Area Under Curve'); 
    elseif metricSelected == 2
         xlim ([0 100]);       
         xlabel('Accuracy'); 
    elseif  metricSelected == 3
         xlim ([0 100]);
         xlabel('Error Percentage');  % fix x axis 
         
    end
else % regression 
      xlim ([0 1]);
      xlabel('R Squared'); 
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
line([CPVal, CPVal], ylim, 'Color', plotcolor2, 'LineStyle', ':', 'LineWidth', 2) ;   % older MATLAB

% real classifier
line([MET MET], ylim, 'Color', plotcolor, 'LineStyle', '--', 'LineWidth', 2);
%y_lim = get(gca, 'YLim');

set(gca,'FontName', 'Courier'); % change font (optional)



end