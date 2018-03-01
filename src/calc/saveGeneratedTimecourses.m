function saveGeneratedTimecourses(file, CorrMatrix,PValMatrix,BMatrix,RandPValMatrix)
    if isempty(RandPValMatrix)
        save(file, 'CorrMatrix', 'PValMatrix', 'BMatrix');
    else
        save(file, 'CorrMatrix', 'PValMatrix', 'BMatrix', 'RandPValMatrix');
    end
end