function D = rich_club_bd2(W)
    D = rich_club_bd(W);
    if  size(D,2) ~= size(W,1)
        D(1,size(W,1)) = NaN ; 
    end
end