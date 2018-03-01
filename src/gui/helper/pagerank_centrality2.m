function D = pagerank_centrality2(W)
    D = pagerank_centrality(W,0.85,0.5);
    
    %d,      damping factor = 0.85
    %falff,      initial page rank probability (non-negative) = 0.5

