function [INTVALUES, NLEVELS, STRLEVELS] = graphvar_factor(C)
    if ischar(C{1})
        [STRLEVELS, ~, INTVALUES] = unique(C);
    else
        VALUES  = cat(1, C{:});
        [LEVELS, ~, INTVALUES] = unique(VALUES, 'rows');
        STRLEVELS = arrayfun(@num2str, LEVELS, 'UniformOutput', false);
    end
    NLEVELS = numel(STRLEVELS);
end