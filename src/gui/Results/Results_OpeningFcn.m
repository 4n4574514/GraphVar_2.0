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


function Results_OpeningFcn(hObject, eventdata, handles, varargin)
global result_path;
global result_folder;
global isNetFuncGUI;
isNetFuncGUI = 0;
global workspacePath; 

set(handles.ResultFig,'windowbuttonmotionfcn',{});

image(imread('GraphVar_Big.png'));
axis off
axis image 

set(hObject,'Units','Pixels');
handles.startSize = get(hObject,'Position');

load(fullfile(workspacePath,'Workspace.mat'));
[brainSheet variableSheet] =  abs_rel_correct(brainSheet,variableSheet);

result_path = [workspacePath filesep 'results'];

handles.output = hObject; guidata(hObject, handles);

handles.BrainStrings = importSpreadsheet(brainSheet);

if(isempty(varargin))
    result_folder = 'CorrResults';
else
    result_folder = varargin{1};
end
if ~(exist([result_path filesep result_folder filesep 'VarList' '.mat'],'file')==2)
    errordlg('No previous results found');
    delete(hObject);
    return;
end
load([result_path filesep result_folder filesep 'VarList' '.mat']);
handles.InterimResultsID = VarList.InterimResultsID;

functions=getFunctions(1);
handles.BrainStrings = handles.BrainStrings(:,2);
handles.BrainStrings(VarList.brainD == 0) = [];

handles.brainsheet = brainSheet;
handles.orgFiles = files;


handles.nRandom = VarList.nRandom;

if isempty(VarList.ConnectivityThr)
    VarList.ConnectivityThr = 1;
end
handles.ConnectivityThr = VarList.ConnectivityThr;
handles.nShuffel = VarList.nShuffel;

globalFunctionsB = functions{1}([functions{1}{:,3}]==1,:);
globalFunctionsW = functions{2}([functions{2}{:,3}]==1,:);
twoDFunction = [functions{1}([functions{1}{:,3}]==3,:);functions{2}([functions{2}{:,3}]==3,:)];
twoDFunction = twoDFunction(:,2);

networkFunction  = functions{3}(2);
N = VarList.N;
handles.vars = VarList.VarList;
handles.thresholds = VarList.thresholdsStr;
handles.functionList = {VarList.functionList{1}{:} ...
    VarList.functionList{2}{:} ...
    VarList.functionList{3}{:} ...
    VarList.functionList{4}{:}};
handles.Files =  VarList.Files;

handles.box = rectangle('Position',[0,0,1,1],'FaceColor','white');
handles.htext = text(0,0,'','FontSize',12,'FontWeight','bold','Interpreter','none');
handles.globFunc = [globalFunctionsB;globalFunctionsW];
handles.netFunc = networkFunction;
handles.twoDFunc = twoDFunction;

doML = strncmp(handles.Files{1}, 'ML', 2);

set(handles.Var2,'String',{'Pers. Vars','Graph Vars','Thresholds'},'Value',1);
set(handles.L_thresh,'String',VarList.thresholdsStr,'Value',1);


set(handles.L_Var,'String',{'All' VarList.VarList{:}},'Enable','on','Value',1);
set(handles.L_Graph,'String',{'All' handles.functionList{:}},'Enable','on','Value',1);
set(handles.L_brain,'String',{handles.BrainStrings{:}},'Enable','on','Value',1:length(handles.BrainStrings));
set(handles.alt_metric,'Visible','off');

if ~doML 
    set(handles.ResultFig,'CurrentAxes',handles.ResultAxes); 
    cla(handles.ResultAxes2,'reset');
    % hide 2nd Axes
    set(handles.ResultAxes2, 'Units', 'pixels', 'Position', [0.01, 0.01, 0.01, 0.01]);   
     % resize main Results Axes to original format
    set(handles.ResultAxes, 'OuterPosition', [-0.0380    0.0237    1.08   0.8005]); 
end

%% setup for ML Results 
if doML   
    
    set(handles.GroupTestChooser,'Visible','on');
    handles.thresholds = handles.thresholds';
    
    set(handles.L_Var,'String', VarList.ML_Outcome, 'Enable','on','Value',1);   
    set(handles.L_Graph,'String',{'All' handles.functionList{:}},'Enable','inactive','Value',1)
   if ~isempty(VarList.ML_extra)
      if ~isempty(VarList.ML_nuisance)
       set(handles.L_Graph,'String',{'All'...
        handles.functionList{:} VarList.ML_extra{:} VarList.ML_nuisance{:}},'Enable','inactive','Value',1)
      else %has nuisance 
       set(handles.L_Graph,'String',{'All'...
        handles.functionList{:} VarList.ML_extra{:}},'Enable','inactive','Value',1)
     end    
   else %has extra 
       if ~isempty(VarList.ML_nuisance)
           set(handles.L_Graph,'String',{'All'...
            handles.functionList{:} VarList.ML_nuisance{:}},'Enable','inactive','Value',1)
          else %has nuisance 
           set(handles.L_Graph,'String',{'All'...
            handles.functionList{:}},'Enable','inactive','Value',1)
       end    
   end
 
    set(handles.L_brain,'Enable','on','Value',1:length(handles.BrainStrings));
    set(handles.L_thresh,'Enable','on','Value', 1); 
 
    set(handles.export_btn,'Enable','off');
    set(handles.save_plot,'Enable','off');
    set(handles.alt_metric,'Visible','off');

    %grey out buttons only relevant for GLM    .... 
    set(handles.VPBack ,'Enable','off');                       
    set(handles.OpenVP ,'Enable','off');                      
    set(handles.VPForward ,'Enable','off') ;                 
    set(handles.Open_PlotMatrix ,'Enable','off') ;         
    set(handles.Var2,'Enable','off') ; 
    %correction panel items... 
    set(handles.correction_type ,'Enable','off')  ;    
    set(handles.CorrectedAlpha ,'Enable','off')  ;    
    set(handles.CorVar ,'Enable','off')     ;
    set(handles.CorGraph ,'Enable','off')    ;
    set(handles.CorThresh ,'Enable','off')    ;
    set(handles.CorBrain ,'Enable','off')  ;  
    set(handles.btn_network ,'Enable','off') ; 
    %top
    set(handles.nSig ,'Enable','off')  ;  
    set(handles.sigVars ,'Enable','off')  ;  
    set(handles.mod_func ,'Enable','off') ;  
    set(handles.Save ,'Enable','off') ;  
    set(handles.Load ,'Enable','off') ;  
    set(handles.AlphaLevel ,'Enable','off') ;  
    set(handles.PValues ,'Enable','off') ;  

end


handles.brainSelect = [];
guidata(hObject, handles);

Results_PlotView(hObject,handles);


