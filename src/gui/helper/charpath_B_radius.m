function D = charpath_B_radius(W)
    D = distance_bin(W);
[~,~,~,D] = charpath(D);
