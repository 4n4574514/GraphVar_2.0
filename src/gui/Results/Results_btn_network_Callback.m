%  This file is part of GraphVar.
%
%  Copyright (C) 2014
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

function Results_btn_network_Callback(hObject, eventdata, handles,isNBS)
global root_path;
global out;
global highlightedNetwork;
highlightedNetwork =0;
if(ishandle(out))
    delete(out);
end

if isNBS == 1 && (handles.nShuffel == 0 && handles.nRandom == 0) || ~isfield(handles,'Results2')
    errordlg('You need to create Random Networks/Groups to perform Network Based Statistics');
    return;
end

if isNBS == 0 && get(handles.correction_type,'value') > 3 && (handles.nShuffel == 0 && handles.nRandom == 0) || ~isfield(handles,'Results2')
    errordlg('You need to create Random Networks/Groups to display components based on correction method "Random Networks/Groups"');
    return;
end


out = dialog('WindowStyle', 'normal', 'Name', 'Network Inspector','Resize','on');

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(out,'javaframe');
jIcon=javax.swing.ImageIcon([ root_path 'src\gui\GraphVar\Icon.png']);
jframe.setFigureIcon(jIcon);
warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

msz  = get( 0,   'MonitorPosition');
msz = msz(1,:);
set( out, 'Units', 'Pixels',...
    'OuterPosition', [0 msz(4)*0.1 msz(3)*0.99 msz(4)*0.9]);

alphaStr = get(handles.AlphaLevel,'String');    % Get the alpha level from text field
alphaLvl = str2double(alphaStr);                % to number

corAlpha = Results_doCorrection(handles,hObject,squeeze(handles.Results2),alphaLvl);


if(isNBS)
    handles.isNBS = 1;
    cnames = {'Size of Network', 'Count in real data', 'Mean count in random data', 'Max Frequecy', 'Alpha'};
    handles.mtable =  uitable(out,'ColumnName',cnames,    'units','normalized',...
        'position',[0 0 0.30 0.95],'CellSelectionCallback',{@select_callback, handles});
    
    handles.networkData = loadAndProcessData(hObject, handles,corAlpha,1);
    
    
    handles.ax = axes(...
        'Parent', out, ...
        'Units', 'normalized', ...
        'HandleVisibility','callback', ...
        'Position',[0.3 0 0.7 0.95]);
    
else
    handles.isNBS = 0;
    
    cnames = {'Size of Network', 'Count in real data'};
    handles.mtable =  uitable(out,'ColumnName',cnames,    'units','normalized',...
        'position',[0 0 0.15 0.95],'CellSelectionCallback',{@select_callback, handles});
    
    handles.networkData = loadAndProcessData(hObject, handles,corAlpha,0);
    
    
    handles.ax = axes(...
        'Parent', out, ...
        'Units', 'normalized', ...
        'HandleVisibility','callback', ...
        'Position',[0.15 0 0.85 0.95]);
end

set(handles.ax,'YTickLabel',[]);
set(handles.ax, 'YTick', []);
set(handles.ax, 'XTick', []);

handles.showCorr = uicontrol('style','checkbox','units','normalized',...
    'position',[0.02,0.95,0.2,0.05],'string','Show all lables');


% uicontrol('Style','text',...
%     'units','normalized', ...
%     'Position',[0.15,0.952,0.05,0.03],...
%     'String','Alpha');
%
handles.editThr = uicontrol('Style','edit',...
    'units','normalized', ...
    'Position',[0.3,0.96,0.05,0.03],...
    'String',num2str(corAlpha),...
    'BackgroundColor','w');

handles.applyAlpha  = uicontrol('Style','pushbutton',...
    'units','normalized', ...
    'Position',[0.35,0.96,0.05,0.03],...
    'String','Apply Alpha'...
    );


% if handles.networkData.isGroup == 2  && isNBS
%     
%     handles.groupSelect  = uicontrol('Style','popupmenu',...
%         'units','normalized', ...
%         'Position',[0.10,0.952,0.15,0.03],...
%         'String',handles.networkData.groupStr);
%     
% if handles.networkData.isGroup == 1 ||  handles.networkData.isGroup == 3
STR_ = handles.networkData.groupStr;
if ~handles.networkData.USE_F
    STR_ = STR_(1:end-2);
end
handles.groupSelect  = uicontrol('Style','text',...
    'units','normalized', ...
    'Position',[0.10,0.952,0.1,0.03],...
    'String', STR_);
