
function [c_mat] = c_matrix(PRED_, NPRED_, Y, YLAB, var, thresh, var_case)
%% Confusion matrix (Classification)
% confusion matrix across sum of all K-folds.
% 
% PRED_: predicted class label value (1 or 2)
% NPRED_:  predicted class label value (1 or 2) - nuisance only model
% Y: actual label 
% YLAB: class/label names/tags
% var: prediction outcome user selection (if multiple)
% thresh: current user selected network threshold
% var_case: determine if variable only feature mode 


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

title('Confusion Matrix (Summed over Folds)');
end
