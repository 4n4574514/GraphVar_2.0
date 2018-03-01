%  This file is part of GraphVar.
% 
%  Copyright (C) 2016 Lea Waller and the GraphVar team
% 
%  GraphVar is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
% 
%  GraphVar is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
% 
%  You should have received a copy of the GNU General Public License
%  along with GraphVar.  If not, see <http://www.gnu.org/licenses/>.

function Results_PlotView(hObject,handles)
%*************************************************************************%
%1.) Get the Filter Vars and decide what to plot where to ****************%
%*************************************************************************%
global result_path;
global result_folder;
global isNetFuncGUI;

%% Switch to ML mode 			
doML = strncmp(handles.Files{1}, 'ML', 2); 			
  if doML 			
      ML_ResultsPlots(hObject,handles) 			
  else  
     
cla(handles.ResultAxes,'reset');
plotP = get(handles.PValues,'Value');

% Set gloabaly available result variables to []
handles.plotX = [];         % Variable on x axes
handles.plotLines  = [];    % Variable which is displayed throu different lines
handles.plotOne = [];       % Variable which is set to a singluar value
handles.Result  = [];       % r matrix
handles.Result2 = [];       % p matrix

set(handles.export_btn,'Visible','on'); % Make export Button visible
set(handles.HideNSig_Check,'Visible','off') % IS THIS NEEDED ?!?
set(handles.Var2,'Visible','off')       % hide the filter (will be shown only when plot type 1)
set(handles.show_random,'Visible','off');

set(handles.GroupTestChooser,'Visible','off')

set(handles.showGroupVal_check,'Visible','off');
set(handles.AllGroups,'Visible','off');
set(handles.AnovaSig,'Visible','off');

alphaStr = get(handles.AlphaLevel,'String');    % Get the alpha level from text field
alphaLvl = str2double(alphaStr);                % to number
if(isnan(alphaLvl) || alphaLvl < 0 || alphaLvl > 1) % If not a number show error and exit
    msgbox('This is not a valid Alpha Level');
    return;
end

[thresh,fun,var,brain] = Results_Filters(hObject,handles);  % Get filter fields returned vars will
handles.brainSelect = brain;

% % contain indexes of items to be shown
% if(length(fun)~=1)                                  % If not only one function is selected,
%     [~,fun2] = ismember(handles.globFunc(:,2),handles.functionList); % set index to correspond to the globalFunc filed
%     fun2(fun2 == 0) = []; %delete zero fields
%     fun = intersect(fun,fun2);
%     
%     
%     Vale = get(handles.L_Graph,'Value');
%     
%     C = setdiff(Vale,fun+1);
%     
%     if(~isempty(C))
%         if(C(1) ==1)
%             set(handles.L_Graph,'Value',  unique(fun+1));
%         else
%             set(handles.L_Graph,'Value',  intersect(fun+1,Vale));
%         end
%         Results_PlotView(hObject,handles);
%         return;
%     end
% end

filterFieldStrings{1} = handles.vars(var);             % Val contains the strings of the filter fields
filterFieldStrings{2} = handles.functionList(fun);

is2DFunction = find(ismember(filterFieldStrings{2},{handles.netFunc{:}, handles.twoDFunc{:}})>0);  % check if the selected Function is special 2D One (example: pure network)

isNetFunc = find(ismember(filterFieldStrings{2},{handles.netFunc{:}, 'bn_var'})>0);  % check if the selected Function is special 2D One (example: pure network)

if isNetFunc
    if ~isNetFuncGUI
        set(handles.L_thresh,'String',handles.ConnectivityThr);
        set(handles.L_thresh,'Value',1);
        if ismember(filterFieldStrings{2},{'bn_var'})
            set(handles.btn_network,'Visible','off'); % Make export Button visible 
        else
            set(handles.btn_network,'Visible','on'); % Make export Button visible
        end
        isNetFuncGUI = 1;
        return;
    else
        filterFieldStrings{3} = {handles.ConnectivityThr(thresh)};
    end
