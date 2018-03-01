function S = smallworldness_bu(W,RW)
cm = zeros(length(RW),1);
cp = zeros(length(RW),1);

for i=1:length(RW)
    cm(i) =  clusterMean_bu(RW{i});
    cp(i) =  charpath_B(RW{i});
end
S = (clusterMean_bu(W)/mean(cm))/(charpath_B(W)/mean(cp));
end