% end

if ~handles.networkData.USE_F
    handles.signSelect  = uicontrol('Style','popupmenu',...
        'units','normalized', ...
        'Position',[0.2,0.952,0.075,0.03],...
        'String',{'two-sided', '<0', '>0'});
    set(handles.signSelect,'callback',{@signSelect_Callback, handles})
end

handles.prevGraph  = uicontrol('Style','pushbutton',...
    'units','normalized', ...
    'Position',[0.47,0.96,0.05,0.03],...
    'String','Previous'...
    );

handles.networkNLabel  = uicontrol('Style','text',...
    'units','normalized', ...
    'Position',[0.52,0.952,0.15,0.03],...
    'String',' ');

handles.nextGraph = uicontrol('Style','pushbutton',...
    'units','normalized', ...
    'Position',[0.68,0.96,0.05,0.03],...
    'String','Next'...
    );


handles.export = uicontrol('Style','pushbutton',...
    'units','normalized', ...
    'Position',[0.76,0.96,0.04,0.03],...
    'String','Export'...
    );

handles.exportPAJ = uicontrol('Style','pushbutton',...
    'units','normalized', ...
    'Position',[0.80,0.96,0.04,0.03],...
    'String','Export PAJ'...
    );

handles.openBrainNet = uicontrol('Style','pushbutton',...
    'units','normalized', ...
    'Position',[0.84,0.96,0.04,0.03],...
    'String','BrainNet Viewer'...
    );

handles.mouseOverGraph = uicontrol('style','checkbox','units','normalized',...
    'position',[0.89,0.95,0.15,0.05],'string','Enable Mouse Over');

guidata(hObject, handles);

if handles.networkData.isGroup == 2 && isNBS
    set(handles.groupSelect,'callback',{@groupSelect_Callback, handles})
end

set(handles.nextGraph,'callback',{@nextGraph_Callback, handles})
set(handles.prevGraph,'callback',{@prevGraph_Callback, handles})

set(handles.showCorr,'callback',{@select_callback, handles})
set(handles.mouseOverGraph,'callback',{@mouseOverGraph_Callback, handles})
set(handles.applyAlpha,'callback',{@applyAlpha_Callback, handles})
set(handles.export,'callback',{@exportNetwork_Callback, handles})
set(handles.exportPAJ,'callback',{@exportPAJ_Callback, handles})
set(handles.openBrainNet,'callback',{@openBrainNet, handles})

set(handles.nextGraph,'Enable','off');
set(handles.prevGraph,'Enable','off');



function exportPAJ_Callback(~,~,handles)
global selectedNetworkID;
global drawArg2;
[FileName,PathName,FilterIndex] = uiputfile({'*.net','Pajek file (.net)'},'ExportData');
if ~ischar(FileName) && FileName == 0
    return;
end
[pathstr,name,ext] = fileparts(FileName) ;
brainIdx = find(handles.networkData.or1 == drawArg2(selectedNetworkID));
writetoPAJ(handles.networkData.data(brainIdx,brainIdx),[PathName name],0);

function openBrainNet(~,~,handles)
global workspacePath;
global selectedNetworkID;
global drawArg2;
if exist('BrainNet_MapCfg','file')
    load(fullfile(workspacePath,'Workspace.mat'));
    
    brainIdx = find(handles.networkData.or1 == drawArg2(selectedNetworkID));
    data = handles.networkData.data(brainIdx,brainIdx);
    data2 = handles.networkData.data2(brainIdx,brainIdx);
    data(data2 > handles.networkData.alpha) = 0;
    handles.BrainStrings(brainIdx);
    
    [BrainMap] = importSpreadsheet(brainSheet);
    [~,idx] = ismember(handles.BrainStrings(brainIdx),BrainMap(:,2));
    tmp = ones(length(idx),1);
    nodes = [BrainMap(idx,4),BrainMap(idx,5),BrainMap(idx,6),num2cell(tmp*4), num2cell(tmp), BrainMap(idx,2)];
    dlmcell('tmp.node',nodes);
    dlmcell('tmp.edge',num2cell(data));
    BrainNet_MapCfg('BrainMesh_ICBM152_smoothed.nv','tmp.node','tmp.edge','ConfigBrainViewer.mat');
else
    warndlg('Please install Brain Net Viewer (http://www.nitrc.org/projects/bnv/)');
end


function exportNetwork_Callback(~,~,handles)
global selectedNetworkID;
global drawArg2;

