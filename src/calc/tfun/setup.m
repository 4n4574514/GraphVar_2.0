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

mex tchol.c  -g -v -largeArrayDims -lmwlapack -lmwblas CFLAGS='-std=c99 -fPIC'
mex tdiag.c  -g -v -largeArrayDims -lmwlapack -lmwblas CFLAGS='-std=c99 -fPIC'
mex tdot.c   -g -v -largeArrayDims -lmwlapack -lmwblas CFLAGS='-std=c99 -fPIC'
mex teig.c   -g -v -largeArrayDims -lmwlapack -lmwblas CFLAGS='-std=c99 -fPIC'
mex tlstsq.c -g -v -largeArrayDims -lmwlapack -lmwblas CFLAGS='-std=c99 -fPIC'
mex tluinv.c -g -v -largeArrayDims -lmwlapack -lmwblas CFLAGS='-std=c99 -fPIC'
mex tsvd.c   -g -v -largeArrayDims -lmwlapack -lmwblas CFLAGS='-std=c99 -fPIC'
mex ttr.c    -g -v -largeArrayDims -lmwlapack -lmwblas CFLAGS='-std=c99 -fPIC'

mex trandlstsq.cpp -g -v -largeArrayDims -lmwlapack -lmwblas CXXFLAGS='-std=c++11 -fPIC'