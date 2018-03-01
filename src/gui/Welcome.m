function varargout = Welcome(varargin)
% WELCOME MATLAB code for Welcome.fig
%      WELCOME, by itself, creates a new WELCOME or raises the existing
%      singleton*.
%
%      H = WELCOME returns the handle to a new WELCOME or the handle to
%      the existing singleton*.
%
%      WELCOME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WELCOME.M with the given input arguments.
%
%      WELCOME('Property','Value',...) creates a new WELCOME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Welcome_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Welcome_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Welcome

% Last Modified by GUIDE v2.5 04-Jul-2013 17:12:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Welcome_OpeningFcn, ...
                   'gui_OutputFcn',  @Welcome_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before Welcome is made visible.
function Welcome_OpeningFcn(hObject, eventdata, handles, varargin)
global root_path;
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Welcome (see VARARGIN)

% Choose default command line output for Welcome
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(gcf,'javaframe');
jIcon=javax.swing.ImageIcon([ root_path 'src\gui\GraphVar\Icon.png']);
jframe.setFigureIcon(jIcon);  
warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');



% UIWAIT makes Welcome wait for user response (see UIRESUME)
% uiwait(handles.WorkspaceChooser);


% --- Outputs from this function are returned to the command line.
function varargout = Welcome_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function WorkspaceName_Callback(hObject, eventdata, handles)
% hObject    handle to WorkspaceName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WorkspaceName as text
%        str2double(get(hObject,'String')) returns contents of WorkspaceName as a double


% --- Executes during object creation, after setting all properties.
function WorkspaceName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WorkspaceName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NewWorkspace.
function NewWorkspace_Callback(hObject, eventdata, handles)
global workspace_path;
global root_path;
cd(root_path);
workspacename =get(handles.WorkspaceName,'String');
if isempty(workspacename)
    errordlg('Please enter a workspace name','Error creating workspace');
    return
end   

if exist(fullfile(workspace_path,workspacename),'file')
    errordlg('A workspace with this name already exists','Error creating workspace');
    return
end

status = mkdir(fullfile(workspace_path,workspacename));

if status == 0
    errordlg('The workspace could not be created. There are probably illagal characters in the name','Error creating workspace');
    return
end

data_path       = fullfile('workspaces' , workspacename,'data');
result_path     = fullfile('workspaces', workspacename,'results');
brainSheet      = 'BrainRegions.csv';
variableSheet   = 'Variables.csv';
ConfigBrainViewer = 'ConfigBrainViewer.mat';
fieldName       = 'CorrMatrix';
filename_start  = 0;
filename_end    = 20;
partVar = 1;
corrVar = 2;

mkdir(data_path);
mkdir([data_path '/Signals']);
mkdir([data_path '/CorrMatrix']);

mkdir(result_path);

mkdir(fullfile(result_path,'Saved'));
mkdir(fullfile(result_path,'CorrResults'));
mkdir(fullfile(result_path,'CorrMatrix'));
mkdir(fullfile(result_path,'SICEMatrix'));
mkdir(fullfile(result_path,'CorrectedAlpha'));
mkdir(fullfile(result_path,'RandomizedTimeSeries'));
mkdir(fullfile(result_path,'FragCheck'));

copyfile(fullfile(root_path,'SampleData','BrainRegions.csv'),fullfile('workspaces', workspacename,brainSheet));
copyfile(fullfile(root_path,'SampleData','Variables.csv'),fullfile('workspaces', workspacename,variableSheet));
copyfile(fullfile(root_path,'src','ConfigBrainViewer.mat'),fullfile('workspaces', workspacename,ConfigBrainViewer));

save(fullfile(workspace_path,workspacename,'Workspace.mat'),'data_path','brainSheet','variableSheet','fieldName','filename_start','filename_end','partVar' ,'corrVar');
InterimResultsID = 0;
save([workspace_path filesep workspacename filesep 'results' filesep 'InterimResultsID.mat'],'InterimResultsID');

mkdir(fullfile(result_path,'default','RandomizedShuffel'));
mkdir(fullfile(result_path,'default','GraphVars'));


delete(handles.WorkspaceChooser); 
GraphVar('Workspace',fullfile(workspace_path,workspacename));

% --- Executes on selection change in ExistingProjects.
function ExistingProjects_Callback(hObject, eventdata, handles)
if strcmp(get(handles.WorkspaceChooser,'SelectionType'), 'open') 
    LoadWorkspace_Callback(hObject, eventdata, handles);
end



% --- Executes on button press in LoadWorkspace.
function LoadWorkspace_Callback(hObject, eventdata, handles)
global workspace_path;
str = get(handles.ExistingProjects, 'String');
workspace = str(get(handles.ExistingProjects, 'value'));
delete(handles.WorkspaceChooser); 
if iscell(workspace)
    workspace = workspace{:};
end
GraphVar('Workspace',fullfile(workspace_path,workspace));


% --- Executes during object creation, after setting all properties.
function ExistingProjects_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExistingProjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global workspace_path;
pathDir = dir(workspace_path);
isub = [pathDir(:).isdir];
nameFolds = {pathDir(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];

set(hObject,'String',nameFolds);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
