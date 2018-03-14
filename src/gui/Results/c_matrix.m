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
end
