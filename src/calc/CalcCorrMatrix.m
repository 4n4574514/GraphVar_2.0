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

function Result  = CalcCorrMatrix(files_toRearrange, ...
    fieldName, brainD, saveBool, filePos, PValFieldName, ...
    ConnectivityThr_bool, ConnectivityThr, randN, ...
    InterimResult,weightAdjust_Raw,r2z,dynamicGraphVar, outputName)
global workspacePath;


nan_method = 'mean';



load(fullfile(workspacePath,'Workspace.mat'));
[brainSheet variableSheet] =  abs_rel_correct(brainSheet,variableSheet);
result_path = [workspacePath filesep 'results' filesep InterimResult];
NeoData = importSpreadsheet(variableSheet);

nSub = length(files_toRearrange);

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
if iscell(PValFieldName)
    PValFieldName = PValFieldName{:};
end

FileCont = load (files_toRearrange{1});
names = fieldnames(FileCont);
idx = find(strcmp(names,'is_dyn'), 1);
if ~isempty(idx) && ...
        FileCont.is_dyn == 1
    is_dyn = 1;
else
    is_dyn = 0;
end


if is_dyn && strcmp(dynamicGraphVar,'Select Dynamic')
    button = questdlg('GraphVar detected dynamic input matrices but no dynamic summary measure was selected. Please select a dynamic measure.', 'Dynamic GraphVar','Cancel','Cancel');
    if strcmpi(button, 'Cancel')
        Result = 0;
        return;
    end
end

brainD = logical(brainD);

% Assume all matrices have the same size
if is_dyn
    matrix_size = size(FileCont.(fieldName){1}(brainD, brainD));
else
    matrix_size = size(FileCont.(fieldName)(brainD, brainD));
end

co = 0;
loc = [];
Result_tmp={};
if isempty(ConnectivityThr)
    ConnectivityThr = 1;
end

if(is_dyn && strcmp(nan_method,'mean')) %falls i_dyn
    if(randN == 0)
        load([result_path filesep 'MeanMatrix.mat'],'dynamicMeanMatrix'); %load MeanMatrix for all sub per i_dyn
    else
        load([result_path filesep 'MeanMatrix_rand_' num2str(randN) '.mat'],'dynamicMeanMatrix'); %load MeanMatrix for i_sub i_dyn
    end
else (strcmp(nan_method,'mean'));
    if(randN == 0)
        load([result_path filesep 'MeanMatrix.mat'],'meanMatrix'); %load regular MeanMatrix
    else
        load([result_path filesep 'MeanMatrix_rand_' num2str(randN) '.mat'],'meanMatrix'); %load regular MeanMatrix
    end
end

