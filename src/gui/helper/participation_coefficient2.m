function D = module_degree_zscore2(W)
    D = modularity_und(W);
    D = participation_coef(W,D);
