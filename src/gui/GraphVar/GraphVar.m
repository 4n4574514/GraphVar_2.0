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

function varargout = GraphVar(varargin)
% GRAPHVAR MATLAB code for GraphVar.fig
%      GRAPHVAR, by itself, creates a new GRAPHVAR or raises the existing
%      singleton*.

% Last Modified by GUIDE v2.5 22-Sep-2017 04:37:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GraphVar_OpeningFcn, ...
    'gui_OutputFcn',  @GraphVar_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

%************************************************************************%

 

%************************************************************************%

%% ENABLE/DISABLE LISTS WHEN THRESHOLD TYPE IS CHANGED
function ThreshType_SelectionChangeFcn(hObject, eventdata, handles, isLoaded)
GraphVar_ThreshType_SelectionChangeFcn(hObject, eventdata, handles, 0)

%************************************************************************%
% MOUSE OVER DISABLED BY DEFAULT NOW. TO ACTIVATE: UNCOMMENT THE FOLLOWING FUNCTION AND GENERATE AN AUTOMATIC CALLBACK FROM THE GRAPHVAR.FIG ON list_brainvars_var  


%% IF IS CLICKED ON A GRAPHVAR ACTIVATE TOOLTIP HELP
% function list_brainvars_var_Callback(hObject, eventdata, handles)
% hListbox = hObject;
% jScrollPane = findjobj(hListbox);
% jListbox = jScrollPane.getViewport.getComponent(0);
% warning('off','MATLAB:hg:JavaSetHGProperty')
% set(jListbox, 'MouseMovedCallback', {@GraphVar_mouseMovedCallback_Vars,hListbox,jListbox,handles});
% warning('on','MATLAB:hg:JavaSetHGProperty');
% GraphVar_settingsChanged(handles)


%************************************************************************%
%%%% calculate stats button that takes to results interface> 
%% CALCULATE AND CORRELATE
function Btn_calcCorr_Callback(hObject, eventdata, handles)
GraphVar_enable_disable(handles,'Off');
[res allTask] = GraphVar_calc(handles);      %%%%%%???????
if(res)
    GraphVar_corr(handles,allTask)
end

GraphVar_enable_disable(handles,'On');



%************************************************************************%
%% ONLY CORRELATE
function Corr_Callback(hObject, eventdata, handles)
GraphVar_enable_disable(handles,'Off');
GraphVar_corr(handles);
GraphVar_enable_disable(handles,'On');

%************************************************************************%
%% AFTER FINISHED CLOSE DLG
function closeWait(src,arg2,arg3)
global running
global wait;
delete(gcf);
running = 0;
%************************************************************************%

% --- Executes when figure1 is resized.
function GraphVar_ResizeFcn(hObject, eventdata, handles)
global isRegisterd;
if(~isRegisterd)
jEditbox = findjobj(handles.FileName_Selector);
if(isempty(jEditbox))
    return;
end
jbh = handle(jEditbox,'CallbackProperties');
set(jbh,'CaretUpdateCallback',{@GraphVar_FileName_selection_change,handles})
isRegisterd = 1;
end

function partial_check_files_Callback(hObject, eventdata, handles)
if(get(handles.partial_check_files,'Value') == 1)
    helpdlg('Computes the linear partial correlation coefficients between pairs of variables in X, controlling for the remaining variables in X. X is an n-by-p matrix, with rows corresponding to observations, and columns corresponding to variables')
set(handles.spearman_check_files,'Value',0)
set(handles.bend_check_files,'Value',0)
set(handles.mutual_check_files,'Value',0)
set(handles.SICEdense_check_files,'Value',0)
set(handles.covariance,'Value',0)
end
GraphVar_settingsChanged(handles)

% --- Executes on button press in spearman_check_files.
function spearman_check_files_Callback(hObject, eventdata, handles)
if(get(handles.spearman_check_files,'Value') == 1)
    helpdlg('Computes Spearman correlation as provided in the Corr_toolbox 2012 (by Cyril Pernet)')
set(handles.partial_check_files,'Value',0)
set(handles.bend_check_files,'Value',0)
set(handles.mutual_check_files,'Value',0)
set(handles.SICEdense_check_files,'Value',0)
set(handles.covariance,'Value',0)           
end
GraphVar_settingsChanged(handles)

function bend_check_files_Callback(hObject, eventdata, handles)
if(get(handles.bend_check_files,'Value') == 1)
        helpdlg('Computes the percentage bend correlation as provided in the Corr_toolbox 2012 (by Cyril Pernet and Guillaume Rousselet; "Robust Correlation Analyses: False Positive and Power Validation Using a New Open Source Matlab Toolbox")')
set(handles.partial_check_files,'Value',0)
set(handles.spearman_check_files,'Value',0)
set(handles.mutual_check_files,'Value',0)
set(handles.SICEdense_check_files,'Value',0)
set(handles.covariance,'Value',0)
end
GraphVar_settingsChanged(handles)

