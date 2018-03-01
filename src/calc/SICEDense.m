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


function [Adjacency, AchievedDensity] = SICEDense(Covariance, TargetDensity)
    Covariance = Covariance / mean(diag(Covariance));

    function Adjacency = estimateAdjacency(Lambda)
        [~, theta, ~, ~, ~] = glasso(size(Covariance, 2), Covariance, 0, repmat(Lambda, size(Covariance, 2)), 0, 0, 1, 1, 1e-4, 1e4, zeros(size(Covariance)), zeros(size(Covariance)));
        theta =  (theta ./ repmat(sqrt(abs(diag(theta))), 1, size(theta, 1))) ./ repmat(sqrt(abs(diag(theta)))', size(theta, 1), 1);
        theta = 0.5 * (theta + theta'); % always generate symmetric matrix
        
        Adjacency = theta ~= 0;
        Adjacency(logical(eye(size(Adjacency)))) = 0;
    end
    
    uLambda = 0;
    uLambdaIncrement = 1;
    uAdjacency = true(size(Covariance, 2));
    while (any(uAdjacency(:)))
        uLambda = uLambda + uLambdaIncrement;
        uAdjacency = estimateAdjacency(uLambda);
    end
    
    maximumConnections = (size(Covariance, 2) ^ 2 - size(Covariance, 2)) / 2;
    targetConnections = round(TargetDensity * maximumConnections);
    
    Lambda = uLambda / 2;
    Delta = uLambda / 4;
    Connections = NaN;
    while (Connections ~= targetConnections)
        Adjacency = estimateAdjacency(Lambda);
        Connections = nnz(triu(Adjacency));        
        
        if (Connections - targetConnections > 0)
            Lambda = Lambda + Delta;
        elseif (Connections - targetConnections < 0)
            Lambda = Lambda - Delta;
        end
        
        Delta = Delta / 2;
    end
    
    AchievedDensity = nnz(triu(Adjacency)) / maximumConnections;
    Adjacency = double(Adjacency);
end