else
    if(isNetFuncGUI)
        set(handles.L_thresh,'String',handles.thresholds);
        set(handles.L_thresh,'Value',1);
        set(handles.btn_network,'Visible','off'); % Make export Button visible
        isNetFuncGUI = 0;
        return;
    else
        filterFieldStrings{3} = handles.thresholds(thresh);
    end
end
filterFieldStrings{4} = handles.BrainStrings(brain);

if (((length(thresh)==1)+(length(fun)==1)+(length(var)==1) == 0)||(((length(thresh)==1)+(length(fun)==1)+(length(var)==1) < 3)&&~isempty(is2DFunction))) % If there is not at least one singular field
    cla(handles.ResultAxes,'reset')                             % Show error: put more filters
    text(0.15,0.55,'Please Filter Variables','FontSize',55);
    set(handles.export_btn,'Visible','off');
    return;
end

nonSingularFields = []; % Variables to be plotted (non singular) will be indexed
% (1 = Varialbes, 2 = Functions, 3 = Thresholds)
Vars = {'Variable','GraphVar','Threshold','Brain Area'};

if(length(thresh)~=1)   % there is more than one threshold
    nonSingularFields(end+1) = 3;    % Add threshold to the Items to be plotted
end
if(length(fun)~=1)      % more than one function
    nonSingularFields(end+1) = 2;    % so we add it
end
if(length(var)~=1)      % more than one variable
    nonSingularFields(end+1) = 1;    % ... add it
end

nonSingularFieldNames = Vars(nonSingularFields);  % Names of non singular vars
set(handles.Var2,'String',nonSingularFieldNames); % set Var selection field for X-Axes to
% available non singular vars

if(length(nonSingularFields) == 1)    % Only one non singular field
    fieldOnXAxes = nonSingularFields;
    fieldAsLines = 0;
elseif isempty(nonSingularFieldNames)  % There is no singular field
    if~isempty(is2DFunction)
        fieldOnXAxes  = 4;
        fieldAsLines  = [];
    else
        cla(handles.ResultAxes,'reset')
        text(0.15,0.55,'Please deselect at least one filter','FontSize',40);
        set(handles.export_btn,'Visible','off');
        return;
    end
else % There are 2 non Singular
    [~,fieldOnXAxes] = ismember(nonSingularFieldNames(get(handles.Var2,'Value')),Vars); % Get the field selected in the X-Axes field
    fieldAsLines  = nonSingularFields;
    fieldAsLines(get(handles.Var2,'Value')) = [];   % Set the other to the Line (by assigning both and deleting the one on the X-Axes)
end

if(fieldOnXAxes ~= 4)% If there are the brainareas on x-axes all fields are singular
    singularFields = find(1:3 ~= fieldOnXAxes);
    singularFields = singularFields(singularFields ~= fieldAsLines); % idx = index of the field which is sigular
else
    singularFields = 1:3;
end

handles.plotX  = filterFieldStrings(fieldOnXAxes);     % set the global plotX (what do we plot on the X-Axes) to the string
if(fieldAsLines > 0 )
    handles.plotLines  = filterFieldStrings(fieldAsLines); % same for the line
elseif ( fieldAsLines == 0 )
        handles.plotLines = {filterFieldStrings(nonSingularFields)};
else
        handles.plotLines = {' '};
end
handles.plotOne ={};
if(length(singularFields) == 1) % One Singular Field
    handles.plotOne = filterFieldStrings{singularFields};   % set the global Variable
else
    handles.plotOne =  filterFieldStrings{1};
    for i=2:length(singularFields)
        handles.plotOne = {handles.plotOne{:} ' X ' filterFieldStrings{i}{:}};
    end
end

SHOW_RANDOM = get(handles.show_random,'Value') && get(handles.correction_type, 'value') > 3;
MAX_N_RANDOM = 100;

AXIS_DIGITS = 3;

