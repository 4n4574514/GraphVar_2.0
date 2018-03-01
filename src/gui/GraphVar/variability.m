function Results = variability(Result_tmp,dim,n_dyn)
% Amount of Regions
[~,regions]=size(Result_tmp{1,1});
  
RZRes=zeros(1,regions);
Result_tmp = reshape(cell2mat(Result_tmp),264,264,n_dyn);
I = triu(true(n_dyn,n_dyn),1);

for w = 1:regions % Walk through regions
    MAT = squeeze(Result_tmp(:,w,:));
    MAT = bsxfun(@minus, MAT, mean(MAT));
    STD = std(MAT);
    STD(STD == 0) = 1;
    MAT = bsxfun(@rdivide, MAT, STD);
    Corr = cov(MAT);
    
    Corr=0.5*log((1+Corr)./(1-Corr)); 
    RZRes(w) = mean(Corr(I));
end 
% R-Z Inverse Transformation
CorrRes=(exp(2*RZRes)-1)./(exp(2*RZRes)+1);
Results=num2cell(CorrRes');



