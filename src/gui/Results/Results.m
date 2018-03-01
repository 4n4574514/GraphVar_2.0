%  This file is part of GraphVar.
%
%  Copyright (C) 2017
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

function varargout = Results(varargin)
% Last Modified by GUIDE v2.5 14-Sep-2017 14:58:23
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Results_OpeningFcn, ...
    'gui_OutputFcn',  @Results_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


function varargout = Results_OutputFcn(hObject, eventdata, handles)
global root_path;
varagout = 1;

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(gcf,'javaframe');
jIcon=javax.swing.ImageIcon([ root_path 'src\gui\GraphVar\Icon.png']);
jframe.setFigureIcon(jIcon);
warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

function filterState(state,hObject,handles)
set(gcf,'windowbuttonmotionfcn','');

guiH = [handles.L_Var handles.L_Graph handles.L_thresh handles.text1 handles.text2 handles.text3];
if(state == 1)
    set(guiH,'Enable', 'on');
else
    set(guiH,'Enable', 'off');
end


function export_btn_Callback(hObject, eventdata, handles)

if strncmp(handles.Files{1}, 'ML', 2) %ML case 
 
Results_PlotView(hObject,handles);
elseif  ~strncmp(handles.Files{1}, 'ML', 2) 
    
[thresh,fun,var,brain]  = Results_Filters(hObject,handles);
Val{1} = handles.vars;
Val{2} = handles.functionList(fun);
Val{3} = handles.thresholds;

[FileName,PathName,FilterIndex] = uiputfile({'*.csv','Comma Seperated Values (*.csv)';'*.xlsx','Excel Sheets (Win only) (*.xlsx)'},'ExportData');


if ~ischar(FileName) && FileName == 0
    return;
end

[pathstr,name,ext] = fileparts(FileName) ;
filetype = strcmp(ext,'.csv');

if(FileName)
    if exist([PathName FileName],'file')
        delete([PathName FileName]);
    end
    for i = 1:2
        outCell = {};
        if(filetype == 1)
            outCell{1,1} = [handles.plotOne{:} ' Corrected Alpha Level: ' num2str(handles.alpha)];
        elseif (filetype == 0)
            xlswrite([PathName FileName],[handles.plotOne 'Corrected Alpha Level: ' handles.alpha],i);
        end
        
        if(handles.PlotType ==1)
            if(filetype == 1)
                outCell(3:size(handles.plotLines{:},2)+2,1) = fliplr(handles.plotLines{:});
                outCell(2,2:size(handles.plotX{:},1)+1) = rot90(handles.plotX{:},1);
                if(i==1)
                    outCell(3:size(handles.Results,2)+2,2:size(handles.Results,1)+1) = num2cell(rot90(handles.Results,1));
                    str = 'RHO';
                    
                    if isfield(handles,'ResultsGroups')
                        start = size(handles.Results,2)+5;
                        
                        for ii=1:size(handles.ResultsGroups,3)
                            groups = squeeze(handles.ResultsGroups(:,:,ii));
                            outCell(start:size(handles.plotLines{:},2)+start-1,1) = fliplr(handles.plotLines{:});
                            outCell(start:size(groups,2)+start-1,2:size(groups,1)+1) = num2cell(rot90(fliplr(groups),1));
                            if(ndims(handles.ResultsGroups) == 2)
                                outCell(start:start+size(handles.GroupNames(handles.GroupsSelected),1)-1,1) = handles.GroupNames(handles.GroupsSelected);
                            else
                                outCell(start-1,1) = handles.GroupNames(handles.GroupsSelected(ii));
                            end
                            start = size(handles.Results,2)+start+2;
                        end
                    end
                    
                    
                else
                    outCell(3:size(handles.Results2,2)+2,2:size(handles.Results2,1)+1) = num2cell(rot90(handles.Results2,1));
                    str = 'p';
                end
                
                dlmcell([PathName name '-' str '-' '.txt'],outCell);
            elseif (filetype == 0)
                xlswrite([PathName FileName],handles.plotLines{:},i,'A3');
                xlswrite([PathName FileName],rot90(handles.plotX{:},1),i,'B2');
                if(i==1)
                    xlswrite([PathName FileName],rot90(handles.Results,1),i,'B3');
                else
                    xlswrite([PathName FileName],rot90(handles.Results2,1),i,'B3');
                end
            end
        else
            if(filetype == 1)
                outCell(3:size(handles.plotX{:},1)+2,1) = handles.plotX{:};
                outCell(2,2:size(handles.BrainStrings(brain),1)+1) = rot90(handles.BrainStrings(brain));
                if(i==1)
                    outCell(3:size(handles.Results,1)+2,2:size(handles.Results,2)+1) = num2cell(handles.Results);
                    str = 'RHO';
                else
                    outCell(3:size(handles.Results2,1)+2,2:size(handles.Results2,2)+1) = num2cell(handles.Results2);
                    str = 'p';
                end
                dlmcell([PathName name '-' str '-' '.txt'],outCell);
                
                if(i==1) && (isfield(handles,'ResultsGroups'))
                    handles.ResultsGroups = squeeze(handles.ResultsGroups);
                    start = size(handles.Results,2)+5;
                    
                    dimN = (handles.PlotType == 2) + 1;
                    for ii=1:size(handles.ResultsGroups,dimN)
                        outCell = {};
                        
                        if(handles.PlotType == 3)
                            groups = squeeze(handles.ResultsGroups(ii,:,:));
                        else
                            groups = squeeze(handles.ResultsGroups(:,ii,:));
                        end
                        outCell(1,2:size(handles.plotX{:},1)+1) = handles.plotX{:};
                        outCell(2:size(groups,2)+1,2:size(groups,1)+1) = num2cell(flipud(rot90(groups,1)));
                        outCell(1:size(handles.GroupNames{handles.GroupsSelected(ii)},2),1) = handles.GroupNames(handles.GroupsSelected(ii));
                        
                        
                        outCell(2:size(handles.BrainStrings(handles.brainSelect),1)+1,1) = handles.BrainStrings(handles.brainSelect);
                        
                        dlmcell([PathName name '-'  handles.GroupNames{handles.GroupsSelected(ii)} '-' str '-' '.txt'],outCell);
                    end
                end
            elseif (filetype == 0)
                xlswrite([PathName FileName],handles.plotX{:},i,'A3');
                xlswrite([PathName FileName],rot90(handles.BrainStrings(brain)),i,'B2');
                            
                
                if(i==1)
                    xlswrite([PathName FileName],handles.Results,i,'B3');
                else
                    xlswrite([PathName FileName],handles.Results2,i,'B3');
                end
            end
        end
        
    end
   end