%*************************************************************************%
%2.) Load the Data *******************************************************%
%*************************************************************************%

% If user selected correction mode 'Random Networks', the corresponding
% data must be loaded.
groupsLoaded = 0;
isGroups = 0;

USE_NONP = get(handles.correction_type, 'value') > 3 && ((handles.nRandom > 0) || (handles.nShuffel && isNetFunc)) ;

STAT = [];
STAT_ = [];
PVAL = [];

NPVAL = [];
NSTAT = [];

HAS_GROUPS = 0;
HAS_MULTIPLE = 0;
GROUPS = {};
LEV = {};

STATNAME = {};

USE_F = [];

DDF = 0;

global TS_VAR;
if ~isempty(TS_VAR)
    TS_VAR = TS_VAR(ismember(TS_VAR, var));
end

for i_thr = 1: length(thresh)
    for i_func = 1:length(fun)
        for i_var = 1:length(var)
            Result = load( ...
                [result_path filesep result_folder filesep handles.Files{thresh(i_thr),fun(i_func),var(i_var), 1}], ...
                'P', 'NP', 'F', 'B', 'N', 'DDF', ...
                'LAB', 'LEV', 'LLEV', 'TYPE', 'MEAN', 'J' ...
            );

            USE_F_ = Result.J > 1;

            RHO1 = Result.B;
            RHO1(:, :, USE_F_) = Result.F(:, :, USE_F_);
            
            STAT1 = Result.F;
            STAT1(:, :, ~USE_F_) = sqrt(STAT1(:, :, ~USE_F_)) .* ...
                sign(Result.B(:, :, ~USE_F_));
            
            DDF = Result.DDF;

            PVAL1   = Result.P;
            
            HAS_MULTIPLE = size(RHO1, 3) > 1;
            if HAS_MULTIPLE
                set(handles.GroupTestChooser,'Visible','on');
                testSelected = get(handles.GroupTestChooser,'Value');

                if testSelected > size(PVAL1, 3)
                    TS_VAR = TS_VAR(TS_VAR ~= var(i_var));
                    testSelected = 1;
                    
                    if isempty(TS_VAR)
                        set(handles.GroupTestChooser,'Value',testSelected);
                    else
                        RHO1(:, :, testSelected) = nan;
                        STAT1(:, :, testSelected) = nan;
                        PVAL1(:, :, testSelected) = nan;
                        USE_F_(testSelected) = 0;
                    end
                else
                    TS_VAR = [TS_VAR var(i_var)];
                end

                set(handles.GroupTestChooser, 'String', Result.LAB)

                RHO1 = RHO1(:, :, testSelected);
                STAT1 = STAT1(:, :, testSelected);
                PVAL1 = PVAL1(:, :, testSelected);
                USE_F_ = USE_F_(testSelected);
                
                if USE_F_ 
                    STATNAME{i_thr, i_func, i_var} = ['F(' num2str(Result.J(testSelected)) ',' num2str(Result.DDF) ')'];
                else
                    if strcmp(Result.TYPE(testSelected), '')
                        USE_F_ = 2;
                        STATNAME{i_thr, i_func, i_var} = ['t(' num2str(Result.DDF) ')'];
                        RHO1 = STAT1;
                    else
                        STATNAME(i_thr, i_func, i_var) = Result.TYPE(testSelected);
                    end
                end
                
                if iscell(Result.LLEV) && ~isempty(Result.LLEV{testSelected}) && get(handles.showGroupVal_check,'Value')
                    HAS_GROUPS = 1;
                end
            else
                STATNAME(i_thr, i_func, i_var) = Result.TYPE;
            end
                    
            USE_F(i_thr, i_func, i_var) = USE_F_;

            if size(RHO1,1) > 1 && size(RHO1,2) > 1
                STAT(:,:) = RHO1;
                STAT_(:,:) = STAT1;
                PVAL(:,:) = PVAL1;
                PlotType = 3;

                if(get(handles.AnovaSig,'Value') == 1)
                    AnovaSig(:, :) = AnovaSigTmp;
                end

                if USE_NONP
                    if size(Result.NP, 3) > 1
                        NPVAL(:, :) = Result.NP(:, :, testSelected);
                    else
                        NPVAL(:, :) = Result.NP;
                    end
                end

                if(groupsLoaded)
                    GROUPS = Groups;
                end
            elseif max(size(RHO1)) > 1
                try
                    STAT(i_thr, i_func, i_var, :) = RHO1;
                    STAT_(i_thr, i_func, i_var, :) = STAT1;
                    PVAL(i_thr, i_func, i_var, :) = PVAL1;
                catch
                    return;
                end

                if(groupsLoaded)
                    GROUPS(i_thr,i_func,i_var,:,:) = Groups;
                end

                PlotType = 2;
                if(get(handles.AnovaSig,'Value') ==1)
                    AnovaSig(i_thr,i_func,i_var,:) = AnovaSigTmp;
                end

                if USE_NONP
                    if size(Result.NP, 3) > 1
                        NPVAL(i_thr, i_func, i_var, :) = Result.NP(:, :, testSelected);
                    else
                        NPVAL(i_thr, i_func, i_var, :) = Result.NP;
                    end
                end
            else
                STAT(i_thr, i_func, i_var) = RHO1;
                STAT_(i_thr, i_func, i_var) = STAT1;
                PVAL(i_thr, i_func, i_var) = PVAL1;
                
                if (HAS_MULTIPLE && get(handles.AllGroups,'Value') && get(handles.showGroupVal_check,'Value')) || ...
                        (HAS_MULTIPLE && ~HAS_GROUPS && get(handles.showGroupVal_check,'Value'))
                    GROUPS{i_var}(i_thr, i_func, :) = Result.MEAN;
                    LEV{i_var} = Result.LEV;
                elseif HAS_GROUPS && get(handles.showGroupVal_check,'Value')
                    IGROUPS = ismember(Result.LEV, Result.LLEV{testSelected});
                    GROUPS{i_var}(i_thr, i_func, :) = Result.MEAN(IGROUPS);
                    LEV{i_var} = Result.LEV(IGROUPS);
                end

                if USE_NONP
                    if size(Result.NP, 3) > 1
                        NPVAL(i_thr,i_func,i_var) = Result.NP(:, :, testSelected);
                    else
                        NPVAL(i_thr,i_func,i_var) = Result.NP;
                    end
                end
                    
                if SHOW_RANDOM
                    Result2 = load( ...
                        [result_path filesep result_folder filesep handles.Files{thresh(i_thr),fun(i_func),var(i_var), 1}], ...
                        'NF', 'NB' ...
                    );
                    NF = Result2.NF;
                    NB = Result2.NB;

                    if HAS_MULTIPLE
                        NF = NF(:, :, testSelected, :);
                        NB = NB(:, :, testSelected, :);
                    end
                    
                    if USE_F_
                        NSTAT(i_thr, i_func, i_var, :) = NF;
                    else
                        NSTAT(i_thr, i_func, i_var, :) = NB;
                    end
                end
                
                PlotType = 1;
            end
        end
    end
