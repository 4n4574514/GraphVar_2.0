function [GWpos,GWneg] = gateway_coef_sign_pos_strength(W)
    Ci = modularity_louvain_und(W);
    [GWpos,GWneg] = gateway_coef_sign(W, Ci, 1);