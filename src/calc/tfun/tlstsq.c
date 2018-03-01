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
	if (nrhs != 2) {
		mexErrMsgTxt("tlstsq requires two input arguments");
	} 

	if (nlhs != 2) {
		mexErrMsgTxt("tlstsq requires two output arguments");
	}

	const mxArray *A_ = prhs[0];
	const mxArray *B_ = prhs[1];

	const ptrdiff_t andim = mxGetNumberOfDimensions(A_);
	const size_t *adim = mxGetDimensions(A_);

	const ptrdiff_t bndim = mxGetNumberOfDimensions(B_);
	const size_t *bdim = mxGetDimensions(B_);

	if(andim != 2 || bndim != 2) {
		mexErrMsgTxt("tlstsq requires input to be 2-dimensional");
	}

	ptrdiff_t m = adim[0], n = adim[1], k = bdim[1];
	
	if (m < n) {
		mexErrMsgTxt("tlstsq requires ");
	}

	double *A = (double*) mxMalloc(m * n * sizeof(double));
	memcpy(A, mxGetPr(A_), mxGetNumberOfElements(A_) * sizeof(double));

	double *B = (double*) mxMalloc(m * k * sizeof(double));
	memcpy(B, mxGetPr(B_), mxGetNumberOfElements(B_) * sizeof(double));

	double *S = (double*) mxMalloc(n * sizeof(double));

	const double rcond = -1;

	ptrdiff_t lwork = -1, liwork = -1;

	double *work = (double*) mxMalloc(1 * sizeof(double));
	ptrdiff_t *iwork = (ptrdiff_t*) mxMalloc(1 * sizeof(ptrdiff_t));

	ptrdiff_t rank, info;

	FORTRAN_WRAPPER(dgelsd)(&m, &n, &k, A, &m, B, &m, S, &rcond, &rank, work, &lwork, iwork, &info);

	if(info < 0) {
		mexErrMsgTxt("tlstsq dgelsd error");
	}

	lwork = *work;
	liwork = *iwork;

	// mexPrintf("%d\t%d", lwork, liwork);

	mxFree(work);
	mxFree(iwork);

	work = (double*) mxMalloc(lwork * sizeof(double));
	iwork = (ptrdiff_t*) mxMalloc(liwork * sizeof(ptrdiff_t));

	FORTRAN_WRAPPER(dgelsd)(&m, &n, &k, A, &m, B, &m, S, &rcond, &rank, work, &lwork, iwork, &info);

	if(info < 0) {
		mexErrMsgTxt("tlstsq dgelsd error");
	}

	if(info > 0) {
		mexWarnMsgTxt("tlstsq dgelsd failed to converge");
	}

	size_t *cdim = (size_t *) mxMalloc(andim * sizeof(size_t));

	cdim[0] = n;
	cdim[1] = k;
	plhs[0] = mxCreateNumericArray(andim, cdim, mxDOUBLE_CLASS, mxREAL);
	double *BETA = mxGetPr(plhs[0]);

	cdim[0] = 1;
	cdim[1] = k;
	plhs[1] = mxCreateNumericArray(andim, cdim, mxDOUBLE_CLASS, mxREAL);
	double *RSS = mxGetPr(plhs[1]);

	for (int i = 0; i < k; i++) {
		for (int j = 0; j < n; j++) {
			BETA[i * n + j] = B[i * m + j];
		}
		for (int j = n; j < m; j++) {
			RSS[i] += pow(B[i * m + j], 2);
		}
	}

	mxFree(A);
	mxFree(B);
	mxFree(S);

	mxFree(cdim);

	mxFree(work);
	mxFree(iwork);
}