end


function Save_Callback(hObject, eventdata, handles)    % save statistics results 
global result_path;

answer = inputdlg('Enter Savename','Enter Savename',1);
if(~isempty(answer))
    if exist([result_path filesep 'FileID.mat'],'file')
        load([result_path filesep 'FileID']);
    else
        id = 0;
    end
    id = id+1;
    save([result_path filesep 'FileID'],'id');
    copyfile([result_path filesep 'CorrResults'],[result_path filesep 'Saved' filesep num2str(id)])
    info.dateTime = now();
    info.name = answer;
    save([result_path filesep 'Saved' filesep num2str(id) filesep 'info'],'info');
end


function Load_Callback(hObject, eventdata, handles)
global result_path;
dirs = dir([result_path filesep 'Saved']);
cmenu = uicontextmenu;
uimenu(cmenu, 'label','Last Results','Callback',{@loadSession,'CorrResults'});

for i = 3:length(dirs)
    if(dirs(i).isdir)
        load([result_path filesep 'Saved' filesep dirs(i).name filesep 'info.mat']);
        uimenu(cmenu, 'label',info.name{:},'Callback',{@loadSession,['Saved' filesep dirs(i).name]});
    end
end

set(handles.Load,'uicontextmenu',cmenu);

hObject_pos = getPositionOnFigure(handles.Load,'pixels');
pos = hObject_pos(1:2);
set(cmenu,'Position',pos);
set(cmenu,'Visible','on');

function loadSession(callback1, callback2,item )
Results(item);

function position = getPositionOnFigure( hObject,units )
%GETPOSITIONONFIGURE returns absolute position of object on a figure
hObject_pos=getRelPosition(hObject,units);
parent = get(hObject,'Parent');
parent_type = get(parent,'Type');
if isequal(parent_type,'figure')
    position = hObject_pos;
    return;
else
    parent_pos = getPositionOnFigure( parent,units );
    position = relativePos2absolutePos(hObject_pos,parent_pos,units);
end

function hObject_pos = getRelPosition( hObject,units )
%this function returns get(hObject,'Position') while with 'units' provided
old_units=get(hObject,'units');
set(hObject,'units',units);
hObject_pos=get(hObject,'Position');
set(hObject,'units',old_units);

