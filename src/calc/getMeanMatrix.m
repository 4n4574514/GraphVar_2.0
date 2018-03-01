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

function Result  = getMeanMatrix(filesRand,fieldName,brainD,filePos,rand,InterimResult,doZtransform)
global NeoData_Atlas;

global workspacePath;

load(fullfile(workspacePath,'Workspace.mat'));
[brainSheet variableSheet] =  abs_rel_correct(brainSheet,variableSheet);


result_path = [workspacePath filesep 'results' filesep InterimResult];

NeoData = importSpreadsheet(variableSheet);


nSub = length(filesRand);


if(exist([workspacePath filesep 'ImportSettings.mat'],'file'))
    load([workspacePath filesep 'ImportSettings.mat']);
else
    userVar = 2;
end

ID = NeoData(2:end,userVar);
    
hasNumericalID = 0;
if isscalar(ID{1})
    ID = cell2mat(ID(:));
    hasNumericalID = 1;
end
clear NeoData;

if iscell(fieldName)
    fieldName = fieldName{:};
end

FileCont = load (filesRand{1});
names = fieldnames(FileCont);

idx = find(strcmp(names,'is_dyn'), 1);
if ~isempty(idx) && isscalar(FileCont.is_dyn) && FileCont.is_dyn == 1;
    is_dyn = 1;
else
    is_dyn = 0;
end

if is_dyn
    n_dyn = size(FileCont.(fieldName),2);
else
    n_dyn = 1;
end

brainD = logical(brainD);

% Assume all matrices have the same size
if is_dyn
matrix_size = size(FileCont.(fieldName){1}(brainD, brainD));
else
matrix_size = size(FileCont.(fieldName)(brainD, brainD));
end

Result={};
meanMatrix = zeros(nSub, n_dyn, matrix_size(1), matrix_size(2));
for i_sub=1:nSub
    FileCont = load (filesRand{i_sub});
    if(~isfield(FileCont,fieldName))
            errordlg(['The field "' fieldName '" has not been found ' ]);
            error(['The field "' fieldName '" has not been found: ' ])
    end

    [~, filesRandName, filesRandExt] = fileparts(filesRand{i_sub});
    filesRandName = [filesRandName filesRandExt];
    subjectRandName = filesRandName(filePos(1):end - filePos(2));
    if(rand == 0)
        if hasNumericalID
            [~, loc1] = ismember(str2double(subjectRandName),ID); % Check if Subject is in Excel
        else
            [~, loc1] = ismember(subjectRandName,ID); % Check if Subject is in Excel
        end
    else 
        if hasNumericalID
            [~, loc1] = ismember(str2double(filesRandName(length('\Shuffel_'):end-length('_000001.mat'))),ID); % Check if Subject is in Excel
        else
            [~, loc1] = ismember(filesRandName(length('\Shuffel_'):end-length('_000001.mat')),ID); % Check if Subject is in Excel
        end
    end
    if ~loc1
        continue;
    end
    
    for i_dyn = 1:n_dyn
        
        if(is_dyn)
            meanMatrix(i_sub,i_dyn,:,:) = FileCont.(fieldName){i_dyn}(brainD, brainD);
        else
            meanMatrix(i_sub,i_dyn,:,:) = FileCont.(fieldName)(brainD, brainD);
        end

        if doZtransform
           meanMatrix(i_sub,i_dyn,:,:) = 0.5 * log((1 + meanMatrix(i_sub,i_dyn,:,:)) ./ (1 - meanMatrix(i_sub,i_dyn,:,:)));
        end 
    end
end

% Mean matrix over all subjects and sliding windows!! 

if is_dyn
    dynamicMeanMatrix = squeeze(mean(meanMatrix));
    meanMatrix = squeeze(mean(dynamicMeanMatrix)); 
    
    meanMatrix(~isfinite(meanMatrix)) = 1;
    dynamicMeanMatrixOut = num2cell(dynamicMeanMatrix,[2,3]);
    dynamicMeanMatrixOut = cellfun(@squeeze,dynamicMeanMatrixOut,'UniformOutput',0);
    if(rand == 0)
        save([result_path filesep 'MeanMatrix.mat'],'meanMatrix', 'dynamicMeanMatrix','dynamicMeanMatrixOut');
    else
        save([result_path filesep 'MeanMatrix_rand_' num2str(rand) '.mat'],'meanMatrix', 'dynamicMeanMatrix','dynamicMeanMatrixOut');
    end
else
    meanMatrix = squeeze(mean(meanMatrix));

    meanMatrix(~isfinite(meanMatrix)) = 1;
    if(rand == 0)
        save([result_path filesep 'MeanMatrix.mat'],'meanMatrix');
    else
        save([result_path filesep 'MeanMatrix_rand_' num2str(rand) '.mat'],'meanMatrix');
    end
end

