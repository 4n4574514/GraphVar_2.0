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


function [Variables,vpNamesNeo] = GraphVar_loadVariables(hObject, eventdata, handles,askRows,NeoData_Atlas)
global workspacePath;
if(~exist([workspacePath filesep 'ImportSettings.mat'],'file'))
    askRows = 1;
end

NeoPath = get(handles.edit_varxls,'String');
if(~exist(NeoPath,'dir'))
    NeoPath = NeoData_Atlas;
end
if(isempty(NeoPath)) 
    Variables  = [];
    vpNamesNeo = [];
    return;
end
NeoData = importSpreadsheet(NeoPath);

Variables = NeoData(1,:);
containsNumbers = cellfun(@isnumeric,NeoData);
containsNumbers = sum(containsNumbers);
idx = containsNumbers > size(NeoData,1)/2;

if(askRows)
    dlg = dialog('Name', 'Select rows');
    
    outerpos = get(dlg,'Position');
    set(dlg,'Position',[0,0,250+(floor(length(Variables)/25*140)),750]);
    btnGroup = uibuttongroup(dlg , 'visible','on','Position',[0 0 .01 .01]);
    
    uicontrol(btnGroup,'Style','text',...
        'String', 'Please select Variables: First selection(Radio button)= Variable with name; Second selection = Variables should be useable for correlation/group comparison (auto deselected variabels with not numerical contents.) ', ...
        'Position',[10  690 200+(floor(length(Variables)/25*140)) 40]);
    
    y = 690;
    x = 30;
    for i=1:length(Variables)
        y = y - 20;
        radio(i) =uicontrol(btnGroup,'Style','radiobutton',...
            'String', [], ...
            'Value',0,'Position',[x  y 130 20]);
        
        check(i) = uicontrol(dlg,'Style','checkbox',...
            'String',Variables{i},...
            'Value',idx(i),'Position',[x+20  y 130 20]);
        
        useVar = get(check,'Value');
        
        setappdata(dlg,'CheckBox',check);
        setappdata(hObject,'Dialog',dlg);
        setappdata(dlg,'RadioButton',radio);
        
        if(y == 50)
            x = x + 170;
            y = 690;
        end
    end
    uicontrol(dlg,'Style','pushbutton',...
        'String','Ok',...
        'Position',[x+20  10 130 20],...
        'Callback',{@VarSelectDlg_closefcn,hObject, eventdata, handles,NeoData_Atlas}...
        );
    set(dlg,'CloseRequestFcn',{@VarSelectDlg_closefcn,hObject, eventdata, handles,NeoData_Atlas})
    GraphVar_saveSettings(handles);
    Variables=[];vpNamesNeo=[];
else
    load([workspacePath filesep 'ImportSettings.mat']);
    Variables = Variables(logical(useVar));
    vpNamesNeo = NeoData(:,userVar);
    clear NeoData;
   set(handles.list_var_svm,'String',Variables,'Value',1);
   set(handles.list_variables,'String',Variables,'Value',1);

end
GraphVar_settingsChanged(handles);

function VarSelectDlg_closefcn(hObjectB, eventdata1,hObject, eventdata, handles,NeoData_Atlas)
global workspacePath;
if ishandle(hObject)
    dlg = getappdata(hObject,'Dialog');
    check = getappdata(dlg,'CheckBox');
    radio = getappdata(dlg,'RadioButton');
    useVar = cell2mat(get(check,'Value'));
    radio = get(radio,'Value');
    delete(dlg);
    userVar = find(cell2mat(radio) == 1);
    save([workspacePath filesep 'ImportSettings.mat'],'userVar','useVar');
    [handles.Variables handles.vpNamesNeo] = GraphVar_loadVariables(hObject, eventdata, handles,0,NeoData_Atlas);
    guidata(hObject, handles);
else 
    delete(gcf);
end

