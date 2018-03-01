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
		mexErrMsgTxt("teig requires one input argument");
	} 

	if (nlhs != 2) {
		mexErrMsgTxt("teig requires two output arguments");
	}

	const mxArray *A_ = prhs[0];

	const ptrdiff_t ndim = mxGetNumberOfDimensions(A_);
	const size_t *adim = mxGetDimensions(A_);

	if(ndim < 2) {
		mexErrMsgTxt("teig requires input to be at least 2-dimensional");
	}

	if (adim[0] != adim[1]) {
		mexErrMsgTxt("teig requires input to be square");
	}

	ptrdiff_t n = adim[1];

	ptrdiff_t npag = 1;
	for(int i = 2; i < ndim; i++) {
		npag *= adim[i];
	}

	double *A = (double*) mxMalloc(n * n * npag * sizeof(double));
	memcpy(A, mxGetPr(A_), mxGetNumberOfElements(A_) * sizeof(double));

	size_t *cdim = (size_t *) mxMalloc(ndim * sizeof(size_t));
	for(int i = 2; i < ndim; i++) {
		cdim[i] = adim[i];
	}

	cdim[0] = n;
	cdim[1] = 1;
	plhs[0] = mxCreateNumericArray(ndim, cdim, mxDOUBLE_CLASS, mxCOMPLEX);
	double *WR = mxGetPr(plhs[0]);
	double *WI = mxGetPi(plhs[0]);

	cdim[0] = n;
	cdim[1] = n;
	plhs[1] = mxCreateNumericArray(ndim, cdim, mxDOUBLE_CLASS, mxREAL);
	double *VR = mxGetPr(plhs[1]);

	ptrdiff_t lwork = 10 * n;
	double *work = (double*) mxMalloc(lwork * sizeof(double));

	for(int i = 0; i < npag; i++) {
		ptrdiff_t info;
		FORTRAN_WRAPPER(dgeev)("N", "V", &n, A + i * n * n, &n, WR + i * n, WI + i * n, NULL, &n, VR + i * n * n, &n, work, &lwork, &info);

		if(info < 0) {
			mexErrMsgTxt("teig dgeev error");
		}
	}

	mxFree(cdim);

	mxFree(A);
	mxFree(work);
}