function mutual_check_files_Callback(hObject, eventdata, handles)
if(get(handles.mutual_check_files,'Value') == 1)
      helpdlg('This operation is time consuming and will generate the connectivity matrix based on mutual information (MI) between nodes (as in the CONN toolbox). The mat array will still be called "CorrMatrix", although it is an "Information Matrix". There are no parametric p-values for MI.')
set(handles.partial_check_files,'Value',0)
set(handles.spearman_check_files,'Value',0)
set(handles.bend_check_files,'Value',0)
set(handles.SICEdense_check_files,'Value',0)           
set(handles.covariance,'Value',0)
end
GraphVar_settingsChanged(handles)

function tetra_check_files_Callback(hObject, eventdata, handles)
if(get(handles.tetra_check_files,'Value') == 1)
      helpdlg('Only works under LINUX Systems so far! Computes the pairwise tetrachoric correlation coefficient (Loewe et al., 2014; Fast construction of voxel-level functional connectivity graphs). To run this function please follow the compilation instructions in the src/ext/corr-m-0.3.1 folder')
set(handles.partial_check_files,'Value',0)
set(handles.spearman_check_files,'Value',0)
set(handles.bend_check_files,'Value',0)
set(handles.mutual_check_files,'Value',0)
set(handles.SICEdense_check_files,'Value',0)
set(handles.covariance,'Value',0)
end
GraphVar_settingsChanged(handles)

function covariance_Callback(hObject, eventdata, handles)
if(get(handles.covariance,'Value') == 1)
      helpdlg('Computes covariance matrices that should be used in combination with the SICE threshold function (Network Construction)')
set(handles.partial_check_files,'Value',0)
set(handles.spearman_check_files,'Value',0)
set(handles.bend_check_files,'Value',0)
set(handles.mutual_check_files,'Value',0)
set(handles.SICEdense_check_files,'Value',0)
end
GraphVar_settingsChanged(handles)

function SICEdense_check_files_Callback(hObject, eventdata, handles)
if(get(handles.SICEdense_check_files,'Value') == 1)
      helpdlg('Computes a binary adjacency matrix with a predefined density using sparse inverse covariance estimation (Huang et al., 2010; Learning brain connectivity of Alzheimers disease by sparse inverse covariance estimation).')
set(handles.partial_check_files,'Value',0)
set(handles.spearman_check_files,'Value',0)
set(handles.bend_check_files,'Value',0)
set(handles.mutual_check_files,'Value',0)
set(handles.covariance,'Value',0)
end
GraphVar_settingsChanged(handles)

function SICE_density_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)

% --- Executes during object creation, after setting all properties.
function SICE_density_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SlidingWindows_Callback(hObject, eventdata, handles)
if(get(handles.SlidingWindows,'Value') == 1)
      helpdlg('Performs sliding windows technique with a defined window length and step size (if matrices created with this option are loaded into GraphVar, it will perform all functions with respect to dynamic brain connectivity.')
end

GraphVar_settingsChanged(handles)

function WindowSize_Callback(hObject, eventdata, handles)
function WindowSize_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function WindowStep_Callback(hObject, ~, handles)
function WindowStep_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%************************************************************************%
%% RELOAD BRAIN REGIONS IF DIFFERENT FILE IS SELECTED
function BrainSelect_Callback(hObject, eventdata, handles)
global Brain_Atlas
global workspacePath
[filename, pathname] = uigetfile({'*.xls;*.xlsx','Excel Sheet (.xsl)';'*.csv;','Character-separated values (semicolon) (.csv)'}, 'Select a brain region sheet');
if ~isequal(filename,0)
    Brain_Atlas = [pathname filename];
    [handles.BrainMap,handles.brain] = GraphVar_loadBrainRegions(hObject, eventdata, handles,Brain_Atlas);
    
   if strcmp([workspacePath filesep],pathname)
        set(handles.edit_brainxls,'String',filename,'Value',1);
   else
        set(handles.edit_brainxls,'String',Brain_Atlas,'Value',1);
   end    
    
    guidata(handles.GraphVar, handles);
end

%************************************************************************%
%% RELOAD VARIABLES IF DIFFERENT FILE IS SELECTED
function FileSelect_Callback(hObject, eventdata, handles)
global NeoData_Atlas;
global workspacePath

[filename, pathname] = uigetfile({'*.xls;*.xlsx','Excel Sheet (.xsl)';'*.csv;','Character-separated values (semicolon) (.csv)'}, 'Select a variables sheet');
if ~isequal(filename,0)
    NeoData_Atlas = [pathname filename];
    GraphVar_loadVariables(hObject, eventdata, handles,1,NeoData_Atlas)
    
    set(handles.list_between_vars, 'String', {});
    set(handles.list_cov_vars, 'String', {});
    set(handles.list_within_vars, 'String', {});
    set(handles.list_nuisance_vars, 'String', {});
 
    %%%add groups and svm var list here too
    set(handles.list_response, 'String', {});
    set(handles.list_extra_feat, 'String', {});
    set(handles.list_nuisance_covariates, 'String', {});
    
   if strcmp([workspacePath filesep],pathname)
        set(handles.edit_varxls,'String',filename);
   else
        set(handles.edit_varxls,'String',[pathname filename]);
   end    

end