[FileName,PathName,FilterIndex] = uiputfile({'*.csv','Comma Seperated Values (*.csv)'},'ExportData');

if ~ischar(FileName) && FileName == 0
    return;
end

[pathstr,name,ext] = fileparts(FileName) ;
filetype = strcmp(ext,'.csv');


brainIdx = find(handles.networkData.or1 == drawArg2(selectedNetworkID));

data = handles.networkData.data(brainIdx,brainIdx);
data2 = handles.networkData.data2(brainIdx,brainIdx);
data(data2 > handles.networkData.alpha) = 0;

outCell(2:length(handles.BrainStrings(brainIdx))+1,1) = handles.BrainStrings(brainIdx);
outCell(1,2:length(handles.BrainStrings(brainIdx))+1) = handles.BrainStrings(brainIdx);

outCell2 = outCell;

outCell(2:end,2:end) = num2cell(data);
outCell2(2:end,2:end) = num2cell(data2);


if(handles.networkData.isGroup == 2)
    testSelected = get(handles.groupSelect,'Value');
    data = handles.networkData.data3{testSelected}(brainIdx,brainIdx);
    outCell(1,1) = {'Anova'};
    outCell(length(handles.BrainStrings(brainIdx))+3,1) = {'T-Test (anova filtered)'};
    outCell(length(handles.BrainStrings(brainIdx))+4:length(handles.BrainStrings(brainIdx))*2+3,1) = handles.BrainStrings(brainIdx);
    outCell(length(handles.BrainStrings(brainIdx))+3,2:length(handles.BrainStrings(brainIdx))+1) = handles.BrainStrings(brainIdx);
    outCell(length(handles.BrainStrings(brainIdx))+4:end,2:end) = num2cell(data);
    
    
    data2 = squeeze(handles.networkData.data4{testSelected});
    data2 = data2(brainIdx,brainIdx);
    outCell2(length(handles.BrainStrings(brainIdx))+3,1) = {'T-Test p Value (anova filtered)'};
    outCell2(length(handles.BrainStrings(brainIdx))+4:length(handles.BrainStrings(brainIdx))*2+3,1) = handles.BrainStrings(brainIdx);
    outCell2(length(handles.BrainStrings(brainIdx))+3,2:length(handles.BrainStrings(brainIdx))+1) = handles.BrainStrings(brainIdx);
    outCell2(length(handles.BrainStrings(brainIdx))+4:end,2:end) = num2cell(data2);
end

dlmcell([PathName filesep name '-r.txt'],outCell2);
dlmcell([PathName filesep name '.txt'],outCell);




function select_callback(~, arg2, handles)
global selectedNetworkID;
global drawArg2;

handles = guidata(handles.ResultFig);


if (isfield(arg2,'Indices') || isa(arg2,'matlab.ui.eventdata.CellSelectionChangeData')) && (~isempty(arg2.Indices))
    selectedNetworkID = 1;
    idx = find(handles.networkData.or2 == arg2.Indices(1));
    drawArg2 = idx;
else
    idx = drawArg2;
end

if(~isempty(idx))
    drawGraph(idx,handles)
end


function dat = loadAndProcessData(hObject, handles, corAlpha, doCorrection)
global result_path;
global result_folder;
[thresh,fun,var,brain] = Results_Filters(hObject,handles);  % Get filter fields returned vars will

testSelected = get(handles.GroupTestChooser,'Value');

Result = load( ...
    [result_path filesep result_folder filesep handles.Files{thresh,fun,var,1}], ...
    'P', 'NP', 'F', 'B', 'N', 'LAB', 'LEV', 'J', 'DDF' ...
);

USE_F = Result.J > 1;

RHO1 = Result.B;
RHO1(:, :, USE_F) = Result.F(:, :, USE_F);
                
PVAL1   = Result.P;
     
if get(handles.correction_type,'value') > 3
    PVAL1   = Result.NP;
end

HAS_MULTIPLE = size(RHO1, 3) > 1;

dat.isGroup = 0;
if HAS_MULTIPLE
    USE_F = USE_F(testSelected);
    RHO1 = RHO1(:, :, testSelected);
    PVAL1 = PVAL1(:, :, testSelected);
    
    if testSelected == 1
        dat.isGroup = 3;
    else
        dat.isGroup = 3;
    end
    
    dat.groupStr = Result.LAB{testSelected};
else
    dat.groupStr = Result.LAB{:};
