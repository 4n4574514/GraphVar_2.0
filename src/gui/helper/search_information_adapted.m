function SI = search_information_adapted(adj)
% SEARCH_INFORMATION                    Search information
% Adapted from BCT search_information.m to work with isolated nodes, too. 

transform = 'inv';
has_memory = true;

orig_size = length(adj);
not_connected = find(sum(adj,2) == 0);
adj(not_connected, :) = [];
adj(:, not_connected) = [];

N = size(adj,1);

if sum(sum( triu(adj,1) + triu(adj,1)' - (adj))) < eps
    flag_triu = true;           % matrix is symmetric (undirected network)
else
    flag_triu = false;          % matrix is not symmetric (directed network)
end

T = diag(sum(adj,2))\adj;
[~,hops,Pmat] = distance_wei_floyd(adj,transform);

SI = zeros(N,N);
SI(eye(N)>0) = nan;

for i = 1:N
    for j = 1:N
        if (j > i && flag_triu) || (~flag_triu && i ~= j)
            path = retrieve_shortest_path(i,j,hops,Pmat);
            lp = length(path);
            if flag_triu
                if ~isempty(path)
                    pr_step_ff = nan(1,lp-1);
                    pr_step_bk = nan(1,lp-1);
                    if has_memory
                        pr_step_ff(1) = T(path(1),path(2));
                        pr_step_bk(lp-1) = T(path(lp),path(lp-1));
                        for z=2:lp-1
                            pr_step_ff(z) = T(path(z),path(z+1))/(1 - T(path(z-1),path(z)));
                            pr_step_bk(lp-z) = T(path(lp-z+1),path(lp-z))/(1 - T(path(lp-z+2),path(lp-z+1)));
                        end
                    else
                        for z=1:length(path)-1
                            pr_step_ff(z) = T(path(z),path(z+1));
                            pr_step_bk(z) = T(path(z+1),path(z));
                        end
                    end
                    prob_sp_ff = prod(pr_step_ff);
                    prob_sp_bk = prod(pr_step_bk);
                    SI(i,j) = -log2(prob_sp_ff);
                    SI(j,i) = -log2(prob_sp_bk);
                else
                    SI(i,j) = inf;
                    SI(j,i) = inf;
                end
            else
                if ~isempty(path)
                    pr_step_ff = nan(1,lp-1);
                    if has_memory
                        pr_step_ff(1) = T(path(1),path(2));
                        for z=2:lp-1
                            pr_step_ff(z) = T(path(z),path(z+1))/(1 - T(path(z-1),path(z)));
                        end
                    else
                        for z=1:length(path)-1
                            pr_step_ff(z) = T(path(z),path(z+1));
                        end
                    end
                    prob_sp_ff = prod(pr_step_ff);
                    SI(i,j) = -log2(prob_sp_ff);
                else
                    SI(i,j) = inf;
                end
            end
        end
    end
end

start = 1;
for bound = not_connected'
    stop = length(SI);
    SI = vertcat(SI(1:bound-1,:), NaN(1, stop), SI(bound:stop,:));
    SI = horzcat(SI(:,1:bound-1), NaN(stop+1, 1), SI(:,bound:stop));
end
