%  This file is part of GraphVar.
%
%  Copyright (C) 2014
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

function outfiles = generateFromTimecourses(path,importFiles,partial,spearman,bend,mutual,SICEdense,covariance,brain,importFieldName,rand,rand_type,rand_n,SICE_density,is_dyn,leng,add,varargin)
global workspacePath;
global running;
wnd = [];
if(nargin > 2)
    wnd  = varargin{1};
end
t = Inf;
load(fullfile(workspacePath,'Workspace.mat'));
[brainSheet variableSheet] =  abs_rel_correct(brainSheet,variableSheet);

%[BrainMap] = xlsread(brainSheet);
nSub = length(importFiles);

isParallel = 0; 
    % parallel computing temporarily disabled for generating
    % conn matrices from time courses (i.e., vectorization seems fast enough; else ~=0)

if isParallel 
    set(wnd,'WindowStyle','normal');
    waitbar(1,wnd,'Progress: MainWindow - wait to finish','Interpreter','none');
    
    if (~exist([workspacePath filesep 'results' filesep 'CorrMatrix'], 'dir'))
        mkdir([workspacePath filesep 'results' filesep 'CorrMatrix']);
    end
    
    if(is_dyn == 1)
        contents = load ([path filesep importFiles{1}]);
        if add > leng
            temp_dyn = floor((size(contents.(importFieldName{:}),1)) / add);
            if ((size(contents.(importFieldName{:}),1))-(add*temp_dyn))>= leng
                n_dyn = (temp_dyn + 1);
            else
                n_dyn = temp_dyn;
            end
        else
            n_dyn = floor((size(contents.(importFieldName{:}),1)-(leng-add)) / add);
        end
    else
        n_dyn = 1;
    end
    
    disp(repmat('#', 2, 60))
    disp([repmat('#', 1, 24) '  Progress  ' repmat('#', 1, 24)])
    disp([repmat('#', 1, 24) '  Display  ' repmat('#', 1, 25)])
    disp(repmat('#', 2, 60))
    disp('Press Ctrl-C to cancel. ')
    

    for i_sub=1:nSub
        
        for i_dyn = 1:n_dyn
            tic
         
            contents = load ([path filesep importFiles{i_sub}]);
            
            if(is_dyn == 1)
                start = 1 + (add * (i_dyn-1));
                stop = start + (leng-1);
            else
                start = 1;
                stop = size(contents.(importFieldName{:}),1);
            end
            
            
            ROISignals = contents.(importFieldName{:})(start:stop,:);
            matrixSize =  size(ROISignals,2);
            CorrMatrix = ones(matrixSize);
            PValMatrix = zeros(matrixSize);
            RandPValMatrix = zeros(matrixSize);
            RandCorrMatrix = zeros(matrixSize,matrixSize,rand_n);
            
            if (partial)
                [CorrMatrix, PValMatrix] = partialcorr(ROISignals);
                
                % make symmetric
                CorrMatrix = (CorrMatrix + CorrMatrix') / 2;
            elseif (spearman)
                pairs = combnk(1:matrixSize, 2);
                [correlations, ~, pvalues]  = Spearman(ROISignals(:, pairs(:, 1)),ROISignals(:, pairs(:, 2)));
                
                udiag = sub2ind(size(CorrMatrix), pairs(:, 1), pairs(:, 2));
                ldiag = sub2ind(size(CorrMatrix), pairs(:, 2), pairs(:, 1));
                
                CorrMatrix(udiag) = correlations;
                CorrMatrix(ldiag) = correlations;
                
                PValMatrix(udiag) = pvalues;
                PValMatrix(ldiag) = pvalues;
            elseif (bend)
                pairs = combnk(1:matrixSize, 2);
                [correlations, ~, pvalues]  = bendcorr(ROISignals(:, pairs(:, 1)),ROISignals(:, pairs(:, 2)));
                
                udiag = sub2ind(size(CorrMatrix), pairs(:, 1), pairs(:, 2));
                ldiag = sub2ind(size(CorrMatrix), pairs(:, 2), pairs(:, 1));
                
                CorrMatrix(udiag) = correlations;
                CorrMatrix(ldiag) = correlations;
                
                PValMatrix(udiag) = pvalues;
                PValMatrix(ldiag) = pvalues;
            elseif (mutual)
                for i = 1:matrixSize
                    for ii = i+1:matrixSize
                        [CorrMatrix(i,ii)]  = mutualinf(ROISignals(:,i),ROISignals(:,ii));
                        CorrMatrix(ii,i) = CorrMatrix(i,ii);
                    end
                end
            elseif (SICEdense)
                [CorrMatrix] = SICEDense(cov(ROISignals),SICE_density);
            elseif (covariance)
                [CorrMatrix] = cov(ROISignals);
            else
                [CorrMatrix, PValMatrix] = corr(ROISignals);
                
                % make symmetric
                CorrMatrix = (CorrMatrix + CorrMatrix') / 2;
            end
            
            if(rand)
                s = size(ROISignals);
                if rand_type == 1
                    RandomSignal(:,:,:) = random('norm',mean(ROISignals(:)),std(ROISignals(:)),s(1),s(2),rand_n);
                elseif rand_type == 2
                    randomizer = randi( s(1) * s(2),s(1) * s(2),rand_n);
                    Signals = ROISignals(:);
                    RandomSignal = zeros(s(1),s(2),rand_n);
                    
                    for j = 1:rand_n
                        RandomSignal(:,:,j) = reshape(Signals(randomizer(:,j)),s(1),s(2));
                    end
                    %clear Signals;
                    
                elseif rand_type == 3
                    % Multivariate algorithm from
                    % Prichard, D., & Theiler, J. (1994).
                    % Generating surrogate data for time series with several
                    % simultaneously measured variables.
                    % Physical Review Letters, 73(7), 951.
                    
                    RandomSignal = zeros([size(ROISignals) rand_n]);
                    FFTROISignals = fft(ROISignals);
                    for i_rand_n = 1:rand_n
                        RandomSignal(:, :, i_rand_n) = ifft(bsxfun(@times, FFTROISignals, exp(1i * unifrnd(0, 2 * pi, [size(ROISignals, 1) 1]))), 'symmetric');
                    end
                    
                end
                
                for i = 1:rand_n
                    if (partial)
                        [RandCorrMatrix(:, :, i), ~] = partialcorr(RandomSignal(:, :, i));
                        
                        % make symmetric
                        RandCorrMatrix(:, :, i) = (RandCorrMatrix(:, :, i) + RandCorrMatrix(:, :, i)') / 2;
                    elseif (spearman)
                        pairs = combnk(1:matrixSize, 2);
                        [correlations, ~, ~]  = Spearman(RandomSignal(:, pairs(:, 1), i),RandomSignal(:, pairs(:, 2), i));
                        
                        udiag = sub2ind(size(CorrMatrix), pairs(:, 1), pairs(:, 2));
                        ldiag = sub2ind(size(CorrMatrix), pairs(:, 2), pairs(:, 1));
                        
                        subRandCorrMatrix = ones(matrixSize);
                        subRandCorrMatrix(udiag) = correlations;
                        subRandCorrMatrix(ldiag) = correlations;
                        RandCorrMatrix(:, :, i) = subRandCorrMatrix;
                    elseif (bend)
                        pairs = combnk(1:matrixSize, 2);
                        [correlations, ~, ~]  = bendcorr(RandomSignal(:, pairs(:, 1), i),RandomSignal(:, pairs(:, 2), i));
                        
                        udiag = sub2ind(size(CorrMatrix), pairs(:, 1), pairs(:, 2));
                        ldiag = sub2ind(size(CorrMatrix), pairs(:, 2), pairs(:, 1));
                        
                        subRandCorrMatrix = ones(matrixSize);
                        subRandCorrMatrix(udiag) = correlations;
                        subRandCorrMatrix(ldiag) = correlations;
                        RandCorrMatrix(:, :, i) = subRandCorrMatrix;
                    elseif (mutual)
                        for m_i = 1:matrixSize
                            for m_ii = m_i+1:matrixSize
                                [RandCorrMatrix(m_i, m_ii, i),~]  = mutualinf(RandomSignal(:, m_i, i),RandomSignal(:, m_ii, i));
                                RandCorrMatrix(m_ii, m_i, i) = RandCorrMatrix(m_i, m_ii, i);
                            end
                        end
                    elseif (SICEdense)
                        [RandCorrMatrix(:, :, i)] = SICEDense(cov(RandomSignal(:, :, i)),SICE_density);
                    elseif (covariance)
                        [RandCorrMatrix] = cov(RandomSignal(:, :, i));
                    else
                        [RandCorrMatrix(:, :, i), ~] = corr(RandomSignal(:, :, i));
                        
                        % make symmetric
                        RandCorrMatrix(:, :, i) = (RandCorrMatrix(:, :, i) + RandCorrMatrix(:, :, i)') / 2;
                    end
                    
                    for m_i = 1:matrixSize
                        for m_ii = m_i+1:matrixSize
                            input = [CorrMatrix(m_ii, m_i) rot90(squeeze(RandCorrMatrix(m_ii, m_i, :)))];
                            RandPValMatrix(m_ii,m_i) = calcCorrectedPVals(input,0,1);
                            RandPValMatrix(m_i,m_ii) = RandPValMatrix(m_ii,m_i);
                        end
                    end
                end
            end
            
            %PlotImg(CorrMatrix);
            [row,col] = find(PValMatrix<0.001);
            
            BMatrix = zeros(matrixSize);
            for i = 1:length(row)
                BMatrix(row(i),col(i)) = 1;
            end
            
            if(is_dyn == 1)
                CorrMatrix_t{i_dyn}         = CorrMatrix;
                PValMatrix_t{i_dyn}         = PValMatrix;
                BMatrix_t{i_dyn}            = BMatrix;
                RandCorrMatrix_t{i_dyn}     = RandCorrMatrix;
                RandPValMatrix_t{i_dyn}     = RandPValMatrix;
            end
            
        end
        
        
        if(is_dyn == 1)
            CorrMatrix = CorrMatrix_t;
            PValMatrix =PValMatrix_t ;
            BMatrix  = BMatrix_t;
            RandCorrMatrix{i_dyn}     = RandCorrMatrix_t;
            RandPValMatrix  =  RandPValMatrix_t;
        end
        
        importFile_ = strrep(importFiles{i_sub}, 'ROISignals_', '');
        
        if rand
            saveGeneratedTimecourses([workspacePath filesep 'results' filesep 'CorrMatrix' filesep 'CorrMatrix_' importFile_], CorrMatrix,PValMatrix,BMatrix,RandPValMatrix);
        elseif SICEdense
            saveGeneratedTimecourses([workspacePath filesep 'results' filesep 'SICEMatrix' filesep 'SICEMatrix_' num2str(SICE_density) '_' importFile_],CorrMatrix,PValMatrix,BMatrix,[])
        else
            saveGeneratedTimecourses([workspacePath filesep 'results' filesep 'CorrMatrix' filesep 'CorrMatrix_' importFile_], CorrMatrix,PValMatrix,BMatrix,[]);
        end
        
        disp(['Generated correlation matrix for subject ' num2str(i_sub) ' of ' num2str(nSub)])
    end
    
    outfiles = cell(1, nSub);
    
    for i_sub=1:nSub
        if SICEdense
            outfiles{i_sub} = [workspacePath filesep 'results'  filesep 'SICEMatrix' filesep 'SICEMatrix_' num2str(SICE_density) '_' importFile_];
        else
            outfiles{i_sub} = [workspacePath filesep 'results'  filesep 'CorrMatrix' filesep 'CorrMatrix_' importFile_];
        end
    end
    
    
else
    
    
    if(is_dyn == 1)
        contents = load ([path filesep importFiles{1}]);
        if add > leng
            temp_dyn = floor((size(contents.(importFieldName{:}),1)) / add);
            if ((size(contents.(importFieldName{:}),1))-(add*temp_dyn))>= leng
                n_dyn = (temp_dyn + 1);
            else
                n_dyn = temp_dyn;
            end
        else
            n_dyn = floor((size(contents.(importFieldName{:}),1)-(leng-add)) / add);
        end
    else
        n_dyn = 1; 
    end
    
    
    for i_sub=1:nSub
        for i_dyn = 1:n_dyn
            tic
            
            
            contents = load ([path filesep importFiles{i_sub}]);
            
            if(is_dyn == 1)
                start = 1 + (add * (i_dyn-1));
                stop = start + (leng-1);
            else
                start = 1;
                stop = size(contents.(importFieldName{:}),1);
            end
            
            ROISignals = contents.(importFieldName{:})(start:stop,:);
            matrixSize =  size(ROISignals,2);
            CorrMatrix = ones(matrixSize);
            PValMatrix = zeros(matrixSize);
            RandPValMatrix = zeros(matrixSize);
            RandCorrMatrix = zeros(matrixSize,matrixSize,rand_n);
            
            
            
            if (partial)
                [CorrMatrix, PValMatrix] = partialcorr(ROISignals);
                
                % make symmetric
                CorrMatrix = (CorrMatrix + CorrMatrix') / 2;
            elseif (spearman)
                pairs = combnk(1:matrixSize, 2);
                [correlations, ~, pvalues]  = Spearman(ROISignals(:, pairs(:, 1)),ROISignals(:, pairs(:, 2)));
                
                udiag = sub2ind(size(CorrMatrix), pairs(:, 1), pairs(:, 2));
                ldiag = sub2ind(size(CorrMatrix), pairs(:, 2), pairs(:, 1));
                
                CorrMatrix(udiag) = correlations;
                CorrMatrix(ldiag) = correlations;
                
                PValMatrix(udiag) = pvalues;
                PValMatrix(ldiag) = pvalues;
            elseif (bend)
                pairs = combnk(1:matrixSize, 2);
                [correlations, ~, pvalues]  = bendcorr(ROISignals(:, pairs(:, 1)),ROISignals(:, pairs(:, 2)));
                
                udiag = sub2ind(size(CorrMatrix), pairs(:, 1), pairs(:, 2));
                ldiag = sub2ind(size(CorrMatrix), pairs(:, 2), pairs(:, 1));
                
                CorrMatrix(udiag) = correlations;
                CorrMatrix(ldiag) = correlations;
                
                PValMatrix(udiag) = pvalues;
                PValMatrix(ldiag) = pvalues;
            elseif (mutual)
                for i = 1:matrixSize
                    for ii = i+1:matrixSize
                        [CorrMatrix(i,ii)]  = mutualinf(ROISignals(:,i),ROISignals(:,ii));
                        CorrMatrix(ii,i) = CorrMatrix(i,ii);
                    end
                end
            elseif (SICEdense)
                [CorrMatrix] = SICEDense(cov(ROISignals),SICE_density);
            elseif (covariance)
                [CorrMatrix] = cov(ROISignals);
            else
                [CorrMatrix, PValMatrix] = corr(ROISignals);
                
                % make symmetric
                CorrMatrix = (CorrMatrix + CorrMatrix') / 2;
            end
            
            if(rand)
                s = size(ROISignals);
                if rand_type == 1
                    RandomSignal(:,:,:) = random('norm',mean(ROISignals(:)),std(ROISignals(:)),s(1),s(2),rand_n);
                elseif rand_type == 2
                    randomizer = randi( s(1) * s(2),s(1) * s(2),rand_n);
                    Signals = ROISignals(:);
                    RandomSignal = zeros(s(1),s(2),rand_n);
                    
                    for j = 1:rand_n
                        RandomSignal(:,:,j) = reshape(Signals(randomizer(:,j)),s(1),s(2));
                        if(nargin > 2)
                            waitbar(i_sub/nSub,wnd,[num2str(i_sub) '/' num2str(nSub) ' - ' num2str(t*(nSub-i_sub)) ' seconds left'],'Interpreter','none');
                            if ~running
                                outfiles = [];
                                delete(wnd);
                                return;
                            end
                        end
                        
                    end
                    clear Signals;
                elseif rand_type == 3
                    % Multivariate algorithm from
                    % Prichard, D., & Theiler, J. (1994).
                    % Generating surrogate data for time series with several
                    % simultaneously measured variables.
                    % Physical Review Letters, 73(7), 951.
                    
                    RandomSignal = zeros([size(ROISignals) rand_n]);
                    FFTROISignals = fft(ROISignals);
                    for i_rand_n = 1:rand_n
                        RandomSignal(:, :, i_rand_n) = ifft(bsxfun(@times, FFTROISignals, exp(1i * unifrnd(0, 2 * pi, [size(ROISignals, 1) 1]))), 'symmetric');
                    end
                end
                
                for i = 1:rand_n
                    if (partial)
                        [RandCorrMatrix(:, :, i), ~] = partialcorr(RandomSignal(:, :, i));
                        
                        % make symmetric
                        RandCorrMatrix(:, :, i) = (RandCorrMatrix(:, :, i) + RandCorrMatrix(:, :, i)') / 2;
                    elseif (spearman)
                        pairs = combnk(1:matrixSize, 2);
                        [correlations, ~, ~]  = Spearman(RandomSignal(:, pairs(:, 1), i),RandomSignal(:, pairs(:, 2), i));
                        
                        udiag = sub2ind(size(CorrMatrix), pairs(:, 1), pairs(:, 2));
                        ldiag = sub2ind(size(CorrMatrix), pairs(:, 2), pairs(:, 1));
                        
                        subRandCorrMatrix = ones(matrixSize);
                        subRandCorrMatrix(udiag) = correlations;
                        subRandCorrMatrix(ldiag) = correlations;
                        RandCorrMatrix(:, :, i) = subRandCorrMatrix;
                    elseif (bend)
                        pairs = combnk(1:matrixSize, 2);
                        [correlations, ~, ~]  = bendcorr(RandomSignal(:, pairs(:, 1), i),RandomSignal(:, pairs(:, 2), i));
                        
                        udiag = sub2ind(size(CorrMatrix), pairs(:, 1), pairs(:, 2));
                        ldiag = sub2ind(size(CorrMatrix), pairs(:, 2), pairs(:, 1));
                        
                        subRandCorrMatrix = ones(matrixSize);
                        subRandCorrMatrix(udiag) = correlations;
                        subRandCorrMatrix(ldiag) = correlations;
                        RandCorrMatrix(:, :, i) = subRandCorrMatrix;
                    elseif (mutual)
                        for m_i = 1:matrixSize
                            for m_ii = m_i+1:matrixSize
                                [RandCorrMatrix(m_i, m_ii, i),~]  = mutualinf(RandomSignal(:, m_i, i),RandomSignal(:, m_ii, i));
                                RandCorrMatrix(m_ii, m_i, i) = RandCorrMatrix(m_i, m_ii, i);
                            end
                        end
                    elseif (SICEdense)
                        [RandCorrMatrix(:, :, i)] = SICEDense(cov(RandomSignal(:, :, i)),SICE_density);
                    elseif (covariance)
                        [RandCorrMatrix] = cov(RandomSignal(:, :, i));
                    else
                        [RandCorrMatrix(:, :, i), ~] = corr(RandomSignal(:, :, i));
                        
                        % make symmetric
                        RandCorrMatrix(:, :, i) = (RandCorrMatrix(:, :, i) + RandCorrMatrix(:, :, i)') / 2;
                    end
                    
                    for m_i = 1:matrixSize
                        for m_ii = m_i+1:matrixSize
                            input = [CorrMatrix(m_ii, m_i) rot90(squeeze(RandCorrMatrix(m_ii, m_i, :)))];
                            RandPValMatrix(m_ii,m_i) = calcCorrectedPVals(input,0,1);
                            RandPValMatrix(m_i,m_ii) = RandPValMatrix(m_ii,m_i);
                        end
                    end
                end
            end
            
            %PlotImg(CorrMatrix);
            [row,col] = find(PValMatrix<0.001);
            
            BMatrix = zeros(matrixSize);
            for i = 1:length(row)
                BMatrix(row(i),col(i)) = 1;
            end
            
            
            if(is_dyn == 1)
                CorrMatrix_t{i_dyn}         = CorrMatrix;
                PValMatrix_t{i_dyn}         = PValMatrix;
                BMatrix_t{i_dyn}            = BMatrix;
                RandCorrMatrix_t{i_dyn}     = RandCorrMatrix;
                RandPValMatrix_t{i_dyn}     = RandPValMatrix;
            end
            
        end
        
        
        if(is_dyn == 1)
            CorrMatrix = CorrMatrix_t;
            PValMatrix =PValMatrix_t ;
            BMatrix  = BMatrix_t;
            RandCorrMatrix{i_dyn}     = RandCorrMatrix_t;
            RandPValMatrix  =  RandPValMatrix_t;
        end
        
        
        importFile_ = strrep(importFiles{i_sub}, 'ROISignals_', '');
        
        
        if rand
            save([workspacePath filesep 'results' filesep 'CorrMatrix' filesep 'CorrMatrix_' importFile_],'CorrMatrix','PValMatrix','BMatrix','RandPValMatrix','is_dyn');
        elseif SICEdense
            save([workspacePath filesep 'results' filesep 'SICEMatrix' filesep 'SICEMatrix_' num2str(SICE_density) '_' importFile_],'CorrMatrix','PValMatrix','BMatrix','is_dyn');
        else
            save([workspacePath filesep 'results' filesep 'CorrMatrix' filesep 'CorrMatrix_' importFile_],'CorrMatrix','PValMatrix','BMatrix','is_dyn');
        end
        
        if SICEdense
            outfiles{i_sub} = [workspacePath filesep 'results'  filesep 'SICEMatrix' filesep 'SICEMatrix_' num2str(SICE_density) '_' importFile_];
        else
            outfiles{i_sub} = [workspacePath filesep 'results'  filesep 'CorrMatrix' filesep 'CorrMatrix_' importFile_];
        end
        
        t = toc;
        
        if(nargin > 2)
            if ~running
                outfiles = [];
                delete(wnd);
                return;
            end
            waitbar(i_sub/nSub,wnd,[num2str(i_sub) '/' num2str(nSub) ' - ' num2str(t*(nSub-i_sub)) ' seconds left'],'Interpreter','none');
        end
        
    end
end
