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

function [res,n_dyn] = GraphVar_CheckFrag(thresholds,thresholdType, brain,files,varargin)
global running;
global workspacePath;
load(fullfile(workspacePath,'Workspace.mat'));
[brainSheet variableSheet] =  abs_rel_correct(brainSheet,variableSheet);
[MatrixName, filePos, allTasks, doRandom, nRandom, randomFunction, randomIterations, smallworldness, ...
    randomForType, pValueField, doShuffelRandom, nShuffelRandom,normalize,random_shuffle_calc,randomRawIter,noCorr,InterimResult, weightAdjust_Thr,DynamicGraphVar] = ...
    getArgs(varargin,{'MatrixName','P'},'FilePos','TaskPlaner',{'DoRandom',0},'nRandom','RandomFunction','RandomIterations','Smallworldness','randomForType',{'pValueField','PValMatrix'},{'DoShuffelRandom',0},{'NShuffelRandom',0},{'Normalize',0},{'RandomRaw',''},{'RandomRawIter',0},{'NoCorr',0},{'InterimResult','default'},{'weightAdjust_Thr',0},{'DynamicGraphVar',''});

result_path = [workspacePath filesep 'results' filesep 'FragCheck'];

continueWithNeg = 0;

%[BrainMap] = xlsread(brainSheet);
%BrainMap(:,1) = brain;

if(exist([workspacePath filesep 'ImportSettings.mat'],'file'))
    load([workspacePath filesep 'ImportSettings.mat']);
else
    userVar = 2;
end

if(noCorr ~=1)
    [NeoData] = importSpreadsheet(variableSheet);
    ID = NeoData(:,userVar);
    clear NeoData;
end
loc = [];

shuffelFiles = [];

if iscell(pValueField)
    pValueField = pValueField{:};
end

nSub = length(files);
if(iscell(MatrixName))
    MatrixName  = MatrixName{:};
end


%% ************************************************************************************
%% PART 2:
%% Do The Thresholding / Binarizer

disp(repmat('#', 2, 60))
            disp([repmat('#', 1, 24) '  FRAGMENTATION  ' repmat('#', 1, 20)])
            disp([repmat('#', 1, 24) '  CHECK  ' repmat('#', 1, 25)])
            disp([repmat('#', 1, 24) '  PROGRESS  ' repmat('#', 1, 23)])
            disp(repmat('#', 2, 60))
            disp('Press Ctrl-C to cancel. ')
            disp(repmat('#', 2, 60))
            disp(repmat('#', 2, 60))

for threshold = thresholds
    
    for i_sub=1:nSub
                
        % ****************************
        % Load Subject, delete not requested BrainAreas
        % ****************************
        FileCont = load (files{i_sub});
        if(~isfield(FileCont,MatrixName))
            error(['The field "' MatrixName '" has not been found: ' ]);
        end
        
        if isfield(FileCont,'is_dyn')
            is_dyn = FileCont.is_dyn;
        else
            is_dyn = 0;
        end
        
        if(is_dyn == 1)
            n_dyn = size(FileCont.(MatrixName),2);
        else
            n_dyn = 1;
        end
        
        for i_dyn = 1:n_dyn
            
            if(iscell(MatrixName))
                MatrixName = MatrixName{:};
            end
            
            if(is_dyn)
                R = FileCont.(MatrixName){i_dyn};
            else
                R = FileCont.(MatrixName);
            end
            
            del = find(brain==0);
            R(del,:) = [];
            R(:,del) = [];
            
            
            % ****************************
            % Do the Threshholding
            % ****************************
            
            if is_dyn
                disp(['FragCheck of Threshold ' num2str(threshold) ' for subject ' num2str(i_sub) ' for Window ' num2str(i_dyn) ' of ' num2str(n_dyn)])
            else
                disp(['FragCheck of Threshold ' num2str(threshold) ' for subject ' num2str(i_sub)])
            end
            
            
            if(thresholdType == 1 )
                W = threshold_proportional(R,threshold);
            elseif(thresholdType == 2)
                W = threshold_absolute(R,threshold);
            elseif(thresholdType == 3)
                if ~isfield(FileCont,pValueField)
                    errordlg('The PValue Matrix could not be found');
                    res = 0;
                    return;
                end
                FileCont.(pValueField)(del,:) = []; %% Delete Brain areas
                FileCont.(pValueField)(:,del) = [];
                W = R;
                W(logical(FileCont.(pValueField)>threshold)) = 0;
                n=size(W,1);                                %number of nodes
                W(1:n+1:end)=0;                             %clear diagonal
            elseif(thresholdType == 4)
                W = R;
                n=size(W,1);                                %number of nodes
                W(1:n+1:end)=0;                             %clear diagonal
            elseif(thresholdType == 5)
                disp(['SICE thresholding may take a while ... for threshold '  num2str(threshold) ' of subject ' num2str(i_sub) ' for Window ' num2str(i_dyn) ' of ' num2str(n_dyn) ' windows (no dynamic = 1 window) '])
                W = SICEDense(R,threshold);
                
            end
            
            if weightAdjust_Thr == 1
                W = abs(W);
            elseif weightAdjust_Thr == 2
                W(W<0) = 0;
                
            elseif ~isempty(W(W<0)) && continueWithNeg == 0
                button = questdlg(['The density threshold of ' num2str(threshold) ' and subsequent densities contain negative weights. THIS WILL AFFECT THE NETWORK TOPOLOGY! Do you want to continue?'], 'Found negative Values', 'Continue', 'Cancel', 'Continue');
                if strcmpi(button, 'Cancel')
                    res = 0;
                    return;
                else
                    continueWithNeg = 1;
                end
                
            end
            
            VPData{i_sub,i_dyn} = W;
            
            frag_check{i_dyn,i_sub} = CheckFrag((VPData{i_sub,i_dyn}));
            save([result_path filesep 'frag_check_' num2str(threshold*10) '.mat'],'frag_check');
            
            clear W R;
        end % end dyn
    end % END Every Subject
    
end

res = 1;
