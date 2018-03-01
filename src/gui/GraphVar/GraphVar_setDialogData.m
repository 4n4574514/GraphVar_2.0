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

function GraphVar_setDialogData(hObject,bla,handles,dialogData)


%%% SECTION GENERAL SETTINGS


if ~strcmp(dialogData.brainXLS,get(handles.edit_brainxls,'String'))
    set(handles.edit_brainxls,'String',dialogData.brainXLS) ;
end

if ~strcmp(dialogData.variableXLS,get(handles.edit_varxls,'String'))
    set(handles.edit_varxls,'String',dialogData.variableXLS) ;
end

set(handles.subjects,'String',dialogData.subjects) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPLEMENT LOADING DIFFERENT VARIABLES OR BRAIN REAGIONS!!!!  
%%%%%%%%%%%%%%%%%%%%%%%%%%


set(handles.filename_start,'String',dialogData.subjectNamePos(1)) ;
set(handles.filename_end,'String',dialogData.subjectNamePos(2)) ;
set(handles.MatrixName,'String',dialogData.MatrixName) ;

[pathstr,name,ext] = fileparts(dialogData.subjects{1});

set(handles.FileName_Selector,'String',[name ext]);
set(handles.newInterimResults_check,'Value',1) ;


%%% SECTION NETWORK CONSTRUCTION


if dialogData.thresholdType == 1
    set(handles.Rel_radio,'Value',1) ;
    thresh = get(handles.list_thresholds_var,'String');
    [~,loc] = ismember(dialogData.thresholdsStr,thresh);
    set(handles.list_thresholds_var,'Value',loc);
    set(handles.list_thresholds_var, 'ListboxTop', 1);
elseif dialogData.thresholdType == 2
    set(handles.Abs_Radio,'Value',1) ;
    thresh = get(handles.list_thresholds_var2,'String');
    [~,loc] = ismember(dialogData.thresholdsStr,thresh);
    set(handles.list_thresholds_var2,'Value',loc);
    set(handles.list_thresholds_var2, 'ListboxTop', 1);
elseif dialogData.thresholdType == 3
    set(handles.Significant_Radio,'Value',1) ;
    thresh = get(handles.list_thresholds_Sig,'String');
    [~,loc] = ismember(dialogData.thresholdsStr,thresh);
    set(handles.list_thresholds_Sig,'Value',loc);
    set(handles.list_thresholds_Sig, 'ListboxTop', 1);
elseif dialogData.thresholdType == 5
    set(handles.SICE_Radio,'Value',1) ;
    thresh = get(handles.threshold_list_SICE,'String');
    [~,loc] = ismember(dialogData.thresholdsStr,thresh);
    set(handles.threshold_list_SICE,'Value',loc);
    set(handles.threshold_list_SICE, 'ListboxTop', 1);    
end
GraphVar_ThreshType_SelectionChangeFcn(hObject, 0, handles, 1)


set(handles.RandomNetwork_check,'Value',dialogData.nRandom~=0); 
GraphVar_RandomNetwork_check_Callback(hObject, 0, handles);
if dialogData.nRandom~=0
    set(handles.RandomNetwork_n,'String',num2str(dialogData.nRandom));    
    Rfunctions = get(handles.RandomNetwork_func,'String');
    [~,loc] = ismember(dialogData.randomNetwork_func,Rfunctions);
    set(handles.RandomNetwork_func,'Value',loc)
    set(handles.RandomNetwork_func, 'ListboxTop', 1);
    set(handles.RandomNetwork_iter,'String',num2str(dialogData.randomIter))
    set(handles.binary_check,'Value',dialogData.randBinary)
    set(handles.weighted_check,'Value',dialogData.randWeighted)
end

loc = find(dialogData.brainD == 1);
set(handles.list_brainareas,'Value',loc)


%%% SECTION NETWORK CALCULATIONS

if isempty(dialogData.functionList{1}) && isempty(dialogData.functionList{2})
    set(handles.DoGraph,'Value',0)
else
    set(handles.DoGraph,'Value',1)
end

set(handles.normalize,'Value',dialogData.normalize)
set(handles.RandomNetwork_smallWorld,'Value',dialogData.RandomNetwork_smallWorld)
set(handles.list_brainvars_var,'Value',dialogData.functionsIndex)

%%% SECTION RAW MATRIX

if isempty(dialogData.functionList{3}) 
    set(handles.DoNetwork,'Value',0)
else
    set(handles.DoNetwork,'Value',1)
end

set(handles.r2z_check,'Value',dialogData.R2Z)
set(handles.ConnectivityThr_Check,'Value',dialogData.ConnectivityThr_bool)
if dialogData.ConnectivityThr_bool
    thresh = cellstr(num2str(dialogData.ConnectivityThr,'%f'));
    [~, thresh] = strtok(thresh,'.');
    thresh_Box = get(handles.ConnectivityThr_Listbox,'String');
    [~,loc] = ismember(thresh,thresh_Box);

    set(handles.ConnectivityThr_Listbox,'Value',loc)
    set(handles.ConnectivityThr_Listbox, 'ListboxTop', 1);
end

set(handles.shuffel_check,'Value',dialogData.nShuffel~=0)
set(handles.shuffel_n,'Value',dialogData.nShuffel)
set(handles.RandomRawIter,'String',num2str(dialogData.RandomRawIter))

Rfunctions = get(handles.raw_random,'String');
[~,loc] = ismember(dialogData.shuffleRandom,Rfunctions);
if loc > 0 
    set(handles.raw_random,'Value',loc)
end

GraphVar_shuffel_check_Callback(hObject, 0, handles);
GraphVar_DoNetwork_Callback(hObject, 0, handles);
 

if isfield(dialogData,'statsType')

    %%% SECTION Statistics
    switch dialogData.statsType
        case {'Correlation'}
            set(handles.corr_check,'Value',1);       
            VarListBox = get(handles.list_variables_cor,'String');
            [~,loc] = ismember(dialogData.VarList,VarListBox);
            set(handles.list_variables_cor,'Value',loc);
            GraphVar_corr_check_Callback(hObject, 0, handles);

        case 'Partial'
            set(handles.partial_check,'Value',1);       
            VarListBox = get(handles.list_variables_cor,'String');
            [~,loc] = ismember(dialogData.VarList,VarListBox);
            set(handles.list_variables_cor,'Value',loc);

            CovarListBox = get(handles.list_covars_cor,'String');
            [~,loc] = ismember(dialogData.CovarList,CovarListBox);
            set(handles.list_covars_cor,'Value',loc);
            GraphVar_partial_check_Callback(hObject, 0, handles);
        case 'Group'
            set(handles.groupCompair_check,'Value',1);       
            VarListBox = get(handles.list_GroupCompair,'String');
            [~,loc] = ismember(dialogData.VarList,VarListBox);
            set(handles.list_GroupCompair,'Value',loc);
            GraphVar_groupCompair_check_Callback(hObject, 0, handles);
    end

    %set(handles.TestAgainstRandom,'Value',dialogData.testAgainstRandGroup)
    %set(handles.testRawAgainstRandom_check,'Value',dialogData.testAgainstShuffel)
    %set(handles.testAgainstRandGroup_check,'Value',dialogData.testAgainstRandGroup)

    set(handles.nRandGroups,'Value',dialogData.nRandGroup)
    set(handles.Corr,'Enable','on');
end

