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
end