function sigVars_Callback(hObject, eventdata, handles)
alphaStr = get(handles.AlphaLevel,'String');
alphaLvl = str2double(alphaStr);
corAlpha = Results_doCorrection(handles,hObject,squeeze(handles.Results2),alphaLvl);
[row,col] =  find(handles.Results2 < corAlpha);
sigC = histc(col,1:size(handles.Results2,2));
nSig = str2double(get(handles.nSig,'String'));
if(isnan(nSig))
    errordlg('Significant Filter : Invalid Number');
    nSig = 2;
end

elements = find(sigC>nSig);

if(isempty(elements))
    errordlg('No Variables with criteria found');
    return;
end

if(handles.PlotType == 1)
    if(sum(get(handles.L_Var,'Value') == 1) == 1)
        set(handles.L_Var,'Value',elements+1);
    else
        selected = get(handles.L_Var,'Value');
        set(handles.L_Var,'Value',selected(elements));
    end
elseif  (handles.PlotType == 2) || (handles.PlotType == 3)
    selected = get(handles.L_brain,'Value');
    set(handles.L_brain,'Value',selected(elements));
end
Results_PlotView(hObject,handles);

function correction_type_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);
function PValues_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);
function AlphaLevel_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);
function CorBrain_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);
function CorThresh_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);
function CorGraph_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);
function CorVar_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);
function L_brain_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);
function mod_func_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);
function HideNSig_Check_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);
function Var2_Callback(hObject, eventdata, handles)
Results_PlotView(hObject, handles);
function L_Var_Callback(hObject, eventdata, handles)
Results_PlotView(hObject, handles)
function L_Graph_Callback(hObject, eventdata, handles)
Results_PlotView(hObject, handles)
function L_Brain_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,  handles)
function L_thresh_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,  handles)
function show_random_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);
function showGroupVal_check_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);


% --- Executes on selection change in GroupTestChooser.
function GroupTestChooser_Callback(hObject, eventdata, handles)

Results_PlotView(hObject,handles);

% --- Executes during object creation, after setting all properties.
function GroupTestChooser_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AllGroups.
function AllGroups_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);

% --- Executes on button press in ShowAllDiff.
function ShowAllDiff_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);


% --- Executes on button press in AnovaSig.
function AnovaSig_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);


% --- Executes when ResultFig is resized.
function ResultFig_ResizeFcn(hObject, eventdata, handles)
Global_ResizeFcn(hObject, eventdata, handles)


% --- Executes on button press in OpenVP.
function OpenVP_Callback(hObject, eventdata, handles)
global result_path;
global result_folder;
if isappdata(hObject,'isPlotMode') && getappdata(hObject,'isPlotMode')
    set(hObject,'String','Open Single Subject');
    set(hObject,'BackgroundColor',getappdata(hObject,'backgroudDefault'));
    setappdata(hObject,'isPlotMode',0) 
    set(handles.ResultFig,'windowbuttonmotionfcn',{});
    set(findall(handles.PlotDisable, '-property', 'enable'), 'enable', 'on')
    set(findall(handles.PlotDisable2, '-property', 'enable'), 'enable', 'on')
    set(findall(handles.PlotDisable3, '-property', 'enable'), 'enable', 'on')
    set(handles.Open_PlotMatrix, 'enable', 'on')

    
    set(handles.WindowPanel,'Visible','Off');
    image(imread('GraphVar_Big.png'));
    axis off
    axis image 
    %set(hObject,'Units','Pixels');
