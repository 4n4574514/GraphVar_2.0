 // This file is part of GraphVar.

 // Copyright (C) 2016 Lea Waller 

 // GraphVar is free software: you can redistribute it and/or modify
 // it under the terms of the GNU General Public License as published by
 // the Free Software Foundation, either version 3 of the License, or
 // (at your option) any later version.

 // GraphVar is distributed in the hope that it will be useful,
 // but WITHOUT ANY WARRANTY; without even the implied warranty of
 // MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 // GNU General Public License for more details.

 // You should have received a copy of the GNU General Public License
 // along with GraphVar.  If not, see <http://www.gnu.org/licenses/>.

#include "mex.h"
#include "blas.h"
#include "lapack.h"
#include <string.h>
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{	
	if (nrhs != 1) {
		mexErrMsgTxt("ttrace requires one input argument");
	} 

	if (nlhs > 1) {
		mexErrMsgTxt("ttrace allows only one output argument");
	}

	const mxArray *A_ = prhs[0];
	double *A = mxGetPr(A_);

	const ptrdiff_t ndim = mxGetNumberOfDimensions(A_);
	const size_t *adim = mxGetDimensions(A_);

	if(ndim < 2) {
		mexErrMsgTxt("ttrace requires input to be at least 2-dimensional");
	}

	ptrdiff_t m = adim[0], n = adim[1];
	ptrdiff_t mn = !(n < m) ? m : n;
	
	size_t *cdim = (size_t*) mxMalloc(ndim * sizeof(size_t));
	cdim[0] = 1;
	cdim[1] = 1;
	for (int i = 2; i < ndim; i++) {
		cdim[i] = adim[i];
	}

	plhs[0] = mxCreateNumericArray(ndim, cdim, mxDOUBLE_CLASS, mxREAL);
	double *C = mxGetPr(plhs[0]);

	ptrdiff_t npag = 1;
	for(int i = 2; i < ndim; i++) {
		npag *= adim[i];
	}

	for(int i = 0; i < npag; i++) {
		for (int x = 0; x < mn; x++) {
			*(C + i) += *(A + i * m * n + x * m + x);
		}
	}

	mxFree(cdim);
}