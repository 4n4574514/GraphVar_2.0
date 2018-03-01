function CE = cost_efficiency_absolute_wei(W)
    D = efficiency_wei(W);
    C = density_und(W);
    CE = (D-C);