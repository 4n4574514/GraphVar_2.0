function S = smallworldness_wu(W,RW)
   cm = zeros(length(RW),1);
cp = zeros(length(RW),1);

for i=1:length(RW)
    cm(i) =  clusterMean_wu(RW{i});
    cp(i) =  charpath_W(RW{i});
end
S = (clusterMean_wu(W)/mean(cm))/(charpath_W(W)/mean(cp));
end