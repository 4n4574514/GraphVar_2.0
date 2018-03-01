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

if ismac
    mex bcteval.c -g -v -largeArrayDims -lmwlapack -lmwblas -liomp5 CFLAGS='-std=c99 -fPIC -O3 -qopenmp' CC='/usr/local/bin/icc'
elseif isunix
    mex bcteval.c -g -v -largeArrayDims -lmwlapack -lmwblas -lgomp CFLAGS='-std=c99 -fPIC -O3 -fopenmp'
elseif ispc
    mex bcteval.c -g -v -largeArrayDims -lmwlapack -lmwblas CFLAGS='-std=c99 -fPIC -O3'
end
