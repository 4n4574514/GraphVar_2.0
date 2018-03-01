function CE = cost_efficiency_relative_bin(W,threshold)
    D = efficiency_bin(W);
    CE = (D-threshold);