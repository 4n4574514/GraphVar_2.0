%% Reshape Corr Matrix (Feature Weights)
function [STAT] = shape_ml(handles,STAT, isHalf)
% Transforms Weights or P-value scores to corr matrix size
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