end

if handles.nRandom > 0 && PlotType == 1 && get(handles.correction_type, 'value') > 3
    set(handles.show_random,'Visible','on');
else
    set(handles.show_random,'Visible','off');
end

if isempty(STAT)
    return;
end
if isGroups && length(Result.groups) > 2
	set(handles.AnovaSig,'Visible','on');
end
 
clear RHO1 PVAL1;

PVAL = squeeze(PVAL);
STAT = squeeze(STAT);
STAT_ = squeeze(STAT_);
STATNAME = squeeze(STATNAME);

secVal = 1:length(filterFieldStrings{fieldOnXAxes});
legendStr = {};
%*************************************************************************%
%3.) Plot Data *******************************************************%
%*************************************************************************%
if(PlotType == 1) % 1D
    corAlpha = Results_doCorrection(handles,hObject,squeeze(PVAL),alphaLvl);
    plotID = [];
    
    handles.alpha = corAlpha;
    set(handles.Var2,'Visible','on')
    
    if fieldOnXAxes == nonSingularFields(1)
        rot = 0;
    else
        rot = 3;
    end
    STAT = rot90(squeeze(STAT(:,:,:)),rot);
    set(handles.ResultAxes,'XTick',secVal,'XTickLabel',filterFieldStrings{fieldOnXAxes})
    hold on;
    PVAL2 = PVAL;
    if USE_NONP
        SIGNIFICANT = NPVAL < corAlpha;
        [row,col] =  find(SIGNIFICANT);
        NPVAL = squeeze(NPVAL);
        PVAL = NPVAL;
    else
        SIGNIFICANT = PVAL < corAlpha;
        [row,col] =  find(SIGNIFICANT);
    end
    PVAL = rot90(squeeze(PVAL),rot);
    PVAL2 = rot90(squeeze(PVAL2),rot);
     legendI = 1;
    
    if(plotP == 0)
        if SHOW_RANDOM
            legendStr_ = 'Null Distribution';
            if size(NSTAT, 4) > MAX_N_RANDOM
                legendStr_ = [legendStr_ ' ' '(1-' num2str(MAX_N_RANDOM) ')'];
            end

            legendStr{end+1} = legendStr_;
            legendI = legendI + 1;

