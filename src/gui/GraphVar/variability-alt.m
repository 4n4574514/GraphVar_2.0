function Results = variability(Result_tmp,dim,n_dyn)
% Amount of sliding Windows per person
[y,windows]=size(Result_tmp);
% Amount of Regions
[z,regions]=size(Result_tmp{1,1});

% Calculate mutations
connections=(windows-1)*windows/2;
    
A=zeros(regions,1);
for y=1:windows % Switch between time slots withtin each person
    for w = 1:regions % Walk through regions
        for z = (y+1):windows % Concatenate with following time points
            Corr=corrcoef(Result_tmp{1,y}(:,w),Result_tmp{1,z}(:,w));
            % R-Z-Transformation
            Corr=0.5*log((1+Corr)./(1-Corr)); 
            A(w,1)= A(w,1)+Corr(1,2);
        end
    end
end 

RZRes=A/connections;
% R-Z Inverse Transformation
CorrRes=(exp(2*RZRes)-1)./(exp(2*RZRes)+1);

Results=num2cell(CorrRes);

