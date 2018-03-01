function D = charpath_B_ecc(W)
    D = distance_bin(W);
[~,~,D] = charpath(D);