%************************************************************************%
% MOUSE OVER DISABLED BY DEFAULT NOW. TO ACTIVATE: UNCOMMENT THE FOLLOWING FUNCTION AND GENERATE AN AUTOMATIC CALLBACK FROM THE GRAPHVAR.FIG

%************************************************************************%
% %% ACTIVATE TOOLTIP HELP FOR RANDOM FUNC
% function RandomNetwork_func_Callback(hObject, eventdata, handles)
% hListbox = handles.RandomNetwork_func;
% jScrollPane = findjobj(hListbox);
% jListbox = jScrollPane.getViewport.getComponent(0);
% warning('off','MATLAB:hg:JavaSetHGProperty')
% set(jListbox, 'MouseMovedCallback', {@GraphVar_mouseMovedCallback_Random,hListbox,jListbox,handles});
% warning('on','MATLAB:hg:JavaSetHGProperty')
% GraphVar_settingsChanged(handles)

%************************************************************************%
function DoNetwork_Callback(hObject, eventdata, handles)
GraphVar_DoNetwork_Callback(hObject, eventdata, handles);

%************************************************************************%
%% IF FIGURE GETS CLOSED
function GraphVar_CloseRequestFcn(hObject, eventdata, handles)
GraphVar_saveSettings(handles);
delete(hObject);


%************************************************************************%
function varargout = GraphVar_OutputFcn(hObject, eventdata, handles)

function RandomNetwork_check_Callback(hObject, eventdata, handles)
GraphVar_RandomNetwork_check_Callback(hObject, eventdata, handles);
GraphVar_settingsChanged(handles);

function binary_check_Callback(hObject, eventdata, handles)
if get(handles.RandomNetwork_check,'Value') &&  (~(get(handles.binary_check,'Value') && get(handles.weighted_check,'Value')));
    set(handles.weighted_check,'Value',1)
end
GraphVar_settingsChanged(handles)

function weighted_check_Callback(hObject, eventdata, handles)
if get(handles.RandomNetwork_check,'Value') &&  (~(get(handles.binary_check,'Value') && get(handles.weighted_check,'Value')));
    set(handles.binary_check,'Value',1)
end
GraphVar_settingsChanged(handles)


function DoGraph_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)

if get(hObject,'Value')
    set(handles.list_brainvars_var,'Enable','on');
    set(handles.RandomNetwork_smallWorld,'Enable','on') ;
    set(handles.normalize,'Enable','on');

    %hasItem = (~isempty(get(handles.list_cov_vars,'String'))) || (~isempty(get(handles.list_between_vars,'String'))) || (~isempty(get(handles.list_within_vars,'String')));
    %if hasItem
    children = get(handles.graph_metrics_testing,'Children');
    set(children,'Enable','on');

    %end

else
    set(handles.list_brainvars_var,'Enable','off');
    set(handles.RandomNetwork_smallWorld,'Enable','off') ;
    children = get(handles.graph_metrics_testing,'Children');
    set(children,'Enable','off');

    set(handles.normalize,'Enable','off');

    set(handles.RandomNetwork_smallWorld,'Value',0) ;
    %set(handles.graph_metrics_testing,'Value',0)  ;
    set(handles.normalize,'Value',0);
end

% --- Executes when GraphVar is resized.
function Global_ResizeFcn(hObject, eventdata, handles)
Global_ResizeFcn(hObject, eventdata, handles)
    
% --- Executes on button press in Rand_timeseries.
function Rand_timeseries_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)

function timeseriesType_N_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)

% --- Executes on button press in timeseriesType_FFT.
function timeseriesType_FFT_Callback(hObject, eventdata, handles)
if(get(handles.timeseriesType_FFT,'Value') == 1)
      helpdlg('Multivariate algorithm from Prichard, D., & Theiler, J. (1994) using fast fourier transformation (FFT); (Generating surrogate data for time series with several simultaneously measured variables; Physical Review Letters, 73(7), 951.)')
end
GraphVar_settingsChanged(handles)

% --- Executes during object creation, after setting all properties.
function timeseriesType_N_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--- Executes on button press in normalize.
function normalize_Callback(hObject, eventdata, handles)
if get(handles.normalize,'Value')
    set(handles.graph_randNW,'Enable','off')
    set(handles.graph_randNW,'Value',0)
else
    %hasItem = (~isempty(get(handles.list_cov_vars,'String'))) || (~isempty(get(handles.list_between_vars,'String'))) || (~isempty(get(handles.list_within_vars,'String')));
    %if hasItem
        set(handles.graph_randNW,'Enable','on')
    %end
end
GraphVar_settingsChanged(handles)

% --- Executes on selection change in list_brainvars_var.
function list_brainvars_var_Callback(hObject, eventdata, handles)

% --- Executes on button press in shuffel_check.
function shuffel_check_Callback(hObject, eventdata, handles)
GraphVar_shuffel_check_Callback(hObject, eventdata, handles) 
GraphVar_settingsChanged(handles)
 
   
% --- Executes on selection change in list_brainareas.
function list_brainareas_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)


% --- Executes on selection change in list_thresholds_Sig.
function list_thresholds_Sig_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)


