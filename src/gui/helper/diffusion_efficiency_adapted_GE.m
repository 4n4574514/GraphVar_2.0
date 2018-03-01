function GEdiff = diffusion_efficiency_adapted_GE(W)
% DIFFUSION_EFFICIENCY      Global mean and pair-wise diffusion efficiency
%   Adapted from BCT diffusion_efficiency.m to work with isolated nodes, too; 

    orig_size = length(W);
    not_connected = find(sum(W,2) == 0);
    W(not_connected, :) = [];
    W(:, not_connected) = [];
    mfpt = mean_first_passage_time(W);
    n = size(mfpt,1);
    Ediff = 1./mfpt;
    Ediff(eye(n)>0) = 0;
    GEdiff = sum(Ediff(~eye(n)>0))/(n^2-n);

end