%             legendStr{end+1} = 'Confidence interval';
%             legendI = legendI + 1;
        
            for i_rand = 1:min(MAX_N_RANDOM, size(NSTAT, 4))
                tmpID = plot(secVal,rot90(squeeze(NSTAT(:, :, :, i_rand)), rot), ':','color',[0,0,0] + 0.5);
                plotID(1) = tmpID(1);
            end
            
%             UPPER = prctile(NSTAT, (1 - corAlpha / 2) * 100, 4);
%             UPPER_TWOT = prctile(NSTAT, (1 - corAlpha) * 100, 4);
%             UPPER(USE_F ~= 0) = UPPER_TWOT(USE_F ~= 0);
%             tmpID = plot(secVal,rot90(squeeze(UPPER), rot), '--','color',[0,0,0]);
%             
%             LOWER = prctile(NSTAT, corAlpha / 2 * 100, 4);
%             LOWER(USE_F ~= 0) = nan;
%             tmpID = plot(secVal,rot90(squeeze(LOWER), rot), '--','color',[0,0,0]);
%             plotID(2) = tmpID(1);
        end

        if (HAS_GROUPS || HAS_MULTIPLE) && (isempty(GROUPS) || ismatrix(squeeze(GROUPS{1})))
            set(handles.showGroupVal_check,'Visible','on');
            
            if HAS_GROUPS 
                set(handles.AllGroups,'Visible','on');
            else
                set(handles.AllGroups,'Visible','off');
            end
            
            if get(handles.showGroupVal_check,'Value')
                hold on;

                GROUPS = squeeze(GROUPS);

                for i_var = 1:length(var)
                    GROUPS_ = squeeze(GROUPS{i_var});
                    if ~isempty(GROUPS_) && size(GROUPS_, 1) == length(secVal)
                        tmpID = plot(secVal,GROUPS_,'--');
                        plotID(end+1:end+length(tmpID)) = tmpID;

                        for qii = 1: size(GROUPS_, 2)
                            legendStr{legendI} =  ['Group mean ' LEV{i_var}{qii} ];
                            legendI = legendI + 1;
                        end
                    end
                end
            end
        end

        hold on;
        plotIDL = length(plotID);
        
        tmpID = plot(secVal, STAT, 'LineWidth', 2);
        COLOR = get(tmpID, 'Color');
        
        plotID(plotIDL+1:plotIDL+length(tmpID)) = tmpID;
    else
        hold on;   
