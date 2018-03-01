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

function varargout = FileViewer(varargin)
% FILEVIEWER MATLAB code for FileViewer.fig
%      FILEVIEWER, by itself, creates a new FILEVIEWER or raises the existing
%      singleton*.
%
%      H = FILEVIEWER returns the handle to a new FILEVIEWER or the handle to
%      the existing singleton*.
%
%      FILEVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILEVIEWER.M with the given input arguments.
%
%      FILEVIEWER('Property','Value',...) creates a new FILEVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FileViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FileViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FileViewer

% Last Modified by GUIDE v2.5 29-Oct-2013 18:47:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FileViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @FileViewer_OutputFcn, ...
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


% --- Executes just before FileViewer is made visible.
function FileViewer_OpeningFcn(hObject, eventdata, handles, varargin)

global workspacePath; 
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FileViewer (see VARARGIN)

% Choose default command line output for FileViewer
handles.output = hObject;

% Update handles structure
load(fullfile(workspacePath,'Workspace.mat'));

[~,handles.BrainStrings] = importSpreadsheet(brainSheet);
handles.BrainStrings = cell2mat(handles.BrainStrings(:,2));
guidata(hObject, handles);

% UIWAIT makes FileViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FileViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ResultList.
function ResultList_Callback(hObject, eventdata, handles)
global workspacePath; 
NL = sprintf('\n');
sel = get(hObject,'Value');
list = dir([workspacePath '/results/Saved/']);
list(1).name = '../CorrResults';
list(2) = [];
load([workspacePath '/results/Saved/' list(sel).name '/VarList.mat' ])
funcStr = []; threStr = []; brainStr = []; outStr = [];
for i=1:3
    for ii = 1:length(VarList.functionList{i})
        funcStr = [funcStr VarList.functionList{i}{ii} ', '];
    end
end
funcStr(end-1:end) = [];

for ii = 1:length(VarList.thresholdsStr)
        threStr = [threStr VarList.thresholdsStr{ii} ', '];
end
if ~isempty(ii)
    threStr(end-1:end) = [];
end
 
brain = handles.BrainStrings(logical(VarList.brainD)) ;
for ii = 1:length(brain)
        brainStr = [brainStr brain{ii} ', '];
end
if ~isempty(ii)
    brainStr(end-1:end) = [];
end


fnames = fieldnames(VarList);
for i = 1:length(fnames)
    if isscalar(VarList.(fnames{i}))
        if isnumeric(VarList.(fnames{i}))
            outStr = [outStr fnames{i} ': ' num2str(VarList.(fnames{i})) NL];
        elseif ischar(VarList.(fnames{i}))
            outStr = [outStr fnames{i} ': ' VarList.(fnames{i}) NL];
        end
        
    end
end


str = [
'Functions: ' funcStr  NL  ...
'Thresholds: '  threStr NL ...
'BrainAreas: ' brainStr NL ... 
outStr ... 
];

set(handles.Description,'String',str);


% --- Executes during object creation, after setting all properties.
function ResultList_CreateFcn(hObject, eventdata, handles)
global workspacePath; 

list = dir([workspacePath '/results/Saved/']);
liststr{1}  = 'Last Results';
for i = 3:length(list)
    load([workspacePath '/results/Saved/' list(i).name '/info.mat' ])
    liststr(end+1) = info.name; 
end


set(hObject,'String',liststr);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
