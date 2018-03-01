function D = diversity_coef_sign_NEG(W)
    D = modularity_und(W);
[~,D] = diversity_coef_sign(W,D);