%         
%         for i_run=1:nRandom
%             tmpID =  plot(secVal,rot90(squeeze(Random2{i_run}(:,:,:)),rot),':','color',[0,0,0]+0.5);
%             plotID(1) = tmpID(1);
%         end
%         
        plotIDL = length(plotID);
        if USE_NONP
            PVALS_ = NPVAL(:,:,:);
            tmpID =   plot(secVal, squeeze(PVALS_),'r', 'LineWidth', 2);        
            plotID(plotIDL+1) = tmpID(1);
            legendStr{end+1} = 'Non-Par';
        end
        plotIDL = length(plotID);

        tmpID =    plot(secVal,PVAL2(:,:,:),'LineWidth',2);
        
        plotID(plotIDL+1:plotIDL+length(tmpID)) = tmpID;
    end
    
    if(fieldAsLines > 0)
        str = filterFieldStrings{fieldAsLines}; 
        a = size(str);
        
        for i = 1:length(str)
            switch fieldAsLines
                case 1
                    if USE_F(1, 1, i, 1) == 1
                        str{i} = ['F-Value: ' str{i}];
                    elseif USE_F(1, 1, i, 1) == 2
                        str{i} = ['t-Value: ' str{i}];
                    end
                case 2
                    if USE_F(1, i, 1, 1)
                        str{i} = ['F-Value: ' str{i}];
                    elseif USE_F(1, 1, i, 1) == 2
                        str{i} = ['t-Value: ' str{i}];
                    end
            end
        end
        
        if a(2) == 1  && max(a)>1
            str = rot90(str);
        end
        
        legend(plotID,[legendStr str],'Interpreter','none');
    elseif  ~isempty(legendStr)    
        str = strjoin(handles.plotOne,'');
        
        if all(USE_F == 1)    
            str = ['F-Value: ' str];
        elseif all(USE_F == 2)            
            str = ['t-Value: ' str];
        end
        
        legend(plotID,[  legendStr {str}],'Interpreter','none');
    end
    
    % Significance markers
    if(plotP == 0)
        
        if ~iscell(COLOR)
            COLOR = {COLOR};
        end
        
        NSIGSTAT = STAT;
        NSIGSTAT(SIGNIFICANT) = nan;
        for i = 1:size(NSIGSTAT, 2)        
            tmpID = plot(secVal, NSIGSTAT(:, i), ...
                'LineStyle', 'none', ...
                'Marker', 'o', 'MarkerSize',10,...
                'MarkerEdgeColor', COLOR{i}, 'MarkerFaceColor', 'none');
        end
        
        SIGSTAT = STAT;
        SIGSTAT(~SIGNIFICANT) = nan;
        for i = 1:size(SIGSTAT, 2)        
            tmpID = plot(secVal, SIGSTAT(:, i), ...
                'LineStyle', 'none', ...
                'Marker', 'o', 'MarkerSize',10,...
                'MarkerEdgeColor', COLOR{i}, 'MarkerFaceColor', COLOR{i});
        end
        
%         for i=1:length(row)
%             if isscalar(STAT(1,1,1))
%                 plot(row(i),STAT(row(i), col(i)),'o','MarkerSize',24,'MarkerEdgeColor','r','LineWidth',2);
%             else
%                 plot(row(i),meanDiff(row(i),col(i)),'o','MarkerSize',24,'MarkerEdgeColor','r','LineWidth',2);
%             end
%         end
        
    end
    
    if range(get(handles.ResultAxes, 'YLim')) < 10 ^ -AXIS_DIGITS
        M = round(mean(get(handles.ResultAxes, 'YLim')), AXIS_DIGITS);
        MM = 0.5 * [-1 1] * (10 ^ -AXIS_DIGITS);
        set(handles.ResultAxes, 'YLim', M + MM)
    end
    
    if fieldAsLines ~= 0
        LineName = filterFieldStrings{fieldAsLines};
    else
        LineName = filterFieldStrings{2};
    end
    
    set(handles.ResultFig,'WindowButtonMotionFcn', ...
        {@press, ...
            handles, ...
            PlotType,plotP, ...
            STAT,USE_F,STAT_,DDF,PVAL,STATNAME, ...
            filterFieldStrings{fieldOnXAxes},Vars(fieldOnXAxes),LineName});
    
