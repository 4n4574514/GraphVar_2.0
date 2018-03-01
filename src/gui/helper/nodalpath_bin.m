function D = nodalpath_bin(W)
D = distance_bin(W);
D(D==Inf) = 0; 
D = mean(D);