% --- Executes on selection change in list_thresholds_var.
function list_thresholds_var_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)


% --- Executes on selection change in list_thresholds_var2.
function list_thresholds_var2_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)

% --- Executes on button press in RandomNetwork_smallWorld.
function RandomNetwork_smallWorld_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)

function RandomNetwork_iter_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)

function RandomNetwork_n_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)

% --- Executes when selected object is changed in uipanel12.
function uipanel12_SelectionChangeFcn(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)

% --- Executes on selection change in raw_random.
function raw_random_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)

% --- Executes during object creation, after setting all properties.
function raw_random_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RandomRawIter_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)

% --- Executes during object creation, after setting all properties.
function RandomRawIter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in r2z_check.
function r2z_check_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)

function shuffel_n_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)

% --- Executes on selection change in ConnectivityThr_Listbox.
function ConnectivityThr_Listbox_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)

% --- Executes during object creation, after setting all properties.
function SpalshImg_CreateFcn(hObject, eventdata, handles)

% --------------------------------------------------------------------
function ThreshType_ButtonDownFcn(hObject, eventdata, handles)

% --- Executes on button press in Switch_Workspace.
function Switch_Workspace_Callback(hObject, eventdata, handles)
delete(handles.GraphVar); 
Welcome();

% --- Executes on button press in partial_check_files.
function checkbox29_Callback(hObject, eventdata, handles)

function edit29_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Rand_timeseries.
function checkbox30_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function generate_btn_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function timeseriesType_Shuffle_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function timeseriesType_Randomize_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function Rand_timeseries_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function partial_check_files_CreateFcn(hObject, eventdata, handles)

% --- Executes on button press in EnableHelp.
function EnableHelp_Callback(hObject, eventdata, handles)

s = fieldnames(handles);
for ii=2:length(s)
if ishandle(handles.(s{ii}))
   if exist(['../../help/' s{ii} '.html'],'file')
        if get(hObject,'Value') 
            fid = fopen(['../../help/' s{ii} '.html']);
            str= fread(fid, inf,'*char')';
            set(handles.(s{ii}),'TooltipString',str);
            fclose(fid);
        else
            set(handles.(s{ii}),'TooltipString','');
        end
   end
end
end

% --- Executes on button press in InterimResults_prev.
function InterimResults_prev_Callback(hObject, eventdata, handles)
global result_path;
global InterimResults_current;

dirs = dir([result_path]);
idx = [dirs.isdir] == 0;
idx(1:2) = 1;
dirs(idx) = [];
[idx,~] = ismember({dirs.name},{'CorrectedAlpha' 'CorrMatrix' 'CorrResults' 'RandomizedTimeSeries' 'Saved'});
dirs(idx) = []; 

if InterimResults_current-1 > 0 && exist([result_path filesep dirs(InterimResults_current-1).name filesep 'info.mat'],'file')
    InterimResults_current = InterimResults_current - 1;
    load([result_path filesep dirs(InterimResults_current).name filesep 'info.mat']);
    GraphVar_openInterimResult(hObject,0,handles,dialogData,InterimResults_current, dirs(InterimResults_current).name);
end

% --- Executes on button press in InterimResults.
function InterimResults_Callback(hObject, eventdata, handles)
global result_path;
global InterimResults_current;

dirs = dir([result_path]);
idx = [dirs.isdir] == 0;
dirs(idx) = [];

[idx,~] = ismember({dirs.name},{'CorrectedAlpha' 'CorrMatrix' 'CorrResults' 'RandomizedTimeSeries' 'Saved'});
dirs(idx) = [];

cmenu = uicontextmenu;
for i = 3:length(dirs)
    if exist([result_path filesep dirs(i).name filesep 'info.mat'],'file')
        load([result_path filesep dirs(i).name filesep 'info.mat']);
        if(i-2 == InterimResults_current)        
            uimenu(cmenu, 'label',['--> ' datestr(dateTime)],'Callback',{@GraphVar_openInterimResultConnectivityThr,handles,dialogData,i-2,dirs(i).name  });
        else
            uimenu(cmenu, 'label',datestr(dateTime),'Callback',{@GraphVar_openInterimResult,handles,dialogData,i-2,dirs(i).name });
        end
    end
end
set(hObject,'uicontextmenu',cmenu);

hObject_pos = getPositionOnFigure(hObject,'pixels');
pos = hObject_pos(1:2);
set(cmenu,'Position',pos);
set(cmenu,'Visible','on');

% --- Executes on button press in newInterimResults_check.
function newInterimResults_check_Callback(hObject, eventdata, handles)

% --- Executes on button press in InterimResults_next.
function InterimResults_next_Callback(hObject, eventdata, handles)
global result_path;
global InterimResults_current;

dirs = dir([result_path]);
idx = [dirs.isdir] == 0;
idx(1:2) = 1;
dirs(idx) = [];
[idx,~] = ismember({dirs.name},{'CorrectedAlpha' 'CorrMatrix' 'CorrResults' 'RandomizedTimeSeries' 'Saved'});
dirs(idx) = []; 

