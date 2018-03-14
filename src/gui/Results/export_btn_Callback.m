function export_btn_Callback(hObject, eventdata, handles)
%% Export data inside Resuls viewer 

doML = strncmp(handles.Files{1}, 'ML', 2);  

 if doML 
 %% ML case 
    % handle inside ml plotviewer script
    ML_ResultsPlots(hObject,handles) 
 elseif  ~doML 
 
 %% GLM case 
    
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
end