end

SGN = 0;
if isfield(handles, 'signSelect') && ishandle(handles.signSelect) 
    SGN_ = get(handles.signSelect, 'Value');
    switch SGN_
        case 2
            SGN = -1;
        case 3
            SGN = 1;
    end
end

if SGN ~= 0 % one sided test
    RHO1(sign(RHO1) ~= SGN) = 0;
end

matrix_size = length(RHO1);
RHO1(PVAL1 > corAlpha) = 0;
RHO1((isnan(RHO1))) = 0;
% RHO1(RHO1 ~= 0) = 1;
[or1, or2] = get_components(RHO1);
[b]  = histc(or2, 1:matrix_size);

dat.data = RHO1;
dat.data2 = PVAL1;
dat.USE_F = USE_F;

randNet = min(handles.nRandom, size(PVAL1, 4));

if(doCorrection)
    J = Result.J;
    DDF = Result.DDF;
    
    if HAS_MULTIPLE
        J = J(testSelected);
    end
    
    Result2 = load( ...
        [result_path filesep result_folder filesep handles.Files{thresh,fun,var,1}], ...
        'NF', 'NB' ...
    );
    NF = Result2.NF;
    NB = Result2.NB;
    
    if HAS_MULTIPLE
        NF = NF(:, :, testSelected, :);
        NB = NB(:, :, testSelected, :);
    end
    
    if SGN ~= 0
        NF(sign(NB) ~= SGN) = 0;
    end
    
    if get(handles.correction_type,'value') > 3
        [~, PVAL1] = sort(NF, 4);
        PVAL1 = PVAL1 / randNet;
    else
        PVAL1 = 1 - fcdf(NF, ...
            repmat(J, size(NF)), ...
            repmat(DDF, size(NF)));
    end

    randB = zeros(randNet, size(PVAL1, 1));
    for i = 1:randNet
        RHO1 = double(PVAL1(:, :, :, i) <= corAlpha);
        [r1, r2] = get_components(RHO1);
        randB(i, :) = histc(r2,1:matrix_size);
    end
    
    [r,c] = find(randB > 0);
    maxFreq = zeros(1,matrix_size);
    sig = zeros(1,matrix_size(1));
    for i = 1:size(randB,1)
        maxFreq(max(c(r==i))) = maxFreq(max(c(r==i))) +1;
    end
    for i = matrix_size:-1:1
        if(i == matrix_size)
            sig(i) = maxFreq(i)/size(randB,1);
        else
            sig(i) = (maxFreq(i)/size(randB,1))+sig(i+1);
        end
    end
    
    set(handles.mtable,'Data',[rot90(1:matrix_size,3),rot90(b,3),rot90(mean(randB,1),3),rot90(maxFreq,3),rot90(sig,3)]);
else
    set(handles.mtable,'Data',[rot90(1:matrix_size,3),rot90(b,3)]);
    
end

dat.alpha=corAlpha;
dat.or1 = or1;
dat.or2 = or2;



function drawGraph(idx,handles)
global out;
global highlightedNetwork;
global selectedNetworkID;
nNetworks = length(idx);
placeUsed = [];
isHighlight = 0;
handles = guidata(handles.ResultFig);

if(selectedNetworkID < nNetworks)
    set(handles.nextGraph,'Enable','on')
else
    set(handles.nextGraph,'Enable','off');
end
if(selectedNetworkID > 1)
    set(handles.prevGraph,'Enable','on')
else
    set(handles.prevGraph,'Enable','off');
end

set(handles.networkNLabel,'String',[num2str(selectedNetworkID) '/'  num2str(nNetworks)]) ;

set(gcf,'CurrentAxes',handles.ax);
cla;

if(handles.networkData.isGroup == 2)
    testSelected = get(handles.groupSelect,'Value');
    disp(handles.networkData.data3(testSelected));
end

brainIdx = find(handles.networkData.or1 ==idx(selectedNetworkID));

t = (1/(2*length(brainIdx)):1/length(brainIdx):1)'*2*pi;
x = sin(t);
y = cos(t);
axis([-1.95 1.95 -1.5 1.5])

addYIdx = length(brainIdx)/10;