end
if(PlotType == 2) || (PlotType == 3)
    if USE_NONP
        NPVAL = squeeze(NPVAL);
        PVAL = NPVAL;
    end
    
    if ~isscalar(STAT(1,1,1))
        STAT = cellfun(@(v) v(3), STAT);
    end
    if iscell(STAT)
        STAT = cell2mat(STAT);
    end
    
    
    set(handles.HideNSig_Check,'Visible','on')
    
    if(PlotType == 2)
        STAT = STAT(:,brain);
        PVAL = PVAL(:,brain);
    elseif (PlotType == 3)
        STAT = STAT(brain,brain);
        PVAL = PVAL(brain,brain);
        visFuncs = get(handles.mod_func,'String');
        visFuncIdx = get(handles.mod_func,'Value');
        if strcmp(visFuncs(1),visFuncs(visFuncIdx))
        elseif strcmp('reorder_mod',visFuncs(visFuncIdx))
            STAT(isnan(STAT)) = 0;
            PVAL(isnan(PVAL)) = 1;
            mod = modularity_und(STAT);
            [newOrder,STAT] = reorder_mod(abs(STAT),mod);
            [~,PVAL] = reorder_mod(PVAL,mod);
            filterFieldStrings{4} = filterFieldStrings{4}(newOrder);
            handles.brainSelect = newOrder;
        elseif strcmp('backbone_wu',visFuncs(visFuncIdx))
            STAT(isnan(STAT)) = 0;
            PVAL(isnan(PVAL)) = 1;           
            [ STAT, CIJclus] = backbone_wu(STAT,12);
            %[~,Results2] = reorder_mod(Results2,mod);
            %filterFieldStrings{4} = filterFieldStrings{4}(newOrder);
            %handles.brainSelect = newOrder;
        elseif strcmp('reorderMAT',visFuncs(visFuncIdx))
            [STAT,newOrder] = reorderMAT(STAT,50,'line');
            filterFieldStrings{4} = filterFieldStrings{4}(newOrder);
            handles.brainSelect = newOrder;
        elseif strcmp('reorder_matrix',visFuncs(visFuncIdx))
            [STAT,newOrder] = reorder_matrix(STAT,'line',0);
            filterFieldStrings{4} = filterFieldStrings{4}(newOrder);
            handles.brainSelect = newOrder;
        end
        
        
    end
    corAlpha = Results_doCorrection(handles,hObject,squeeze(PVAL),alphaLvl);
    handles.alpha = corAlpha;
    
    if(plotP == 0)
        if(get(handles.AnovaSig,'Value') ==1) && testSelected > 1
            STAT(AnovaSig > corAlpha) = 0;
        end
        if(get(handles.HideNSig_Check,'Value') ==1)
            PVAL = squeeze(PVAL);
            STAT(PVAL > corAlpha) = nan;
        end
        imagesc(STAT)
        
    else
        
        if(get(handles.AnovaSig,'Value') ==1) && testSelected > 1
            PVAL(AnovaSig > corAlpha) = 0;
        end

        if(get(handles.HideNSig_Check,'Value') ==1)
            PVAL = squeeze(PVAL);
            PVAL(PVAL > corAlpha) = nan;
        end
        imagesc(PVAL)
    end
    h.a = gca;
    set(handles.ResultAxes, 'YTick',secVal, ...
                            'YTickLabel', filterFieldStrings{fieldOnXAxes});
    
    VERSION = version('-release');
    YEAR = str2double(VERSION(1:end-1));
    if YEAR >= 2014 && ~strcmp(VERSION, '2014a')
        set(handles.ResultAxes, 'TickLabelInterpreter', 'none');
        
        if ismember(fieldOnXAxes, [1 2])
            set(handles.ResultAxes, 'YTickLabelRotation', 90);
        end
    end
    set(handles.ResultFig,'WindowButtonMotionFcn', ...
        {@press,handles,PlotType,plotP,STAT,USE_F,STAT_,DDF,PVAL,STATNAME,filterFieldStrings{fieldOnXAxes},Vars(fieldOnXAxes),[]});
    
    colorbar;
