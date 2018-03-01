function CE = cost_efficiency_absolute_bin(W)
    D = efficiency_bin(W);
    C = density_und(W);
    CE = (D-C);