addX = zeros(1,length(brainIdx));
addY = zeros(1,length(brainIdx));
len = zeros(length(brainIdx));
for i = 1:length(brainIdx)
    len(i) = length(handles.BrainStrings{brainIdx(i)});
    if(i <= (length(brainIdx)/2))
        addX(i) = 0.05;
    else
        addX(i) = -(len(i)/22);
    end
    if i <= ((length(brainIdx)/4)*0.5)
        addY(i) = 0.12*addYIdx*(addYIdx/20);
        addYIdx = addYIdx - 1;
    elseif  (i <= ((length(brainIdx)/4)*2)) && (i > ((length(brainIdx)/4)*1.5))
        addY(i) = -0.12*addYIdx*(addYIdx/20);
        addYIdx = addYIdx + 1;
    elseif (i <= ((length(brainIdx)/4)*2.5)) && (i > ((length(brainIdx)/2)))
        addYIdx = addYIdx - 1;
        addY(i) = -0.12*addYIdx*(addYIdx/20);
    elseif i > ((length(brainIdx)/4)*3.5)
        addY(i) = 0.12*addYIdx*(addYIdx/20);
        addYIdx = addYIdx + 1;
    else
        addY(i) = 0;
    end
end
for i = 1:length(brainIdx)
    teH = text(x(i)+addX(i),y(i)+addY(i),handles.BrainStrings(brainIdx(i)),'Interpreter','none','FontSize',14,'FontWeight','bold');
    hold on;
    pos = get(teH,'Extent');
    if(pos(1) <= 0)
        startX(i) = pos(1) + pos(3) + 0.04;
    else
        startX(i) = pos(1)-0.04;
    end
    realX(i) = pos(1);
    startY(i) = pos(2) + pos(4)/2   ;
    
    plot(startX(i) ,startY(i),'o','MarkerSize',12,'MarkerEdgeColor','r','LineWidth',2);
end
data = handles.networkData.data(brainIdx,brainIdx);
data2 = handles.networkData.data2(brainIdx,brainIdx);
meanWidth = nanmean(abs(data(data2 < handles.networkData.alpha)), 1);
stdWidth = sqrt(nanvar(abs(data(data2 < handles.networkData.alpha))));
corWidth = nanmin(abs(data(data2 <= handles.networkData.alpha))) - meanWidth + 0.01;
if isnan(meanWidth) || stdWidth == 0
    meanWidth = 0.2;
    stdWidth = 0.2;
end
for i = 1:length(brainIdx)
    for ii = (i+1):length(brainIdx)
        if(handles.networkData.data2(brainIdx(i),brainIdx(ii))>handles.networkData.alpha)
            continue;
        end
        width = handles.networkData.data(brainIdx(i),brainIdx(ii));
        isHighlight = 1;
        
        if(highlightedNetwork ~= 0) && (i ~= highlightedNetwork) && (ii ~= highlightedNetwork)
            color = [1 1 1];
            isHighlight = 0;
        else
            color = [1 0 0.01];
        end
        if(width < 0)
            width = width*-1;
            if(isHighlight)
                color = [0 0 1];
            end
        elseif(isnan(width) || width == 0)
            continue;
        end
        if(isHighlight)
            if get(handles.showCorr,'Value')
                lineSmoth = 'off';
            else
                lineSmoth = 'on';
            end
            if(handles.networkData.isGroup == 2)
                value = handles.networkData.data3{testSelected}(brainIdx(i),brainIdx(ii));
                if value ~= 0
                    line([startX(i) startX(ii)],[startY(i) startY(ii)],'LineWidth',abs((width - meanWidth- corWidth) / stdWidth) * 3,'Color',color,'LineSmoothing',lineSmoth);
                else
                    plot([startX(i) startX(ii)],[startY(i) startY(ii)],'--','LineWidth',abs((width - meanWidth- corWidth) / stdWidth) * 3,'Color',color + [-0.6 1 0]);
                end
            else
                line([startX(i) startX(ii)],[startY(i) startY(ii)],'LineWidth',max(abs((width - meanWidth) / stdWidth- corWidth) * 4, 0.0001),'Color',color,'LineSmoothing',lineSmoth);
            end
        end
        if(get(handles.showCorr,'Value') && isHighlight)
            testSpace = [mean([startX(i),startX(ii)]),mean([startY(i),startY(ii)])];
            if ~isempty(placeUsed)
                found = (testSpace(1)+0.3) >= placeUsed(:,1) & testSpace(1) <= (placeUsed(:,1)+0.3) & testSpace(2)+0.1 >= placeUsed(:,2) & testSpace(2) <= (placeUsed(:,2)+0.1);
                xA = (startX(i) - startX(ii));
                xA  = xA + ((xA == 0) * 0.01);
                m = (startY(i) - startY(ii)) / xA ;
                n  = startY(i) - m*startX(i);
                xa = mean([startX(i),startX(ii)]);
                xs = xa;
                while(sum(found) ~= 0 )
                    xa = xa + 0.05;
                    testSpace = [xa m*xa+n];
                    found = (testSpace(1)+0.3) >= placeUsed(:,1) & testSpace(1) <= (placeUsed(:,1)+0.3) & testSpace(2)+0.1 >= placeUsed(:,2) & testSpace(2) <= (placeUsed(:,2)+0.1);
                    if(sum(found) ~= 0)
                        xs = xs - 0.05;
                        testSpace = [xs m*xs+n];
                        found = (testSpace(1)+0.3) >= placeUsed(:,1) & testSpace(1) <= (placeUsed(:,1)+0.3) & testSpace(2)+0.1 >= placeUsed(:,2) & testSpace(2) <= (placeUsed(:,2)+0.1);
                    end
                    if(xs < -1) || (xa > 1) || testSpace(2) > 1 || testSpace(2) < -1
                        testSpace = [mean([startX(i),startX(ii)]),mean([startY(i),startY(ii)])];
                        break;
                    end
                    
                end
            end
            placeUsed(end+1,:) = testSpace;
            rectangle('Position',[testSpace-0.025,0.35,0.1],'FaceColor','w')
            
            if(handles.networkData.isGroup == 2) && (handles.networkData.data3{testSelected}(brainIdx(i),brainIdx(ii)) ~= 0 )
                text(testSpace(1),testSpace(2)+0.03,[num2str(handles.networkData.data(brainIdx(i),brainIdx(ii)),4) '/' num2str(handles.networkData.data3{testSelected}(brainIdx(i),brainIdx(ii)),4)],'Color',color,'FontSize',12,'FontWeight','bold');
            else
                text(testSpace(1)+0.03,testSpace(2)+0.03,num2str(handles.networkData.data(brainIdx(i),brainIdx(ii)),4),'Color',color,'FontSize',12,'FontWeight','bold');
            end
        end
    end
