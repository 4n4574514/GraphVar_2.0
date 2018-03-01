function D = module_degree_zscore2(W)
    D = modularity_dir(W);
    D = participation_coef(W,D);