else  
    Results = load(handles.orgFiles{1});

    names = fieldnames(Results);
    
    idx = find(strcmp(names,'is_dyn'), 1);
    if ~isempty(idx) && Results.is_dyn == 1;
        setappdata(hObject,'isDyn',1)
        names(end+1) = {'Dynamic Mean Matrix'};
        is_dyn = 1;
    else
        is_dyn = 0;
        setappdata(hObject,'isDyn',0)
    end
    
    
    if ~isempty(idx)
        names(idx) = [];
        
    end
    
    [Selection,ok] = listdlg('ListString',names,...
        'SelectionMode','single',...
        'PromptString','Select a Variable:');
    if ok  
        
        
        handles.vpBrowser.curPos = 1;
        [BrainMap] = importSpreadsheet(handles.brainsheet);
        BrainCriteria = cell2mat(BrainMap(:,1));
        BrainMap = BrainMap(:,2);
        [~,loc] = ismember(handles.BrainStrings,BrainMap);

        handles.vpBrowser.BrainMap = loc;

        if is_dyn && Selection == length(names)
            handles.vpBrowser.length = 1;
            handles.vpBrowser.var = 'dynamicMeanMatrixOut';
            handles.loadedFiles = {[result_path filesep handles.InterimResultsID  filesep 'MeanMatrix.mat']};
            loadAndDisplay(handles.loadedFiles{1}, 'dynamicMeanMatrixOut', handles)
        else
            handles.vpBrowser.length = length(handles.orgFiles);
            handles.vpBrowser.var = names{Selection};
            handles.loadedFiles = handles.orgFiles;
            loadAndDisplay(handles.loadedFiles{1}, names{Selection}, handles)
        end
        set(handles.Open_PlotMatrix, 'enable', 'off')
        set(findall(handles.PlotDisable, '-property', 'enable'), 'enable', 'off')
        set(findall(handles.PlotDisable2, '-property', 'enable'), 'enable', 'off')
        set(findall(handles.PlotDisable3, '-property', 'enable'), 'enable', 'off')
        set(hObject,'String','Exit Plot Mode');
        setappdata(hObject,'backgroudDefault',get(handles.Open_PlotMatrix,'BackgroundColor')) 
        set(hObject,'BackgroundColor',[1 0 0]);
        setappdata(hObject,'isPlotMode',1) 
        
        if(is_dyn)
            set(handles.WindowPanel,'Visible','On');
        end
    end
end
guidata(hObject,handles);   


% --- Executes on button press in VPForward.
function VPForward_Callback(hObject, eventdata, handles)
if isfield(handles, 'vpBrowser') && (handles.vpBrowser.length >=  handles.vpBrowser.curPos+1)
    handles.vpBrowser.curPos = handles.vpBrowser.curPos+1;
    loadAndDisplay(handles.loadedFiles{handles.vpBrowser.curPos}, handles.vpBrowser.var,handles);
    guidata(hObject,handles);
end

% --- Executes on button press in VPBack.
function VPBack_Callback(hObject, eventdata, handles)
if isfield(handles, 'vpBrowser') && (0 <  handles.vpBrowser.curPos-1)
    handles.vpBrowser.curPos = handles.vpBrowser.curPos-1;
    loadAndDisplay(handles.loadedFiles{handles.vpBrowser.curPos}, handles.vpBrowser.var,handles);
    guidata(hObject,handles);
end
function loadAndDisplay(file, var, handles)
Results = load(file);
window = str2double(get(handles.WindowText,'String'));
if ~isnumeric(window) || (window < 1)
    window = 1;
    set(handles.WindowText,'String','1');
elseif window > length(Results.(var))
    window = length(Results.(var));
    set(handles.WindowText,'String',num2str(window));
end


if getappdata(handles.OpenVP,'isDyn')
    Results.(var) = Results.(var){window}(handles.vpBrowser.BrainMap,handles.vpBrowser.BrainMap);
else
    Results.(var) = Results.(var)(handles.vpBrowser.BrainMap,handles.vpBrowser.BrainMap);
end
imagesc(Results.(var));
colorbar;
text(1,1,file,'Interpreter','none');
set(handles.ResultFig,'windowbuttonmotionfcn',{@pressLoad,handles,Results.(var),Results.(var),1,var});

% --- Executes on button press in windowRight.
function windowRight_Callback(hObject, eventdata, handles)
set(handles.WindowText,'String', num2str(str2double(get(handles.WindowText,'String')) +1)) ;
loadAndDisplay(handles.loadedFiles{handles.vpBrowser.curPos}, handles.vpBrowser.var,handles);


% --- Executes on button press in WindowLeft.
function WindowLeft_Callback(hObject, eventdata, handles)
set(handles.WindowText,'String', num2str(str2double(get(handles.WindowText,'String')) -1)) ;
loadAndDisplay(handles.loadedFiles{handles.vpBrowser.curPos}, handles.vpBrowser.var,handles);

function pressLoad(o,e,h,Results,Results2,Lable,VarName)
h = guidata(h.ResultFig);
pt = get(h.ResultAxes, 'CurrentPoint');
X = get(h.ResultAxes,'XLim');
Y = get(h.ResultAxes,'YLim');
if(pt(1,1) > X(2) || pt(1,1)< X(1)) || (pt(2,2) > Y(2) || pt(2,2)< Y(1))
    return
end
myBrainStr = h.BrainStrings;

pt(:,1) = ceil(pt(:,1)-X(1));
pt(:,2) = round(pt(:,2));


if(~ishandle(h.box))
    h.box = rectangle('Position',[0,0,1,1],'FaceColor','white');
    h.htext = text(0,0,'','FontSize',12,'FontWeight','bold','Interpreter','none');
    guidata(h.ResultFig, h);
