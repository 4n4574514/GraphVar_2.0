function CE = CheckFrag(W)
    W(W~=0) = 1;
    [~,S] = get_components(W);
    A = numel(S);
    if A > 1
        CE = 1;
    else
        CE = 0;
    end
    