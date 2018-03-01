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

function GraphVar_ThreshType_SelectionChangeFcn(hObject, eventdata, handles, isLoaded)

if isLoaded==0
    GraphVar_settingsChanged(handles)

    if get(handles.Significant_Radio,'Value')
        [selection,ok] = listdlg('PromptString','Select the field where p-Values are stored :','ListString',handles.fNames,'SelectionMode','single');
        if(ok)
            handles.sigField = handles.fNames(selection);
        else
            set(eventdata.OldValue,'Value',1)
        end
    end
end

if get(handles.Rel_radio,'Value')
    set(handles.list_thresholds_var,'Visible','on')
    set(handles.textRel,'Visible','on')
    
    set(handles.list_thresholds_var2,'Visible','off')
    set(handles.textAbs,'Visible','off')
    
    set(handles.list_thresholds_Sig,'Visible','off')
    set(handles.textSig,'Visible','off')
    
    set(handles.threshold_list_SICE,'Visible','off')
    set(handles.textSICE,'Visible','off')
elseif get(handles.Abs_Radio,'Value')
    set(handles.list_thresholds_var,'Visible','off')
    set(handles.textRel,'Visible','off')
    
    set(handles.list_thresholds_var2,'Visible','on')
    set(handles.textAbs,'Visible','on')
    
    set(handles.list_thresholds_Sig,'Visible','off')
    set(handles.textSig,'Visible','off')
    
    set(handles.threshold_list_SICE,'Visible','off')
    set(handles.textSICE,'Visible','off') 
elseif get(handles.Significant_Radio,'Value')

    set(handles.list_thresholds_var,'Visible','off')
    set(handles.textRel,'Visible','off')
    
    set(handles.list_thresholds_var2,'Visible','off')
    set(handles.textAbs,'Visible','off')
    
    set(handles.list_thresholds_Sig,'Visible','on')
    set(handles.textSig,'Visible','on')
    
    set(handles.threshold_list_SICE,'Visible','off')
    set(handles.textSICE,'Visible','off')
elseif get(handles.SICE_Radio,'Value')

    set(handles.list_thresholds_var,'Visible','off')
    set(handles.textRel,'Visible','off')
    
    set(handles.list_thresholds_var2,'Visible','off')
    set(handles.textAbs,'Visible','off')
    
    set(handles.list_thresholds_Sig,'Visible','off')
    set(handles.textSig,'Visible','off')
    
    set(handles.threshold_list_SICE,'Visible','on')
    set(handles.textSICE,'Visible','on')    
    
    warndlg(sprintf(' Estimates binary graphs with predefined densities using sparse inverse covariance estimation (Huang et al., 2010; Learning brain connectivity of Alzheimers disease by sparse inverse covariance estimation). \n \n You should use estimated COVARIANCE matrices (e.g. computed in the "Generate Conn Matrix" panel'))
else
    set(handles.list_thresholds_var,'Visible','off')
    set(handles.textRel,'Visible','off')
    
    set(handles.list_thresholds_var2,'Visible','off')
    set(handles.textAbs,'Visible','off')
    
    set(handles.list_thresholds_Sig,'Visible','off')
    set(handles.textSig,'Visible','off')
    
    set(handles.threshold_list_SICE,'Visible','off')
    set(handles.textSICE,'Visible','off')
    
    warndlg(sprintf(' Please keep several things in mind if no threshold is applied: \n \n 1. Not all graph metrics make sense if your initial matrices are fully connected! \n \n 2. Not all metrics can handle negative weights - thus, you may want to transform those to absolute values or ignore negative weights! \n \n Here are some metrics that may work for you with fully connected matrices: \n \n Weighted: Betweeness centrality \n Weighted: Characteristic path length \n Weighted: Clustering coefficient \n Weighted: Edge betweeness centrality \n Weighted: Eigenvector centrality \n Weighted: Efficiency global \n Weighted: Efficiency local \n Weighted: Modularity \n Weighted: Strength \n Weighted: Participation coefficient \n Weighted: Shannon diversity coefficient \n Weighted: Transitivity \n Weighted: Within-module degree z-score \n '))
end
guidata(hObject, handles);
