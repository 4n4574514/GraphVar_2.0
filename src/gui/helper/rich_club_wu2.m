function   [Rw] = rich_club_wu2(W)
    NodeDegree = sum((W~=0)); 
    klevel = max(NodeDegree);
    R = rich_club_wu(W,klevel);
    if  size(R,2) ~= size(W,1)
        fill = NaN(1,(size(W,1)-size(R,2)))
        Rw = [R, fill]
    end