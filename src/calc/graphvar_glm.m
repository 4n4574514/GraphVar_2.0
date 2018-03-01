%  This file is part of GraphVar.
% 
%  Copyright (C) 2016 Lea Waller 
% 
%  GraphVar is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
% 
%  GraphVar is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
% 
%  You should have received a copy of the GNU General Public License
%  along with GraphVar.  If not, see <http://www.gnu.org/licenses/>.

function [PFUN, RFUN, NFUN, ...
                LAB, LLAB, LLEV, LASSIGN, LTYPE, ...
                MMEANS, J, N, DDF] = ...
                    graphvar_glm(XX, NCOV, WID, WCOV, COV, BFAC, INT, LAB)

    %% Paired measures
    
    if ~isempty(WID)
        [VALUES, ~, ~] = graphvar_factor(XX(:, WID));
        [~, WIND1] = unique(VALUES, 'rows', 'first');
        [~, WIND2] = unique(VALUES, 'rows', 'last');
    end

    %% Design

    ASSIGN = 1;
    
    X = ones(size(XX, 1), 1);
    if ~isempty(WID)
        X = X(WIND1, :);
    end
    
    N = size(XX, 1);
    
    FACLEVELS = {[]}; 
    
    LAB = ['Intercept' LAB];
    XLAB = {'Intercept'}; 
    XNOM = {{'Intercept'}}; 
    
    for i = 1:length(COV)
        VALUES = [XX{:, COV(i)}]; 
        
        if ~isempty(WID)
            VALUES = VALUES(WIND1);
        end
        
        X      = [X VALUES(:) - mean(VALUES(:))]; 
        
        XLAB   = [XLAB LAB{i + 1}];
        XNOM   = [XNOM {LAB(i + 1)}];
        
        ASSIGN = [ASSIGN ASSIGN(end) + 1];
        FACLEVELS = [FACLEVELS {[]}];
    end
    
    for i = 1:length(WCOV)
        VALUES = [XX{:, WCOV(i)}]; 
        
        if ~isempty(WID)
            VALUES = VALUES(WIND2) - VALUES(WIND1);
        end
        
        X      = [X VALUES(:) - mean(VALUES(:))]; 
        
        XLAB   = [XLAB LAB{length(COV) + 1 + i}];
        XNOM   = [XNOM {LAB(length(COV) + 1 + i)}];
        
        ASSIGN = [ASSIGN ASSIGN(end) + 1];
        FACLEVELS = [FACLEVELS {[]}];
    end
    
    for i = 1:length(BFAC) % effect coding
        [VALUES, NLEVELS, STRLEVELS] = graphvar_factor(XX(:, BFAC(i)));
        
        if NLEVELS == 1
            errordlg(['Factor ' LAB{length(COV) + length(WCOV) + 1 + i} ' has only one one level' ]);
            error(['Factor ' LAB{length(COV) + length(WCOV) + 1 + i} ' has only one one level' ]);
        end

        I = ASSIGN(end) + 1;
        for LEVEL = 2:NLEVELS
            DUMMY = double(VALUES == LEVEL);
            DUMMY(VALUES == 1) = -1;
            
            % Weighted means
            % DUMMY(DUMMY(:) ~= 0) = DUMMY(DUMMY(:) ~= 0) - ...
            %     mean(DUMMY(DUMMY(:) ~= 0));
            
            if ~isempty(WID)
                DUMMY = DUMMY(WIND1);
            end
            
            X      = [X DUMMY(:)];
            
            LEVEL_ = [LAB{length(COV) + length(WCOV) + 1 + i} '_' STRLEVELS{LEVEL}];
            LEVEL1_ = [LAB{length(COV) + length(WCOV) + 1 + i} '_' STRLEVELS{1}];
            XLAB   = [XLAB [LEVEL_ '-' LEVEL1_]];
            XNOM   = [XNOM {{LEVEL_, LEVEL1_}}];
            
            ASSIGN = [ASSIGN I];
        end
        
        FACLEVELS = [FACLEVELS {strcat(LAB{length(COV) + length(WCOV) + 1 + i}, '_', STRLEVELS)}];
    end
    
    function C = CATCOMB(A, B)
        IN = [2 1];
        IX = {1:numel(A), 1:numel(B)};
        [IX{IN}] = ndgrid(IX{IN});
        
        C = cell(numel(IX{1}), 2); 
        C(:, 1) = reshape(A(IX{1}), [], 1);
        C(:, 2) = reshape(B(IX{2}), [], 1);
        
        C = strcat(C(:, 1), ':', C(:, 2));
    end

    function A = CATREC(A)
        if numel(A) > 1
            for p = 2:log2(numel(A))
                A = reshape(A, 2, [])';
                A = strcat('(', A(:, 1), '-', A(:, 2), ')');
            end
            A = reshape(A, 2, [])';
            A = strcat(A(:, 1), '-', A(:, 2));
        end
    end
    
    INTERACTIONS = [];
    IASSIGN = mat2cell(1:ASSIGN(end), 1, ones(1, ASSIGN(end)));
    for i = 2:INT
        COMB = nchoosek(2:ASSIGN(end), i);
        for j = 1:size(COMB, 1)
            LAB = [LAB strjoin(LAB(COMB(j, :)), '*')];
            IASSIGN = [IASSIGN {COMB(j, :)}];
            
            VALUES = X(:, ASSIGN == COMB(j, 1));
            VNOM = XNOM(ASSIGN == COMB(j, 1));
            for k = 2:i
                VALUESK = X(:, ASSIGN == COMB(j, k));
                PROD    = size(VALUESK, 2) * size(VALUES, 2);
                VALUES  = repmat(VALUES, 1, PROD / size(VALUES, 2)) .* ...
                          repmat(VALUESK, 1, PROD / size(VALUESK, 2));
                KNOM    = XNOM(ASSIGN == COMB(j, k));
                VNOM    = cellfun( ...
                    @CATCOMB, ...
                    repmat(VNOM, 1, PROD / length(VNOM)), ...
                    repmat(KNOM, 1, PROD / length(KNOM)), ...
                    'UniformOutput', false);
            end
            
            X = [X VALUES];
            
            VLAB = VNOM;
            for q = 1:numel(VNOM)
                VLAB{q} = CATREC(VLAB{q});
            end
            
            XLAB = [XLAB VLAB{:}];
            XNOM = [XNOM VNOM];
            
            if any(ismember(COMB(j, :), (1:length(BFAC)) + length(COV) + length(WCOV) + 1))
                FACLEVELS = [FACLEVELS {unique([VNOM{:}])}];
            else
                FACLEVELS = [FACLEVELS {[]}];
            end
            
            II = ASSIGN(end);
            if ~isempty(INTERACTIONS)
                II = max(II, INTERACTIONS(end));
            end
            INTERACTIONS = [INTERACTIONS repmat(II + 1, 1, size(VALUES, 2))];
        end
    end
    
    %% Nuisance variables
    
    NX = ones(size(X, 1), 1); 
    
    for i = 1:length(NCOV)
        if ischar(XX{1, NCOV(i)})
            [VALUES, NLEVELS, ~] = graphvar_factor(XX(:, NCOV(i)));
            
            for LEVEL = 2:NLEVELS
                DUMMY = double(VALUES == LEVEL);
                DUMMY(VALUES == 1) = -1;
                
                if ~isempty(WID)
                    DUMMY = DUMMY(WIND1);
                end
            
                NX = [NX DUMMY(:)];
            end
        else
            VALUES_ = [XX{:, NCOV(i)}];
            
            if ~isempty(WID)
                VALUES_ = VALUES_(WIND1);
            end

            NX = [NX VALUES_(:)];  
        end
    end
    
    %% Adjusted means
    
    function LC = MATCOMB(LL)
        II_ = numel(LL):-1:1;
        [LC{II_}] = ndgrid(LL{II_}) ;
        LC = reshape(cat(numel(LL) + 1, LC{:}), [], numel(LL));
    end
    
    if ~isempty(BFAC)
        LEVELS = {};
        for i = (1:length(BFAC)) + length(COV) + length(WCOV) + 1
            LEVELS = [LEVELS {1:sum(ASSIGN == i)+1}];
        end
        LCOMB = MATCOMB(LEVELS);

        LX = ones(size(LCOMB, 1), 1);
        LX = [LX zeros(size(LCOMB, 1), length(COV) + length(WCOV))];

        for i = 1:size(LCOMB, 2) % effect coding
            for LEVEL = 2:numel(LEVELS{i})
                DUMMY = double(LCOMB(:, i) == LEVEL);
                DUMMY(LCOMB(:, i) == 1) = -1;
                LX = [LX DUMMY(:)];
            end
        end

        for i = 2:INT
            COMB = nchoosek(2:ASSIGN(end), i);
            for j = 1:size(COMB, 1)
                VALUES = LX(:, ASSIGN == COMB(j, 1));
                for k = 2:i
                    VALUESK = LX(:, ASSIGN == COMB(j, k));
                    PROD    = size(VALUESK, 2) * size(VALUES, 2);
                    VALUES  = repmat(VALUES, 1, PROD / size(VALUES, 2)) .* ...
                              repmat(VALUESK, 1, PROD / size(VALUESK, 2));
                end
                LX = [LX VALUES];
            end
        end
    end
    
    %% Hypotheses
    
    ASSIGN = [ASSIGN INTERACTIONS];
    
    L = [];
    J = [];
    LLAB = {};
    LASSIGN = [];
    LLEV = {};
    LTYPE = {};
    MMEANS = []; % 1 - 
    
    NH = max(histc(ASSIGN, unique(ASSIGN)));
    
    function [AA, AI] = TRANSF
        G = IASSIGN;
        for i_ = 1:numel(IASSIGN)
            GC = G{i_}(ismember(G{i_}, IND_COV));
            if length(GC) == length(IND_COV) && ...
                        all(GC == IND_COV)
                if length(G{i_}) == length(IND_COV) && ...
                        all(G{i_} == IND_COV)
                    G{i_} = 1;
                else
                    G_ = G{i_};
                    G{i_} = G_(~ismember(G_, IND_COV));
                end
            else
                G{i_} = [];
            end
        end
        
        AA = zeros(numel(ASSIGN), 1);
        AI = zeros(numel(ASSIGN), 1); 
        for i_ = 1:numel(IASSIGN)
            for j_ = 1:i_-1
                if length(G{i_}) == length(IASSIGN{j_}) && ...
                        all(G{i_} == IASSIGN{j_})
                    AA(ASSIGN == i_) = find(ASSIGN == j_);
                    AI(ASSIGN == j_) = find(ASSIGN == i_);
                end
            end
        end
        AA = AA(AA ~= 0);
        AI = AI(AI ~= 0);
    end
    
    for i = 1:ASSIGN(end)
        IND = find(ASSIGN == i);
        
        % Adjusted means
        
        MML = [];
        MMLLAB = {};
        if any(ismember(IASSIGN{i}, (1:length(BFAC)) + length(COV) + length(WCOV) + 1))
            IND_ = IASSIGN{i};
            IND_COV = IND_(~ismember(IND_, (1:length(BFAC)) + length(COV) + length(WCOV) + 1));
            IND_FAC = IND_(ismember(IND_, (1:length(BFAC)) + length(COV) + length(WCOV) + 1));
            
            LABS = strjoin(LAB(IND_COV), ':');
            if ~isempty(IND_COV)
                LABS = [LABS ':'];
                [AA, AI] = TRANSF();
            end
            LEVELS = FACLEVELS(IND_FAC);
            
            LCOMB_ = unique(LCOMB(:, IND_FAC - length(COV) - length(WCOV) - 1), 'rows');

            for j = 1:size(LCOMB_, 1)
                LIND = all(bsxfun(@eq, LCOMB(:, IND_FAC - length(COV) - length(WCOV) - 1), LCOMB_(j, :)), 2);
                
                LL = zeros(NH, length(ASSIGN));
                LL(1, :) = mean(LX(LIND, :), 1);
                
                if ~isempty(IND_COV)
                    LL(:, AI) = LL(:, AA);
                    LL(:, AA) = 0;
                end

                MML = cat(3, MML, LL);

                MMLLAB_ = [LABS LEVELS{1}{LCOMB_(j, 1)}];
                for k = 2:numel(LEVELS)
                    MMLLAB_ = [MMLLAB_ ':' [LEVELS{k}{LCOMB_(j, k)}]];
                end

                MMLLAB = [MMLLAB {MMLLAB_}];
            end
        end
        
        % Effects
        
        if sum(ASSIGN == i) == 1 && length(IASSIGN{i}) == 1
            LL = zeros(NH, length(ASSIGN));
            
            if ~isempty(FACLEVELS{i}) % better naming for 2-level factors
                LLAB = [LLAB [FACLEVELS{i}{1} '-' ...
                              FACLEVELS{i}{2} '=0']];
                LL(1, IND) = -2;
                
                if any(ismember(IASSIGN{i}, (1:length(COV)+length(WCOV)) + 1))
                    LTYPE = [LTYPE {'d(b)'}];
                else
                    LTYPE = [LTYPE {'d'}];
                end
            else
                LL(1, IND) = 1;
                LLAB = [LLAB [LAB{i} '=0']];
                
                if i == 1
                    LTYPE = [LTYPE {'m'}];
                else
                    LTYPE = [LTYPE {'b'}];
                end
            end
            
            L = cat(3, L, LL);
            J = [J 1];
            LLEV = [LLEV {[]}];
            MMEANS = [MMEANS {''}];
            LASSIGN = [LASSIGN i];
            
            if ~isempty(MML)
                L = cat(3, L, MML);
                
                J = [J ones(1, size(MML, 3))];
                LLAB = [LLAB strcat(MMLLAB, '=0')];
                MMEANS = [MMEANS MMLLAB];
                
                for j = 1:size(MML, 3)
                    LASSIGN = [LASSIGN i];
                    LLEV = [LLEV {[]}];
                    
                    if any(ismember(IASSIGN{i}, (1:length(COV)+length(WCOV)) + 1))
                        LTYPE = [LTYPE {'b'}];
                    else
                        LTYPE = [LTYPE {'m'}];
                    end
                end
            end
        else
            LLEV_ = {};
            
            LL = zeros(NH, length(ASSIGN));
            LL(1:length(IND), IND) = eye(length(IND));
            
            if sum(ASSIGN == i) == 1
                LL = LL * -2;
            end
            
            L = cat(3, L, LL);
            
            J = [J length(IND)];
            LLAB = [LLAB [LAB{i} '=0']];
            if all(ismember(IASSIGN{i}, (1:length(COV)+length(WCOV)) + 1))
                LTYPE = [LTYPE {'b'}];
            else
                LTYPE = [LTYPE {''}];
            end
            MMEANS = [MMEANS {''}];
            LASSIGN = [LASSIGN i];
            LLEV = [LLEV {[]}];
            
            if ~isempty(MML)
                L = cat(3, L, MML);
                
                J = [J ones(1, size(MML, 3))];
                LLAB = [LLAB strcat(MMLLAB, '=0')];
                MMEANS = [MMEANS MMLLAB];
                
                for j = 1:size(MML, 3)
                    LASSIGN = [LASSIGN i];
                    LLEV = [LLEV {[]}];
                    
                    if any(ismember(IASSIGN{i}, (1:length(COV)+length(WCOV)) + 1))
                        LTYPE = [LTYPE {'b'}];
                    else
                        LTYPE = [LTYPE {'m'}];
                    end
                end
                
                
                COMB = nchoosek(1:size(MML, 3), 2);

                for j = 1:size(COMB, 1)
                    ANOM = MMLLAB{COMB(j, 1)};
                    BNOM = MMLLAB{COMB(j, 2)};

                    LL = MML(:, :, COMB(j, 1)) - MML(:, :, COMB(j, 2));
                    L = cat(3, L, LL);
                    J = [J 1];

                    LLEV = [LLEV {ANOM BNOM}];

                    VLAB = CATREC({ANOM BNOM});
                    LLAB = [LLAB [VLAB{:} '=0']];
                    
                    if any(ismember(IASSIGN{i}, (1:length(COV)+length(WCOV)) + 1))
                        LTYPE = [LTYPE {'d(b)'}];
                    else
                        LTYPE = [LTYPE {'d'}];
                    end

                    MMEANS = [MMEANS {''}];
                    LASSIGN = [LASSIGN i];

                end
            end
        end
    end
    
    %%
    
    ISTD = cellfun(@(Q) any(ismember(Q, 2:length(COV)+length(WCOV)+1)), IASSIGN);
    LSTD = ISTD(LASSIGN);
    ISTD_ = find(ISTD);

    STD = std(X, [], 1);
    IASSIGN_ = IASSIGN(ISTD);
    for i = 1:numel(IASSIGN_)
        Q = IASSIGN_{i};
        Q = Q(ismember(Q, 2:length(COV)+length(WCOV)+1));
        for j = 1:i-1
            if length(IASSIGN_{j}) == length(Q) && ...
                    all(IASSIGN_{j} == Q) 
                STD(ISTD_(i)) = STD(ISTD_(j));
            end
        end
    end

    STD(ISTD) = STD(cellfun(@min, IASSIGN(ISTD)));
    STD = STD(LASSIGN(ismember(LASSIGN, find(ISTD))));
    
    %% Fit function
    
    PFUN = @PFIT;
    RFUN = @RFIT;
    NFUN = @NFIT;
    
    XTX = pinv(X' * X);
    LXTXL = tpinv(tdot(tdot(L, XTX), tt(L)));
    DDF = size(X, 1) - size(X, 2);
    
    function Y_ = PRE(Y)
        Y_ = Y;
        
        if ~isempty(WID)
            Y_ = Y_(WIND2, :, :) - Y_(WIND1, :, :);
        end
        
        if ~isempty(NCOV)
            BETAN = tdot(pinv(NX), Y_);
            PREDN = tdot(NX(:, 2:end), BETAN(2:end, :, :));
            Y_ = Y_ - PREDN;
        end
    end
    
    function [PP, F, LB, SE] = PFIT(Y) % Parametric
        Y = PRE(Y);
        
        [B, R] = tlstsq(X, Y);
        B = permute(B, [1 3 4 2]);
        R = permute(R, [1 3 4 2]);
        
        LB = tdot(L, B);
        F = tdot(tdot(tt(LB), LXTXL), LB) ./ ...
            (bsxfun(@times, R, permute(J, [1 3 2])) / DDF);
        F = permute(F, [3 4 1 2]);
        
        SE = sqrt(...
            bsxfun(@times, tdot(tdot(L, XTX), tt(L)), R ./ DDF));
        
        PP = 1 - fcdf(F, ...
            repmat(J', 1, size(F, 2)), ...
            repmat(DDF, size(F))); 

        LB = LB(1, :, :, :);
        if ~isempty(COV) || ~isempty(WCOV)
            LB(:, :, LSTD, :) = bsxfun(@rdivide, ...
                LB(:, :, LSTD, :), ...
                permute(std(Y(:, :, 1), [], 1), [1 3 4 2]));
            
            LB(:, :, LSTD, :) = bsxfun(@times, ...
                LB(:, :, LSTD, :), ...
                permute(STD, [1 3 2]));
        end
        LB = permute(LB, [3 4 1 2]);
        
        SE = SE(1, :, :, :);
        SE = permute(SE, [3 4 1 2]);
    end

    function [PP, NP, F, RF, LB, LRB, SE] = RFIT(Y, NR) % Randomization test
        Y = PRE(Y);
        
        [B, R] = tlstsq(X, Y);
        B = permute(B, [1 3 4 2]);
        R = permute(R, [1 3 4 2]);
        
        LB = tdot(L, B);
        F = tdot(tdot(tt(LB), LXTXL), LB) ./ ...
            (bsxfun(@times, R, permute(J, [1 3 2])) / DDF);
        F = permute(F, [3 4 1 2]);
        
        SE = sqrt(...
            bsxfun(@times, tdot(tdot(L, XTX), tt(L)), R ./ DDF));
        
        PP = 1 - fcdf(F, ...
            repmat(J', 1, size(F, 2)), ...
            repmat(DDF, size(F))); 
        
        [RB, RR] = trandlstsq(X, Y, NR);
        RB = permute(RB, [1 4 5 2 3]);
        RR = permute(RR, [1 4 5 2 3]);
        
        LRB = tdot(L, RB);
        RF = tdot(tdot(tt(LRB), LXTXL), LRB) ./ ...
            (bsxfun(@times, RR, permute(J, [1 3 2])) / DDF);
        
        LB = permute(LB, [3:5 1 2]);
        LRB = permute(LRB, [3:5 1 2]);
        RF = permute(RF, [3:5 1 2]);
        
        NP = 1 - mean(bsxfun(@gt, F, RF), 3);
        
        LB = LB(:, :, :, 1);
        LRB = LRB(:, :, :, 1);        

        ISTD = cellfun(@(Q) any(ismember(Q, 2:length(COV)+length(WCOV)+1)), IASSIGN);
        LSTD = ISTD(LASSIGN);
        
        if ~isempty(COV) || ~isempty(WCOV)
            LB(LSTD, :) = bsxfun(@rdivide, ...
                LB(LSTD, :), ...
                std(Y(:, :, 1), [], 1));
            LRB(LSTD, :, :) = bsxfun(@rdivide, ...
                LRB(LSTD, :, :), ...
                std(Y(:, :, 1), [], 1));
            
            STD = std(X, [], 1);
            STD(ISTD) = STD(cellfun(@min, IASSIGN(ISTD)));
            STD = STD(LASSIGN(ismember(LASSIGN, find(ISTD))));
            LB(LSTD, :) = bsxfun(@times, ...
                LB(LSTD, :), ...
                tt(STD));
            LRB(LSTD, :, :) = bsxfun(@times, ...
                LRB(LSTD, :, :), ...
                tt(STD));
        end
        
        SE = SE(1, :, :, :);
        SE = permute(SE, [3 4 1 2]);
    end

    function [PP, NP, F, NF, LB, LNB, SE] = NFIT(Y) % Null model networks
        Y = PRE(Y);
        
        YS = [size(Y) 1 1 1 1];
        
        YY = reshape(Y, YS(1), []);
        
        [NB, NR] = tlstsq(X, YY);
        NB = reshape(NB, [], 1, 1, YS(2), YS(3));
        NR = reshape(NR, [], 1, 1, YS(2), YS(3));
        
        LNB = tdot(L, NB);
        NF = tdot(tdot(tt(LNB), LXTXL), LNB) ./ ...
            (bsxfun(@times, NR, permute(J, [1 3 2])) / DDF);
        
        SE = sqrt(...
            bsxfun(@times, tdot(tdot(L, XTX), tt(L)), NR(:, :, 1) ./ DDF));
        
        LNB = permute(LNB, [3:5 1 2]);
        NF = permute(NF, [3:5 1 2]);
        
        F  = NF(:, :, 1);
        NF = NF(:, :, 2:end);
        NP = 1 - mean(bsxfun(@gt, F, NF), 3);
        
        PP = 1 - fcdf(F, ...
            repmat(J', 1, size(F, 2)), ...
            repmat(DDF, size(F))); 
        
        LB = LNB(:, :, 1, 1);
        LNB = LNB(:, :, 2:end, 1);
        
        ISTD = cellfun(@(Q) any(ismember(Q, 2:length(COV)+length(WCOV)+1)), IASSIGN);
        LSTD = ISTD(LASSIGN);
        
        if ~isempty(COV) || ~isempty(WCOV)
            LB(LSTD, :) = bsxfun(@rdivide, ...
                LB(LSTD, :), ...
                std(Y(:, :, 1), [], 1));
            LNB(LSTD, :, :, :) = bsxfun(@rdivide, ...
                LNB(LSTD, :, :, :), ...
                std(Y(:, :, 2:end), [], 1));
            
            STD = std(X, [], 1);
            STD(ISTD) = STD(cellfun(@min, IASSIGN(ISTD)));
            STD = STD(LASSIGN(ismember(LASSIGN, find(ISTD))));
            LB(LSTD, :) = bsxfun(@times, ...
                LB(LSTD, :), ...
                tt(STD));
            LNB(LSTD, :, :) = bsxfun(@times, ...
                LNB(LSTD, :, :), ...
                tt(STD));
        end
        
        SE = SE(1, :, :, :);
        SE = permute(SE, [3 4 1 2]);
    end

end