
function [STAT, SLAB] = shape_plot(STAT, SLAB)
%% Reshape Feature Weights Values and Labels
% reshapes weights values and feature labels for plot display
% STAT: weight or p value 
% SLAB: label of user selected features


A = length(STAT);
A = length (SLAB);
 if A >=  10          
        if A >=  10     
            DW = 10;
        end

        if  A >= 500
        DW = 100;
        end

        C = mod(A, DW);
        R =  A - C;
        T = R/DW;
        STAT1 = STAT(1:R);
        STAT2 = STAT(R+1:end);   %remainder

        STAT3 = NaN(DW,1);
        STAT3= padcat(STAT2, STAT3);
        STAT3 = STAT3(:,1);
        STAT1 = [STAT1; STAT3];
        STAT = reshape (STAT1, DW, (T+1));


        SLAB2 = (cell((DW - C), 1));
        SLAB2(:) = {'NaN'};
        SLAB1 = [SLAB(1:end); SLAB2(1:end)];
        SLAB = reshape (SLAB1, DW, (T+1));     
 end
end