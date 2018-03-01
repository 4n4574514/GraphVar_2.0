function Ediff = diffusion_efficiency_adapted_E(W)
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
    
    start = 1;
    for bound = not_connected'
        stop = length(Ediff);
        Ediff = vertcat(Ediff(1:bound-1,:), NaN(1, stop), Ediff(bound:stop,:));
        Ediff = horzcat(Ediff(:,1:bound-1), NaN(stop+1, 1), Ediff(:,bound:stop));
    end
    
    %GEdiff = sum(Ediff(~eye(n)>0))/(n^2-n);

end