if InterimResults_current+ 1 <= length(dirs) && exist([result_path filesep dirs(InterimResults_current+ 1).name filesep 'info.mat'],'file')
    InterimResults_current = InterimResults_current + 1;
    load([result_path filesep dirs(InterimResults_current).name filesep 'info.mat']);
    GraphVar_openInterimResult(hObject,0,handles,dialogData,InterimResults_current, dirs(InterimResults_current).name);
end

% --- Executes on button press in Unlock_btn.
function Unlock_btn_Callback(hObject, eventdata, handles)
global fid;
GraphVar_enable_disable(handles,'On');
try
fclose(fid);
catch
end

% --- Executes on button press in CreateCorrMatrix_Btn.
function CreateCorrMatrix_Btn_Callback(hObject, eventdata, handles)

function MatrixName_Callback(hObject, eventdata, handles)

%%--- Executes during object creation, after setting all properties.
function editParallelWorkersNumber_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editParallelWorkersNumber_Callback(hObject, eventdata, handles)
Size_MatlabPool =str2double(get(hObject,'String'));
ParallelWorkersNumber = 0;
% Check number of matlab workers. To start the matlabpool if Parallel Computation Toolbox is detected.
isParallel(Size_MatlabPool);
  

function RandomDataRepitions_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function RandomDataRepitions_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    if do_ml_parametric == 1 
   GraphVar_enable_disable(handles,'Off');
    end
end

% --- Executes on button press in weights_negToZero.
function weights_negToZero_Callback(hObject, eventdata, handles)

% --- Executes on button press in weights_absolute.
function weights_absolute_Callback(hObject, eventdata, handles)

% --- Executes on button press in weights_noChange.
function weights_noChange_Callback(hObject, eventdata, handles)

%%%%%%%%%%%% CALLBACKS BUTTONS RAW MATRIX/WEIGHTS %%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in weights_negToZero_raw.
function weights_negToZero_raw_Callback(hObject, eventdata, handles)

% --- Executes on button press in weights_absolute_raw.
function weights_absolute_raw_Callback(hObject, eventdata, handles)

% --- Executes on button press in weights_noChange_raw.
function weights_noChange_raw_Callback(hObject, eventdata, handles)

%%%%%%%%%%% CALLBACKS NETWORK CONSTRUCT/THRESHOLD %%%%%%%%%%%%%%%

% --- Executes on button press in None_Radio.
function None_Radio_Callback(hObject, eventdata, handles)

% --- Executes on button press in SICE_Radio.
function SICE_Radio_Callback(hObject, eventdata, handles)

function threshold_list_SICE_Callback(hObject, eventdata, handles)
GraphVar_settingsChanged(handles)


% --- Executes during object creation, after setting all properties.
function threshold_list_SICE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on button press in pairedT.
% function pairedT_Callback(hObject, eventdata, handles)
% if(get(handles.pairedT,'Value') == 1)
%     helpdlg('Computes a paired ttest. The groups must be defined within one vector (i.e., column in the variable sheet - e.g. "pre" (n=15) "post" (n=15) (i.e., total of 30 subjects, where subject 1 and 16; 2 and 17; 3 and 18 etc. are the same subjects with "pre" and "post" assignments.')
% end

% --- Executes on selection change in DynamicGraphVar.
function DynamicGraphVar_Callback(hObject, eventdata, handles)
index_selected = get(hObject,'Value');
list = get(hObject,'String');
item_selected = list{index_selected}; 
if strcmp(item_selected,'Dynamic community flexibility: only with MULTISLICE affiliation vector') || strcmp(item_selected,'Dynamic community promiscuity: only with MULTISLICE affiliation vector')
    input = inputdlg({'How many iterations do you want to perform to average this dynamic measure?'},'Dynamic Community',1,{'100'});
    input = str2double(input);
    if isnan(input)
       DynamicGraphVar_Callback(hObject, eventdata, handles);
    end
    if isempty(input)
        input = 100; 
    end
    set(handles.n_multislice,'String', input);  

    set(handles.list_brainvars_var,'Enable','off');
    list = get(handles.list_brainvars_var,'String');

    ind = find(ismember(list,'Weighted: MULTISLICE affiliation Vector GENERALIZED Louvain - MULTISLICE affiliation Vector'));
    set(handles.list_brainvars_var,'Value',ind);
else
    if strcmp(item_selected,'Variance over time') || strcmp(item_selected,'Standard Deviation') || strcmp(item_selected,'Periodicity') || strcmp(item_selected,'PointProcess: rate') || strcmp(item_selected,'PointProcess: interval')
        input = 1;
        set(handles.n_multislice,'String', input);
    set(handles.list_brainvars_var,'Enable','on');
    end
end
% --- Executes during object creation, after setting all properties.
function DynamicGraphVar_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over DynamicGraphVar.
function DynamicGraphVar_ButtonDownFcn(hObject, eventdata, handles)

% --- Executes on selection change in DynamicGraphVar2.
function DynamicGraphVar2_Callback(hObject, eventdata, handles)
index_selected = get(hObject,'Value');
list = get(hObject,'String');
item_selected = list{index_selected}; 
if strcmp(item_selected,'Brain-Network Variability')
        input = 1;
        set(handles.n_multislice,'String', input);
    set(handles.ConnectivityThr_Check,'Enable','off');