end
if(pt(1,1) > X/2)
    set(h.box,'Position',[pt(1,1)-X(2)/5,pt(1,2)-Y(2)/20,X(2)/5,Y(2)/10]);
    set(h.htext, 'string', [myBrainStr(pt(1,1)) myBrainStr{pt(1,2)} [VarName ': ' num2str(Results(pt(1,2),pt(1,1)))]] , 'position', [pt(1,1)-X(2)/5,pt(1,2)]);
else
    set(h.box,'Position',[pt(1,1),pt(1,2)-Y(2)/20,X(2)/5,Y(2)/10]);
    set(h.htext, 'string', [myBrainStr(pt(1,1)) myBrainStr{pt(1,2)} [VarName ': ' num2str(Results(pt(1,2),pt(1,1)))]], 'position', pt(1,:));
end


% --- Executes on button press in Open_PlotMatrix.
function Open_PlotMatrix_Callback(hObject, eventdata, handles)
if isappdata(hObject,'isPlotMode') && getappdata(hObject,'isPlotMode')
    set(handles.Open_PlotMatrix,'String','Plot Conn MeanMatrix');
    set(handles.Open_PlotMatrix,'BackgroundColor',getappdata(hObject,'backgroudDefault'));
    setappdata(hObject,'isPlotMode',0) 
    set(findall(handles.PlotDisable, '-property', 'enable'), 'enable', 'on')
    set(findall(handles.PlotDisable2, '-property', 'enable'), 'enable', 'on')
    set(findall(handles.PlotDisable3, '-property', 'enable'), 'enable', 'on')
    set(findall(handles.PlotDisable4, '-property', 'enable'), 'enable', 'on')
    set(handles.ResultFig,'windowbuttonmotionfcn',{});
    
    set(handles.OpenVP,'Enable','on');
    image(imread('GraphVar_Big.png'));
    axis off
    axis image 
    
else  
    uiwait(helpdlg('The MeanMatrix is stored in your interim results folder (if you have conducted analyses on the raw matrix): Your Workspace/results/interimResult/MeanMatrix.mat'));
    [FileName,PathName,FilterIndex] = uigetfile('*.mat','Select the MeanMatrix: Your Workspace/results/interimResult/MeanMatrix.mat');
    if ~isequal(FileName,0)
        Results = load([PathName filesep FileName]);
        imagesc(Results.meanMatrix);
        colorbar;
        set(handles.ResultFig,'windowbuttonmotionfcn',{@pressLoad,handles,Results.meanMatrix,Results.meanMatrix,1,'MeanMatrix'});
        set(findall(handles.PlotDisable, '-property', 'enable'), 'enable', 'off')
        set(findall(handles.PlotDisable2, '-property', 'enable'), 'enable', 'off')
        set(findall(handles.PlotDisable3, '-property', 'enable'), 'enable', 'off')
        set(findall(handles.PlotDisable4, '-property', 'enable'), 'enable', 'off')
        set(handles.Open_PlotMatrix,'String','Exit Plot Mode');
        setappdata(hObject,'backgroudDefault',get(handles.Open_PlotMatrix,'BackgroundColor')) 
        set(handles.Open_PlotMatrix,'BackgroundColor',[1 0 0]);
        set(handles.OpenVP,'Enable','off');
        setappdata(hObject,'isPlotMode',1) 
    end
end
guidata(hObject,handles);

function WindowText_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function WindowText_CreateFcn(hObject, eventdata, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_network.
function btn_network_Callback(hObject, eventdata, handles)

% --- Save Plot Button action -> % integrate so it saves plot in jpeg 
function save_plot_Callback(hObject, eventdata, handles)

[fname,pth] = uiputfile({'.png'; '.jpeg'; '.eps'; '.pdf'});     
export_fig (gca, (sprintf('%s', fname))) ; 

% 2 dependencies: 1. ghostscript 2. 
% figure out way to clear dependencies 

% train_image = getimage(handles.ResultAxes)
% % print('-depsc2', '-loose', 'test2.eps');
% print('SurfacePlot','-deps','-noui')
Results_PlotView(hObject,handles);


% --- Executes on selection change in alt_metric.
function alt_metric_Callback(hObject, eventdata, handles)
Results_PlotView(hObject,handles);
%allows user selection of alternative metric 

% --- Executes during object creation, after setting all properties.
function alt_metric_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in alt_metric.
function ResultAxes2_CreateFcn(hObject, eventdata, handles)
    % empty




