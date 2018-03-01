function Global_ResizeFcn(hObject, eventdata, handles)
    if isfield(handles,'startSize')
        %% Get the Size Change   
        set(hObject,'Units', 'pixels' )
        [pos] = get(hObject,'Position');
        
        
        change = pos(3:4) - handles.startSize(3:4);
        
        
        % dont let it become too small
        if(pos(3) < 700)
            pos = [pos(1) pos(2) + change(2) [700 525]];
            set(hObject,'Position',pos); 
        end
        
        sizeFacT = [pos(3) / handles.startSize(3) pos(4) / handles.startSize(4)];          
        sizeFac = min(sizeFacT);

        if(sizeFac < 1) 
            sizeFac = max(sizeFacT);
        end
        
        
        
        if(pos(1) ~= handles.startSize(1))
                    set(hObject,'Position',[pos(1) + change(1)  pos(2) handles.startSize(3:4)*sizeFac]);
        else
                    set(hObject,'Position',[pos(1) pos(2) handles.startSize(3:4)*sizeFac]);
        end
        
        handles.startSize(3:4) = handles.startSize(3:4) * sizeFac; %handles.startSize(3:4)*sizeFac;

        s = fieldnames(handles);
        for ii=2:length(s)
        if (isscalar(handles.(s{ii}))) && (ishandle(handles.(s{ii}))) && (isprop(handles.(s{ii}),'Position'))
            if handles.(s{ii}) == hObject
                continue
            end
            tmp = get(handles.(s{ii}),'Position');

            tmp = tmp * sizeFac;

            set(handles.(s{ii}),'Position',tmp);
        end
        end
    end
guidata(hObject, handles);