end
   
% --- Executes during object creation, after setting all properties.
function DynamicGraphVar2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function n_multislice_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function n_multislice_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in list_nuisance_vars.
function list_nuisance_vars_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function list_nuisance_vars_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in list_variables.
function list_variables_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function list_variables_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function nRandGroups_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function nRandGroups_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in list_between_vars.
function list_between_vars_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function list_between_vars_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in list_within_vars.
function list_within_vars_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function list_within_vars_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in list_cov_vars.
function list_cov_vars_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function list_cov_vars_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in add_corr_btn.
function add_corr_btn_Callback(hObject, eventdata, handles)
add_to_field(handles.list_cov_vars,handles)
setFields(handles);

% --- Executes on button press in remove_corr_btn.
function remove_corr_btn_Callback(hObject, eventdata, handles)
remove_from_field(handles.list_cov_vars, handles)
setFields(handles);

% --- Executes on button press in add_between_btn.
function add_between_btn_Callback(hObject, eventdata, handles)
add_to_field(handles.list_between_vars,handles)
setFields(handles);

% --- Executes on button press in remove_between_btn.
function remove_between_btn_Callback(hObject, eventdata, handles)
remove_from_field(handles.list_between_vars,handles)
setFields(handles);

% --- Executes on button press in add_within_btn.
function add_within_btn_Callback(hObject, eventdata, handles)
add_to_field(handles.list_within_vars,handles)
if isempty(get(handles.withinID, 'String'))
    reselectWithinField(handles)
end
setFields(handles);

% --- Executes on button press in remove_within_btn.
function remove_within_btn_Callback(hObject, eventdata, handles)
remove_from_field(handles.list_within_vars,handles)
setFields(handles);

% --- Executes on button press in add_nuisance_btn.
function add_nuisance_btn_Callback(hObject, eventdata, handles)
add_to_field(handles.list_nuisance_vars,handles)
setFields(handles);

% --- Executes on button press in remove_nuisance_btn.
function remove_nuisance_btn_Callback(hObject, eventdata, handles)
remove_from_field(handles.list_nuisance_vars,handles)
setFields(handles);

function edit46_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function edit46_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RandomDataRepitionsML_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function RandomDataRepitionsML_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%                ADD AND REMOVE FROM FIELDS GLM PANEL          %%%%%%%%%
function add_to_field(field,handles)
strings_field = get(field,'String');
selected = get(handles.list_variables,'Value');
strings = get(handles.list_variables,'String');
set(field,'String',[strings_field ; strings(selected)]);
set(handles.list_variables,'Value',[]);
set(handles.list_variables,'String',strings(setdiff(1:length(strings),selected)));

function remove_from_field(field,handles)
strings_field = get(field,'String');
selected = get(field,'Value');
strings = get(handles.list_variables,'String');
set(field,'Value',[]);
set(field,'String',strings_field(setdiff(1:length(strings_field),selected)));
set(handles.list_variables,'String',[strings ; strings_field(selected)]);

%%%%                ADD AND REMOVE FROM FIELDS SVM PANEL          %%%%%%%%%
function add_to_field_svm(field,handles)
strings_field = get(field,'String');
selected = get(handles.list_var_svm,'Value');
strings = get(handles.list_var_svm,'String');
set(field,'String',[strings_field ; strings(selected)]);
set(handles.list_var_svm,'Value',1);
set(handles.list_var_svm,'String', strings(setdiff(1:length(strings),selected)));

function remove_from_field_svm(field,handles)
strings_field = get(field,'String');
selected = get(field,'Value');
strings = get(handles.list_var_svm,'String');
set(field,'Value',[1]);
set(field,'String',strings_field(setdiff(1:length(strings_field), selected)));
set(handles.list_var_svm,'String',[strings ; strings_field(selected)]);

function setFields(handles)

% hasItem = (~isempty(get(handles.list_cov_vars,'String'))) || (~isempty(get(handles.list_between_vars,'String'))) || (~isempty(get(handles.list_within_vars,'String')));
% if hasItem && ~get(handles.normalize,'Value') && get(handles.DoGraph,'Value') 
% 	set(handles.TestAgainstRandom,'Enable','on')  ;
% end
% 
% if hasItem && get(handles.DoNetwork,'Value') 
% 	set(handles.testRawAgainstRandom_check,'Enable','on');
% end
% 
% if ~hasItem || ~get(handles.DoGraph,'Value') 
% 	set(handles.TestAgainstRandom,'Enable','off');
% 	set(handles.TestAgainstRandom,'Value',0);
% end
% 
% if ~hasItem || ~get(handles.DoNetwork,'Value') 
%     set(handles.testRawAgainstRandom_check,'Enable','off');
% 	set(handles.testRawAgainstRandom_check,'Value',0);
% end
% 
% if ~isempty(get(handles.list_cov_vars,'String')) 
% 	set(handles.TestAgainstRandomData,'Enable','on')  ;
% else
% 	set(handles.TestAgainstRandomData,'Enable','off');
% 	set(handles.TestAgainstRandomData,'Value',0);
% end
% 
% 
% hasItem = (~isempty(get(handles.list_between_vars,'String'))) || (~isempty(get(handles.list_within_vars,'String')));
% if hasItem
% 	set(handles.testAgainstRandGroup_check,'Enable','on')  ;
% else
% 	set(handles.testAgainstRandGroup_check,'Enable','off');
% 	set(handles.testAgainstRandGroup_check,'Value',0);
% end

