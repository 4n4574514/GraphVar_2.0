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

#include <cstdlib>
#include <iostream>
#include <list> 
#include <set> 
#include <algorithm> 
#include <string>
#include <numeric>
#include <vector> 
#include <random> 

#include "mex.h"
#include "blas.h"
#include "lapack.h"

using namespace std;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{	
	random_device randomDevice;
	mt19937 mersenneTwister(randomDevice());

	if (nrhs != 3) {
		mexErrMsgTxt("trandlstsq requires three input arguments");
	} 

	if (nlhs != 2) {
		mexErrMsgTxt("trandlstsq requires two output arguments");
	}

	const mxArray *A_ = prhs[0];
	const mxArray *B_ = prhs[1];
	const double p = *mxGetPr(prhs[2]);

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

	double *X = mxGetPr(A_);
	double *A = (double*) mxMalloc(m * n * sizeof(double));
	memcpy(A, X, m * n * sizeof(double));

	double *Y = mxGetPr(B_);
	double *B = (double*) mxMalloc(m * k * sizeof(double));
	memcpy(B, Y, m * k * sizeof(double));

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

	vector<int> perm(m);
  	iota(perm.begin(), perm.end(), 0);

	const ptrdiff_t cndim = 3;
	size_t *cdim = (size_t *) mxMalloc(cndim * sizeof(size_t));

	cdim[0] = n;
	cdim[1] = k;
	cdim[2] = p;
	plhs[0] = mxCreateNumericArray(cndim, cdim, mxDOUBLE_CLASS, mxREAL);
	double *BETA = mxGetPr(plhs[0]);

	cdim[0] = 1;
	cdim[1] = k;
	cdim[2] = p;
	plhs[1] = mxCreateNumericArray(cndim, cdim, mxDOUBLE_CLASS, mxREAL);
	double *RSS = mxGetPr(plhs[1]);

	for (int q = 0; q < (int) p; q++) {
		shuffle(perm.begin(), perm.end(), mersenneTwister);

		memcpy(A, X, m * n * sizeof(double));
		for (int i = 0; i < k; i++) {
			for (int j = 0; j < m; j++) {
				B[i * m + j] = Y[i * m + perm[j]];
			}
		}
		// memcpy(B, Y, m * k * sizeof(double));

		// cout << perm[0] << " " << perm[1] << endl;

		FORTRAN_WRAPPER(dgelsd)(&m, &n, &k, A, &m, B, &m, S, &rcond, &rank, work, &lwork, iwork, &info);

		if(info < 0) {
			mexErrMsgTxt("tlstsq dgelsd error");
		}

		if(info > 0) {
			mexWarnMsgTxt("tlstsq dgelsd failed to converge");
		}

		for (int i = 0; i < k; i++) {
			for (int j = 0; j < n; j++) {
				BETA[(q * k + i) * n + j] = B[i * m + j];
			}
			for (int j = n; j < m; j++) {
				RSS[q * k + i] += pow(B[i * m + j], 2);
			}
		}
	}

	mxFree(A);
	mxFree(B);
	mxFree(S);

	mxFree(cdim);

	mxFree(work);
	mxFree(iwork);
}