for i_sub=1:nSub
    tmp = files_toRearrange{i_sub};
    k = strfind(tmp, filesep);
    
    ID_ = files_toRearrange{i_sub}(k(end)+filePos(1):end-filePos(2));

    if hasNumericalID
        ID_ = str2double(ID_);
    end
    
    [~,loc1] = ismember(ID_, ID);
    if loc1 > 0    
        co = co + 1;
        loc(co) = loc1;    
    else
        continue;
    end
    
    FileCont = load (files_toRearrange{i_sub});
    if(~isfield(FileCont,fieldName))
        errordlg(['The field "' fieldName '" has not been found ' ]);
        error(['The field "' fieldName '" has not been found: ' ])
    end
    
    names = fieldnames(FileCont);
    
    idx = find(strcmp(names,'is_dyn'), 1);
    if ~isempty(idx) && FileCont.is_dyn == 1
        is_dyn = 1;
    else
        is_dyn = 0;
    end
    
    if(is_dyn == 1)
        n_dyn = size(FileCont.(fieldName),2);
    else
        n_dyn = 1;
    end
    
    for i_dyn = 1:n_dyn
        if(is_dyn)
            R = FileCont.(fieldName){i_dyn};
        else
            R = FileCont.(fieldName);
        end
        R = R(brainD, brainD);
        
        if r2z == 1
            if any(abs(R(:)) > 1)
                errordlg(['The connectivity values cannot be Fisher r-to-z transformed, as they are not scaled correctly (-1 < r < 1). ' ]);
                error(['The connectivity values cannot be Fisher r-to-z transformed, as they are not scaled correctly (-1 < r < 1). ' ])
            end
            
            R = 0.5*log((1+R)./(1-R));
            % Eliminate infinite values
            R(isinf(R))=1;
        end
        
        if weightAdjust_Raw == 1
            R = abs(R);
        elseif weightAdjust_Raw == 2
            R(R<0) = 0;
        end
        
        if is_dyn
            subMeanMatrix = dynamicMeanMatrix(i_dyn, :, :);
        else
            subMeanMatrix = meanMatrix(:, :);
        end
        
        
        if(ConnectivityThr_bool)
            if(~isfield(FileCont,PValFieldName))
                errordlg(['The field "' PValFieldName '" has not been found ' ]);
                error(['The field "' PValFieldName '" has not been found: ' ])
            end
            
            if(is_dyn)
                P = FileCont.(PValFieldName){i_dyn};
            else
                P = FileCont.(PValFieldName);
            end
            P = P(brainD, brainD);
            
            for i_thr=1:length(ConnectivityThr)
                subR = R;
                if(isscalar(ConnectivityThr))
                    thisThr = ConnectivityThr;
                else
                    thisThr = ConnectivityThr(i_thr);
                end
                if strcmp(nan_method,'mean')
                    subR(P <= thisThr) = subMeanMatrix(P <= thisThr) ;
                elseif (strcmp(nan_method,'nan'))
                    subR(P <= thisThr) = NaN;
                elseif (strcmp(nan_method,'zero'))
                    subR(P <= thisThr) = 0;
                end
                if isempty(find(((round(triu(R)*1000000)/1000000) == (round(tril(R)'*1000000)/1000000) ) == 0))
                    isHalf = 1;
                    if is_dyn
                        Result_tmp{i_thr}{co}{i_dyn} = subR(~triu(ones(size(subR)))); % Only lower diagonal
                    else
                        Result_tmp{i_thr}{co} = rot90(subR(~triu(ones(size(subR)))));
                    end
                else
                    isHalf = 0;
                    if is_dyn
                        Result_tmp{i_thr}{co}{i_dyn} = subR(:); % Only lower diagonal
                    else
                        Result_tmp{i_thr}{co} = rot90(subR(:));
                    end
                end
            end
        else
            if isempty(find(((round(triu(R)*1000000)/1000000) == (round(tril(R)'*1000000)/1000000) ) == 0))
                isHalf = 1;
                if is_dyn && strcmp(dynamicGraphVar,'Brain-Network Variability')
                    Result_tmp{1}{co}{i_dyn} = R(:,:);
                elseif is_dyn
                    Result_tmp{1}{co}{i_dyn} = R(~triu(ones(size(R)))); % Only lower diagonal
                else
                    Result_tmp{1}{co} = rot90(R(~triu(ones(size(R)))));
                end
            else
                isHalf = 0;
                if is_dyn
                    Result_tmp{1}{co}{i_dyn} = R(:); % Only lower diagonal
                else
                    Result_tmp{1}{co} = rot90(R(:));
                end
            end
        end
    end
end

% VARIANCE OR OTHER MEASURES TO CONCATINATE INFO OF DYN

if(is_dyn)
    n_thr = 1;
    if ConnectivityThr_bool
        n_thr = length(ConnectivityThr);
    end
    
    for i_thr = 1:n_thr
        for i_co = 1:length(Result_tmp{i_thr})
            for i_check = 1:size(Result_tmp{i_thr}{i_co},2)
                if sum(isnan(Result_tmp{i_thr}{i_co}{i_check}))
                    errordlg(['Data contains NaN. Please check your data. NaN found in ' files{i_co}]);
                    error(['Data contains NaN. Please check your data. NaN found in ' files{i_co}]);
                end
            end
            % Variability requires different format
            if strcmp(dynamicGraphVar,'Brain-Network Variability')
                 Result_tmp{i_thr}{i_co} = variability(Result_tmp{i_thr}{i_co}, 2, n_dyn);
            end
            Result_tmp{i_thr}{i_co} = cell2mat(Result_tmp{i_thr}{i_co});
            if strcmp(dynamicGraphVar,'Variance over time')
                Result_tmp{i_thr}{i_co} = rot90(var(Result_tmp{i_thr}{i_co}, [], 2));
            elseif strcmp(dynamicGraphVar,'Standard Deviation')
                Result_tmp{i_thr}{i_co} = rot90(std(Result_tmp{i_thr}{i_co}, [], 2));
            elseif strcmp(dynamicGraphVar,'Periodicity')
                Result_tmp{i_thr}{i_co} = rot90(multidimfunc('periodicity',Result_tmp{i_thr}{i_co}, 2));
            elseif strcmp(dynamicGraphVar,'PointProcess: rate')
                Result_tmp{i_thr}{i_co} = rot90(multidimfunc('point_process_rate',Result_tmp{i_thr}{i_co}, 2));
            elseif strcmp(dynamicGraphVar,'PointProcess: interval')
                Result_tmp{i_thr}{i_co} = rot90(multidimfunc('point_process_interval',Result_tmp{i_thr}{i_co}, 2));
            end
            
        end
    end
end

if(saveBool)
    save([result_path filesep 'Settings.mat'],'loc')
    
    for i_thr=1:length(ConnectivityThr)
        Result = Result_tmp{i_thr};
        
        if is_dyn
            load([result_path filesep 'MeanMatrix.mat'],'meanMatrix');
            meanMatrix = zeros(size(meanMatrix));
            if isHalf
                meanMatrix(~triu(ones(size(meanMatrix)))) = mean(cell2mat(Result'));
                meanMatrix = (meanMatrix + meanMatrix') / 2;
            else
                meanMatrix(:,:) = reshape(mean(cell2mat(Result')),size(meanMatrix))';
            end
            
            if(randN == 0)
                save([result_path filesep 'DynamicSummaryMeanMatrix_' num2str(ConnectivityThr(i_thr)) '.mat'],'meanMatrix');
            else
                save([result_path filesep 'DynamicSummaryMeanMatrix_' num2str(ConnectivityThr(i_thr)) '_rand_' num2str(randN) '.mat'],'meanMatrix');
            end
        end
        
        if(randN == 0)
            save([result_path filesep 'GraphVars' filesep outputName '_' num2str(ConnectivityThr(i_thr)) '.mat'],'Result');
        else 
            save([result_path filesep 'GraphVars' filesep outputName '_' num2str(ConnectivityThr(i_thr)) '_rand_' num2str(randN) '.mat'],'Result');
        end
    end
    save([result_path filesep 'GraphVars' filesep 'MatrixSize-Network.mat'],'matrix_size','isHalf');
end