if isempty(get(handles.list_cov_vars,'String'))
    set(handles.remove_corr_btn, 'Enable', 'off');
else
    set(handles.remove_corr_btn, 'Enable', 'on');
end
if isempty(get(handles.list_between_vars,'String'))
    set(handles.remove_between_btn, 'Enable', 'off');
else
    set(handles.remove_between_btn, 'Enable', 'on');
end
if isempty(get(handles.list_within_vars,'String'))
    set(handles.remove_within_btn, 'Enable', 'off');
else
    set(handles.remove_within_btn, 'Enable', 'on');
end
if isempty(get(handles.list_nuisance_vars,'String'))
    set(handles.remove_nuisance_btn, 'Enable', 'off');
else
    set(handles.remove_nuisance_btn, 'Enable', 'on');
end

% SET INTERACTIONS   (field interactions for GLM)
n = length(get(handles.list_cov_vars,'String')) + length(get(handles.list_between_vars,'String')) + length(get(handles.list_within_vars,'String')) + length(get(handles.list_nuisance_vars,'String')) ;
if n > 4 
    n=4;
end
order={'1st', '2nd', '3rd'};
str = {'No Interactions'};
for i=2:n
    str = [str, cellstr(['Interactions '  order{i-1} ' order'])];
end
if get(handles.interactions_Popup,'Value') > length(str)
    set(handles.interactions_Popup,'Value',length(str));   
end
set(handles.interactions_Popup,'String',str);

% define SetFields function for svm panel: (groups) 
function setFieldsML(handles)
if isempty(get(handles.list_response,'String'))
    set(handles.remove_response, 'Enable', 'off');
else
    set(handles.remove_response, 'Enable', 'on');
end
if isempty(get(handles.list_nuisance_covariates,'String'))
    set(handles.remove_nuisance_cov, 'Enable', 'off');
else
    set(handles.remove_nuisance_cov, 'Enable', 'on');
end
if isempty(get(handles.list_extra_feat,'String'))
    set(handles.remove_extra_feat, 'Enable', 'off');
else
    set(handles.remove_extra_feat, 'Enable', 'on');
end

% --- Executes on selection change in interactions_Popup.
function interactions_Popup_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function interactions_Popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function reselectWithinField(handles)
global workspacePath;
load(fullfile(workspacePath,'Workspace.mat'));
[~, variableSheet] =  abs_rel_correct(brainSheet,variableSheet);

if(exist([workspacePath filesep 'ImportSettings.mat'],'file'))
    load([workspacePath filesep 'ImportSettings.mat']);
else
    userVar = 2;
end

[NeoData] = importSpreadsheet(variableSheet);
names = NeoData(1,:);
clear NeoData;
names(userVar) = [];
[selection,ok] = listdlg('PromptString','Select within ID field','ListString',names,'SelectionMode','single');
if(ok)
    selField = names(selection);
else
    return;
end

if iscell(selField)
    selField = [selField{:}];
end

set(handles.withinID,'String',selField);
set(handles.changeWithinID,'String', ['Within ID - ' selField]);
set(handles.clearWithinID,'Visible','On');

% --- Executes on button press in changeWithinID.
function changeWithinID_Callback(hObject, eventdata, handles)
reselectWithinField(handles)

% --- Executes on button press in changeWithinID.
function clearWithinID_Callback(hObject, eventdata, handles)
set(handles.withinID,'String','');
set(handles.changeWithinID,'String', 'Select Within ID');

strings_field = get(handles.list_within_vars,'String');
strings = get(handles.list_variables,'String');
set(handles.list_variables,'String',[strings ; strings_field]);
set(handles.list_within_vars,'String',{});

set(handles.clearWithinID,'Visible','Off');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%   ---------SWITCH BETWEEEN GML AND SVM PANELS---------        %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in show_svm_panel.
function show_svm_panel_Callback(hObject, eventdata, handles)
set(handles.panel_glm,'visible','off')
set(handles.panel_svm,'visible','on')

% --- Executes on button press in show_glm_panel.
function show_glm_panel_Callback(hObject, eventdata, handles)
set(handles.panel_glm,'visible','on')
set(handles.panel_svm,'visible','off')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%        ---------SVM PANEL CALLBACKS AND FUNCTIONS---------    %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%        -------------- CLASSIFIER TYPE------------------     %%%%%%%%%%

function classifier_type_Callback(hObject, eventdata, handles)