end
if(PlotType == 3)
    
end

hold off;
handles.Results = STAT;
if USE_NONP
    handles.Results2 = squeeze(NPVAL);
else
    handles.Results2 = squeeze(PVAL);
end
if isfield(handles,'ResultsGroups')
    handles = rmfield(handles,'ResultsGroups');
    handles = rmfield(handles,'GroupNames');
    handles = rmfield(handles,'GroupsSelected');
end
if(groupsLoaded)
    handles.ResultsGroups  = GROUPS;
    handles.GroupNames  = Result.groups;
    if ~exist('loc','var')
        handles.GroupsSelected = 1:length(Result.groups);
    else
        handles.GroupsSelected  = loc;
    end
end
handles.PlotType = PlotType;
guidata(hObject, handles);
  end

function press(o,e,handles,PlotType,plotP,STAT,USE_F,STAT_,DDF,PVAL,STATNAME,Label,VarName,LineName)
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

BoxSize = [diff(X) / 5 diff(Y) / 9];
BoxPoint = Point;
if Point(1) > X(1) + diff(X) / 2
    BoxPoint(1) = BoxPoint(1) - BoxSize(1);
end
if Point(2) > Y(1) + diff(Y) / 2
    BoxPoint(2) = BoxPoint(2) - BoxSize(2);
end

if PlotType == 1
    if plotP == 0
        REF = STAT;
    else
        REF = PVAL;
    end
    
    Indices = [nan nan];
    
    [DX, IX] = min(abs(Point(1) - (1:length(Label))));
    if DX < diff(X) / 50
        Indices(2) = IX;
    end
    
    [DY, IY] = min(abs(Point(2) - REF(IX, :)), [], 2);
    if DY < diff(Y) / 50
        Indices(1) = IY;
        BrainStr = LineName(Indices(1));
    end
else
    Indices = round(Point);
    
    BrainStr = handles.BrainStrings(handles.brainSelect);
    BrainStr = BrainStr(Indices(1));
end

if ~any(isnan(Indices))
    set(handles.htext, 'Visible', 'on');
    set(handles.box, 'Visible', 'on');

    VarStr = [VarName{1} ': ' Label{Indices(2)}];

    USE_F = squeeze(USE_F);
    if PlotType == 1
        STATStr = STATNAME{Indices(2), Indices(1)};
        USE_F_ = USE_F(Indices(2), Indices(1));
    elseif PlotType == 2
        STATStr = STATNAME{Indices(2)};
        USE_F_ = USE_F(Indices(2));
    else
        STATStr = STATNAME{:};
        USE_F_ = USE_F;
    end
    STATStr = [STATStr ' = ' sprintf('%05f', STAT(Indices(2), Indices(1)))];

    TStr = '';
    if ~USE_F_
        TStr  = ['t(' num2str(DDF) ') = ' sprintf('%05f', STAT_(Indices(2), Indices(1)))];
    end

    PStr = ['p = ' sprintf('%05f', PVAL(Indices(2), Indices(1)))];

    set(handles.htext, ...
        'String', [BrainStr VarStr STATStr TStr PStr], ...
        'Position', BoxPoint + [diff(X) / 500 diff(Y) / 18]);

    set(handles.box, 'Position', ...
        [BoxPoint BoxSize]);
else
    set(handles.htext, 'Visible', 'off');
    set(handles.box, 'Visible', 'off');
end