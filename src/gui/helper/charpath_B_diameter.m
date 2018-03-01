function D = charpath_B_diameter(W)
    D = distance_bin(W);
[~,~,~,~,D] = charpath(D);
