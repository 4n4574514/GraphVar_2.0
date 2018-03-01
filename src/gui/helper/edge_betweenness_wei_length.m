function D = edge_betweenness_wei_length(W)
    E=find(W); W(E)=1./W(E);        %invert weights
    D = edge_betweenness_wei(W);
