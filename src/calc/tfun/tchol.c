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
		mexErrMsgTxt("tchol requires one input argument");
	} 

	if (nlhs > 1) {
		mexErrMsgTxt("tchol allows only one output argument");
	}

	const mxArray *A = prhs[0];

	const ptrdiff_t ndim = mxGetNumberOfDimensions(A);
	const size_t *adim = mxGetDimensions(A);

	if(ndim < 2) {
		mexErrMsgTxt("tchol requires input to be at least 2-dimensional");
	}

	if (adim[0] != adim[1]) {
		mexErrMsgTxt("tchol requires input to be square");
	}
	
	ptrdiff_t m = adim[0];

	plhs[0] = mxCreateNumericArray(ndim, adim, mxDOUBLE_CLASS, mxREAL);
	double *L = mxGetPr(plhs[0]);
	memcpy(L, mxGetPr(A), mxGetNumberOfElements(A) * sizeof(double));

	ptrdiff_t npag = 1;
	for(int i = 2; i < ndim; i++) {
		npag *= adim[i];
	}

	for(int i = 0; i < npag; i++) {

		// store chol in lower diagonal
		ptrdiff_t info;
		FORTRAN_WRAPPER(dpotrf)("L", &m, L + i * m * m, &m, &info);

		if(info < 0) {
			mexErrMsgTxt("tchol dpotrf error");
		}

		for (int j = 0; j < adim[0]; j++) {
			for (int k = j + 1; k < adim[1]; k++) {
				*(L + i * m * m + k * adim[0] + j) = 0; // zero upper diagonal
			}
		}
	}
}