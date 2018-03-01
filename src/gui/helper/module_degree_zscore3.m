function D = module_degree_zscore3(W)
    D = modularity_dir(W);
    D = module_degree_zscore(W,D);
