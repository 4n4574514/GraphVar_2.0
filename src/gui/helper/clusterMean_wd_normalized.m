function D = clusterMean_wd_normalized(W)
    W=W./max(abs(W(:)));    %scale by maximal weight
    D = mean(clustering_coef_wd(W));
