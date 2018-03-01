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

function B = tblkdiag(A)

    sz = size(A);

    n = sz(1);
    
    k = sz(3);

    B = zeros([n * k n * k sz(4:end)]);
    
    for i = 1:k
        I = ((i-1)*n:i*n-1)+1;
        B(I, I, :, :, :, :, :, :) = squeeze(A(:, :, i, :, :, :, :, :, :));
    end

end