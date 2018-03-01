function D = module_degree_zscore2(W)
    D = modularity_und(W);
    D = module_degree_zscore(W,D);
