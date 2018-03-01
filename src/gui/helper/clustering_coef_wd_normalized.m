function D = clustering_coef_wd_normalized(W)
    W=W./max(abs(W(:)));    %scale by maximal weight
    D = clustering_coef_wd(W);
