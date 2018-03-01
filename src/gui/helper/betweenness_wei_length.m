function D = betweenness_wei_length(W)
    E=find(W); W(E)=1./W(E);        %invert weights
    D = betweenness_wei(W);
   