end


if get(handles.mouseOverGraph,'Value')
    set(out,'WindowButtonMotion',{@mouseOverNetwork,realX,startY,len,handles,idx});
end

function mouseOverNetwork(~,~,X,Y,len,handles,idx)
global highlightedNetwork;
cp = get(handles.ax,'CurrentPoint');
mX  = cp(1,1);
mY = cp(1,2);
for i=1:length(X)
    if((mX > (X(i)-0.02))&& (mX < (X(i)+len(i)*0.045)))&& ((mY > (Y(i)-0.027))&& (mY < (Y(i)+0.027)))
        if(i == highlightedNetwork)
            return
        end
        highlightedNetwork = i;
        drawGraph(idx,handles);
        return;
    end
end
highlightedNetwork = 0;
drawGraph(idx,handles);


function mouseOverGraph_Callback(~,~,handles)
global out;
if get(handles.mouseOverGraph,'Value')
    select_callback(0,0,handles);
else
    set(out,'WindowButtonMotion',{});
end

function applyAlpha_Callback(~,~,handles)
handles.networkData = loadAndProcessData(handles.ResultFig, handles ,str2double(get(handles.editThr,'String')),handles.isNBS);
set(handles.export,'callback',{@exportNetwork_Callback, handles})
set(handles.exportPAJ,'callback',{@exportPAJ_Callback, handles})
set(handles.openBrainNet,'callback',{@openBrainNet, handles})

guidata(handles.ResultFig,handles);

function signSelect_Callback(~,~,handles)
handles = guidata(handles.ResultFig);
handles.networkData = loadAndProcessData(handles.ResultFig, handles ,str2double(get(handles.editThr,'String')),handles.isNBS);
guidata(handles.ResultFig, handles);

function groupSelect_Callback(~,~,handles)
global drawArg2;
drawGraph(drawArg2,handles)

function nextGraph_Callback(~,~,handles)
global selectedNetworkID;
global drawArg2;
selectedNetworkID = selectedNetworkID + 1;
drawGraph(drawArg2,handles)

function prevGraph_Callback(~,~,handles)
global selectedNetworkID;
global drawArg2;
if(selectedNetworkID > 1)
    selectedNetworkID = selectedNetworkID - 1;
end
drawGraph(drawArg2,handles)
