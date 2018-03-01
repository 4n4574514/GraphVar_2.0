function mfpt = mean_first_passage_time2(W)
    orig_size = length(W);
    not_connected = find(sum(W,2) == 0);
    W(not_connected, :) = [];
    W(:, not_connected) = [];
    mfpt = mean_first_passage_time(W);
    start = 1;
    for bound = not_connected'
        stop = length(mfpt);
        mfpt = vertcat(mfpt(1:bound-1,:), NaN(1, stop), mfpt(bound:stop,:));
        mfpt = horzcat(mfpt(:,1:bound-1), NaN(stop+1, 1), mfpt(:,bound:stop));
    end
end

       