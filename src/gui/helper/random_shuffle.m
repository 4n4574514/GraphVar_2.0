function randM = random_shuffel(input,iter)
line = [];

elsSize = size(input);

for k=1:elsSize(1)
    line(end+1:end+elsSize(2)-k) = input(k,k+1:end);
end

line = line(randperm(numel(line)));

randM = zeros(elsSize(1),elsSize(2));
start = 1;
for ii = 1:elsSize(1)
    randM(ii,ii)= 1;
    ende = start + size(randM,2)-ii-1;
    randM(ii,ii+1:end)= line(1,start:ende);
    randM(ii+1:end,ii)= line(1,start:ende);
    start = ende +1;
end

end