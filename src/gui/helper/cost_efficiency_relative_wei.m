function CE = cost_efficiency_relative_wei(W,threshold)
    D = efficiency_wei(W);
    CE = (D-threshold);
    