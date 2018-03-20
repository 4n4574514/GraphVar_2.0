
function [STAT] = shape_ml(handles,STAT, isHalf)
%% Reshape Corr Matrix (Feature Weights)
% Transforms weights or p-value scores to corr matrix size
% handles: 
% STAT: feature weights or p values
% isHalf: logical to determine if matrix symmetric 

    if isHalf == 1
        %transform to fit brainstring x brainstring
        STAT_ = zeros(length(handles.BrainStrings), length(handles.BrainStrings));
        P_ = zeros(length(handles.BrainStrings), length(handles.BrainStrings));
        STAT_(~triu(ones(size(P_, 1)))) =  STAT(:, 1);    %fill in values
        STAT = STAT_ + STAT_' ;
    else
        STAT = reshape (STAT, [], length(handles.BrainStrings)); %keep non full corr matrix
    end
end