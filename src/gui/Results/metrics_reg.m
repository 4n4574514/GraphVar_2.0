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
end