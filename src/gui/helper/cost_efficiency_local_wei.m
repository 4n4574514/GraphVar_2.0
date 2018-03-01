function CE = cost_efficiency_local_wei(W)
    D = efficiency_local_wei(W);
    C = rot90(fliplr(degrees_und(W)));
    CE = (D-C);