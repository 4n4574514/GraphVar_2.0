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
%  Written by L. Waller

function lambda = SICE(Covariance)
    
    w = zeros(size(Covariance));
    theta = zeros(size(Covariance));
    function Blocks = estimateConnectedComponents(lambda)
        [w, theta, iter, avgTol, hasError] = glasso(size(Covariance, 2), Covariance, 0, repmat(lambda, size(Covariance, 2)), 0, 0, 1, 1, 1e-4, 1e4, w, theta);
%         disp(['lambda=' num2str(lambda) ' iter=' num2str(iter) ' avgTol=' num2str(avgTol) ' hasError=' num2str(hasError)])

        Adjacency = theta ~= 0;
        
        [~, p, ~, r] = dmperm(Adjacency);
        NC = length(r) - 1;
        
        Blocks = zeros(1, size(Covariance, 2));
        Blocks(r(1:NC)) = 1;
        Blocks = cumsum(Blocks);
        Blocks = Blocks(p);
    end
    
    uLambda = 0;
    uLambdaIncrement = 1;
    uBlocks = true(size(Covariance, 2));
    while (length(unique(uBlocks)) ~= size(Covariance, 2))
        uLambda = uLambda + uLambdaIncrement;
        uBlocks = estimateConnectedComponents(uLambda);
    end
    
    function [treeLambda, treeBlocks] = treeRecursion(uLambda, lLambda, uBlocks, lBlocks)
        treeLambda = [];
        treeBlocks = {}; 
        
        mLambda = (uLambda + lLambda) / 2;
        mBlocks = estimateConnectedComponents(mLambda);

        lDelta = length(unique(mBlocks)) - length(unique(lBlocks));
        uDelta = length(unique(uBlocks)) - length(unique(mBlocks));

        if (lDelta == 1)
            treeLambda = [treeLambda lLambda];
            treeBlocks = [treeBlocks lBlocks];
        elseif (lDelta > 1)
            [uTreeLambda, uTreeCC] = treeRecursion(mLambda, lLambda, mBlocks, lBlocks);
            treeLambda = [treeLambda uTreeLambda];
            treeBlocks = [treeBlocks uTreeCC];
        end

        if (uDelta == 1)
            treeLambda = [treeLambda mLambda];
            treeBlocks = [treeBlocks mBlocks];
        elseif (uDelta > 1)
            [lTreeLambda, lTreeCC] = treeRecursion(uLambda, mLambda, uBlocks, mBlocks);
            treeLambda = [treeLambda lTreeLambda];
            treeBlocks = [treeBlocks lTreeCC];
        end
    end

    set(0,'RecursionLimit', 100000)
    [treeLambda, treeBlocks] = treeRecursion(uLambda, 0, uBlocks, true(1, size(Covariance, 2)));   

    treeCC = false(size(Covariance, 2), size(Covariance, 2), length(treeBlocks));
    for i = 1:length(treeBlocks)
        blocks = treeBlocks{i};
        treeCC(:, :, i) = repmat(blocks, length(blocks), 1) == repmat(blocks, length(blocks), 1)';
    end
    
    lambda = sum(treeCC, 3) / length(treeLambda);
end