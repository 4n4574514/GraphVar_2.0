function D = clusterMean_wu_normalized(W)
    W=W./max(abs(W(:)));    %scale by maximal weight
    D = mean(clustering_coef_wu(W));