if ~strcmp(get(get(handles.tabgroup2, 'SelectedTab'), 'Title'), 'Model Tuning (Nested)')
   
    list = get(handles.classifier_type, 'String');
    Idx = get(handles.classifier_type, 'Value'); 
    model = list(Idx);
    doManual = ~strcmp(get(get(handles.tabgroup2, 'SelectedTab'), 'Title'), 'Model Tuning (Nested)');
    [Name, ~, HYP, ~, ~, ~, ~] = graphvar_ml_models(model, handles.hyperopt_steps, doManual); 
      if numel(Name) == 2 
        set(handles.ml_PString1, 'String', HYP(1))
        set(handles.ml_PString2, 'String', HYP(2))
        set(handles.text124, 'String', Name{1})
        set(handles.text125, 'String', Name{2})
        set(handles.ml_PString2, 'Enable', 'on') 
      else
        set(handles.ml_PString1, 'String', HYP)
        set(handles.ml_PString2, 'Enable', 'off')
        set(handles.ml_PString2, 'String', ' ')
        set(handles.text124, 'String', Name)
        set(handles.text125, 'String', 'Parameter 2')
      end
end
guidata(gcbo, handles);


function classifier_type_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%            --------------CV FOLD #------------------        %%%%%%%%%%

function cv_fold_number_Callback(hObject, eventdata, handles)
guidata(gcbo, handles);
       
% --- Executes during object creation, after setting all properties.
function cv_fold_number_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%     -------------- SELECT FROM (VAR LIST)------------------ %%%%%%%%%%

% --- Executes on selection change in list_var_svm.
function list_var_svm_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function list_var_svm_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%     -------------- ADD AND REMOVE BUTTONS------------------ %%%%%%%%%%

%%%%%%%%%UPDATED, FIXED 
% --- Executes on button press in add_groups_svm.
function add_response_Callback(hObject, eventdata, handles)
add_to_field_svm(handles.list_response,handles)
setFieldsML(handles);

% --- Executes on button press in remove_groups_svm.
function remove_response_Callback(hObject, eventdata, handles)
remove_from_field_svm(handles.list_response,handles)
setFieldsML(handles);

% --- Executes on button press in add_nuisance_cov.
function add_nuisance_cov_Callback(hObject, eventdata, handles)
add_to_field_svm(handles.list_nuisance_covariates,handles)
setFieldsML(handles);

% --- Executes on button press in remove_nuisance_cov.
function remove_nuisance_cov_Callback(hObject, eventdata, handles)
remove_from_field_svm(handles.list_nuisance_covariates,handles)
setFieldsML(handles);

% --- Executes on button press in add_extra_feat.
function add_extra_feat_Callback(hObject, eventdata, handles)
add_to_field_svm(handles.list_extra_feat,handles)
setFieldsML(handles);

% --- Executes on button press in remove_extra_feat.
function remove_extra_feat_Callback(hObject, eventdata, handles)
remove_from_field_svm(handles.list_extra_feat,handles)
setFieldsML(handles);

% --- Executes on selection change in list_extra_feat.
function list_extra_feat_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function list_extra_feat_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%     -------------- RESPONSE & FEATURE LISTS --------------  %%%%%%%%%%

% --- Executes on selection change in list_response.
function list_response_Callback(hObject, eventdata, handles)
guidata(hObject, handles) 

% --- Executes during object creation, after setting all properties.
function list_response_CreateFcn(hObject, eventdata, handles) 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in list_nuisance_covariates.
function list_nuisance_covariates_Callback(hObject, eventdata, handles)
guidata(hObject, handles) 

% --- Executes during object creation, after setting all properties.
function list_nuisance_covariates_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in do_featsel.
function do_featsel_Callback(hObject, eventdata, handles)

% --- Executes on button press in do_hyperopt.
function do_hyperopt_Callback(hObject, eventdata, handles)

function featsel_thres_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function featsel_thres_CreateFcn(hObject, eventdata, handles)

function hyperopt_steps_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function hyperopt_steps_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in do_ml_parametric.
function do_ml_parametric_Callback(hObject, eventdata, handles)

guidata(hObject, handles) 

% --- Executes on button press in do_ml_perm.
function do_ml_perm_Callback(hObject, eventdata, handles)

guidata(hObject, handles) 

% --- not needed 
function ml_parameter_1_Callback(hObject, eventdata, handles)
guidata(hObject, handles) 
function ml_parameter_2_Callback(hObject, eventdata, handles)
guidata(hObject, handles) 

function ml_PString1_Callback(hObject, eventdata, handles)

guidata(hObject, handles) 

% --- Executes during object creation, after setting all properties.
function ml_PString1_CreateFcn(hObject, eventdata, handles)
guidata(hObject, handles) 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit51_Callback(hObject, eventdata, handles)
guidata(hObject, handles) 

% --- Executes during object creation, after setting all properties.
function edit51_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ml_PString2_Callback(hObject, eventdata, handles)
guidata(hObject, handles) 


% --- Executes during object creation, after setting all properties.
function ml_PString2_CreateFcn(hObject, eventdata, handles)
guidata(hObject, handles) 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function manual_tuning_CreateFcn(hObject, eventdata, handles)
guidata(hObject, handles) % overwritten 
