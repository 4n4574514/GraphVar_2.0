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

classdef folder < handle 
       properties
           name;
           contents;
           showInProgress = 1;
           cycles;
           timePerCycle;
           actCycle = 0;        
           isActive;
           path;
           timerID;
           root;
       end

       methods
           function obj = folder(varargin)
               
           if(nargin == 4)
                obj.name = varargin{1};
                obj.showInProgress = varargin{2};
                obj.cycles = varargin{3};
                obj.contents = varargin{4};
           elseif(nargin == 3)
            	obj.name = varargin{1};
                obj.showInProgress = varargin{2}; 
                obj.cycles = varargin{3};
           end
           end
           function t = getTime(obj)
               t = 0;
               if isempty(obj.contents)
                        t = (obj.cycles - obj.actCycle - 1) * obj.timePerCycle;
               else
                   for i = 1:length(obj.contents) 
                        t = t + obj.contents{i}.getTime();
                   end
               end
           end
           function setBusy(obj)
           	 multiWaitbar(obj.name,'Busy');
           end
           function newCycle(obj,addText)
               
               global running; 
               if ~running
                    return 
               end
               
               %time = toc(obj.timerID);
               %obj.timePerCycle = mean([obj.timePerCycle,obj.timePerCycle,time]);                   
               obj.actCycle = obj.actCycle + 1;
               if obj.showInProgress
                   if nargin < 2
                    multiWaitbar({obj.name length(obj.path) },'Value', 1/(obj.cycles) *  obj.actCycle);
                   else
                    multiWaitbar({obj.name length(obj.path) addText},'Value', 1/(obj.cycles) *  obj.actCycle);
                   end
               end
               if ~isempty(obj.root) && isempty(obj.contents) 
                obj.root.newCycle([' ' num2str(obj.root.actCycle) ' of ' num2str(obj.root.cycles) ' Operations' ] );
               end
               %obj.timerID = tic();
           end
           
           function start(obj)
               
               if obj.showInProgress
                if isempty(obj.root)  
                    multiWaitbar({obj.name length(obj.path)},'Busy', 'Color', [0.8 0.0 0.1]);
                else
                    multiWaitbar({obj.name length(obj.path)},'Busy', 'Color', [0.9 0.7 0.7]);
                end
               end
               obj.timerID = tic();
               obj.isActive = 1;  
               obj.actCycle = 0;        
           end
           
           function actF = getTask(obj,name)
            pathID = obj.ClassNames('get',name);
            pathID = pathID{1};
            actF = obj;
            for i = 1:length(pathID) 
                actF = actF.contents{pathID(i)};
            end
            
           end
           
           function obj = init(obj,varargin) 
               closeAll = 1; 
               if nargin > 1 
                   closeAll = varargin{1}; 
               end
               
               if nargin > 2 
                   obj.root = varargin{2}; 
                   root = varargin{2}; 
               else 
                   root = obj;
               end
               
               if isempty(obj.path)
                    folder.ClassNames('clear');
               end
               
               folder.ClassNames('set',obj.name,obj.path);

               for i=1:length(obj.contents)
                    obj.contents{i}.path = [obj.path i];
                    obj.contents{i} = obj.contents{i}.init(0,root);
               end
               if(closeAll)
                    multiWaitbar( 'CloseAll' );
               end
           end
       end
       
       methods (Static)
         function out=ClassNames(opt,name,path)
             persistent names;
             persistent paths;
             if strcmp(opt,'set')    
                 names=[names {name}]; paths = [paths {path}]; 
             elseif strcmp(opt,'get')
                [~,idx] = ismember(name,names);     
                out=paths(idx);
             elseif strcmp(opt,'clear')
                names = [];
                paths = [];
             end
         end
                  
       end
       
       
   end