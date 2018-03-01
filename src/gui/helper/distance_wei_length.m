function D = distance_wei_length(W)
    E=find(W); W(E)=1./W(E);        %invert weights
    D = distance_wei(W);
    
