function   [Rw] = rich_club_wd2(W)
    NodeDegree = sum((W~=0))+sum((W'~=0)); %define degree of each node (indegree + outdegree)
    klevel = max(NodeDegree);
    R = rich_club_wd(W,klevel);
    if  size(R,2) ~= size(W,1)
        fill = NaN(1,(size(W,1)-size(R,2)))
        Rw = [R, fill]
    end