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

typedef union {
	long long INT64;
	double FLOAT64;
} UFLOAT64;

double eps(double V) {
	UFLOAT64 F;
	F.FLOAT64 = V;
	F.INT64++;
	return F.INT64 < 0 ? V - F.FLOAT64 : F.FLOAT64 - V;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{	
	if (nrhs != 1) {
		mexErrMsgTxt("tpinv requires one input argument");
	} 

	if (nlhs > 1) {
		mexErrMsgTxt("tpinv requires one output argument");
	}

	const mxArray *A_ = prhs[0];

	const ptrdiff_t ndim = mxGetNumberOfDimensions(A_);
	const size_t *adim = mxGetDimensions(A_);

	if(ndim < 2) {
		mexErrMsgTxt("tinv requires input to be at least 2-dimensional");
	}

	plhs[0] = mxCreateNumericArray(ndim, adim, mxDOUBLE_CLASS, mxREAL);
	double *P = mxGetPr(plhs[0]);

	ptrdiff_t m = adim[0], n = adim[1];
	ptrdiff_t mn = !(n < m) ? m : n;

	ptrdiff_t npag = 1;
	for(int i = 2; i < ndim; i++) {
		npag *= adim[i];
	}

	double *A = (double*) mxMalloc(m * n * npag * sizeof(double));
	memcpy(A, mxGetPr(A_), mxGetNumberOfElements(A_) * sizeof(double));

	double *U = (double*) mxMalloc(m * m * sizeof(double));
	double *S = (double*) mxMalloc(n * m * sizeof(double));
	double *VT = (double*) mxMalloc(n * n * sizeof(double));

	double *US = (double*) mxMalloc(n * m * sizeof(double));

	ptrdiff_t lwork = 5 * m + 5 * n;
	double *work = (double*) mxMalloc(lwork * sizeof(double));

	const double zero = 0, one = 1.0;

	mxArray *rhs[1], *lhs[1];


	for(int i = 0; i < npag; i++) {
		memset(U, 0, m * m * sizeof(double));
		memset(S, 0, n * m * sizeof(double));
		memset(VT, 0, n * n * sizeof(double));

		ptrdiff_t info;
		FORTRAN_WRAPPER(dgesvd)("A", "A", &m, &n, A + i * m * n, &m, S, U, &m, VT, &n, work, &lwork, &info);

		if(info < 0) {
			mexErrMsgTxt("tpinv dgesvd error");
		}

		double pinvtol = mn * eps(*(S));
		for (int j = 0; j < mn; j++) {
			if (*(S + j) > pinvtol) {
				*(S + j * n + j) = 1.0 / *(S + j);
			} else {
				*(S + j * n + j) = 0;
			}
		}

		for (int j = 1; j < mn; j++) {
			*(S + j) = 0;
		}

		FORTRAN_WRAPPER(dgemm)("T", "N", &n, &m, &n, &one, VT, &n, S, &n, &zero, US, &n);
		FORTRAN_WRAPPER(dgemm)("N", "T", &n, &m, &m, &one, US, &n, U, &m, &zero, P + i * m * n, &n);
	}

	mxFree(A);

	mxFree(U);
	mxFree(S);
	mxFree(VT);

	mxFree(US);

	mxFree(work);
}