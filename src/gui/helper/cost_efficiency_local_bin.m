function CE = cost_efficiency_local_bin(W)
    D = efficiency_local_bin(W);
    C = rot90(fliplr(degrees_und(W)));
    CE = (D-C);