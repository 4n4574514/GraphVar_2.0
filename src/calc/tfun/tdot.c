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

//#include <omp.h>
// #include <iostream>
// using namespace std;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs != 2) {
		mexErrMsgTxt("tdot requires two input arguments");
	} 

	if (nlhs > 1) {
		mexErrMsgTxt("tdot allows only one output argument");
	}

	const mxArray *A_ = prhs[0];
	double *A = mxGetPr(A_);

	const ptrdiff_t andim = mxGetNumberOfDimensions(A_);
	const size_t *adim = mxGetDimensions(A_);

	const mxArray *B_ = prhs[1];
	double *B = mxGetPr(B_);

	const ptrdiff_t bndim = mxGetNumberOfDimensions(B_);
	const size_t *bdim = mxGetDimensions(B_);

	if (andim < 2 || bndim < 2) {
		mexErrMsgTxt("tdot requires inputs to be at least 2-dimensional");
	}

	if (adim[1] != bdim[0]) {
		mexErrMsgTxt("tdot requires inner dimensions to match");
	}

	ptrdiff_t m = adim[0], n = bdim[1], k = adim[1];
	const ptrdiff_t cndim = (bndim < andim) ? andim : bndim;

	size_t *cdim = (size_t*) mxMalloc(cndim * sizeof(size_t));
	cdim[0] = m;
	cdim[1] = n;

	int *acast = (int*) mxMalloc(cndim * sizeof(int));
	int *bcast = (int*) mxMalloc(cndim * sizeof(int));
	for (int i = 2; i < cndim; i++) {
		acast[i] = bcast[i] = 0;

		if (i >= andim) {
			cdim[i] = bdim[i];
			acast[i] = 1;
		} else if (i >= bndim) {
			cdim[i] = adim[i];
			bcast[i] = 1;
		} else if (adim[i] == bdim[i]) {
			cdim[i] = adim[i];
			// no casting
		} else if (adim[i] == 1) {
			cdim[i] = bdim[i];
			acast[i] = 1;
		} else if (bdim[i] == 1) {
			cdim[i] = adim[i];
			bcast[i] = 1;
		} else {
			mexErrMsgTxt("tdot dimension mismatch");
		}
	}

	int *aprod = (int*) mxMalloc(andim * sizeof(int));
	aprod[2] = 1;
	for (int i = 3; i < andim; i++) {
		aprod[i] = aprod[i - 1] * adim[i - 1];
	}

	int *bprod = (int*) mxMalloc(bndim * sizeof(int));
	bprod[2] = 1;
	for (int i = 3; i < bndim; i++) {
		bprod[i] = bprod[i - 1] * bdim[i - 1];
	}

	int *cprod = (int*) mxMalloc(cndim * sizeof(int));
	cprod[2] = 1;
	for (int i = 3; i < cndim; i++) {
		cprod[i] = cprod[i - 1] * cdim[i - 1];
	}

	ptrdiff_t npag = 1;
	for(int i = 2; i < cndim; i++) {
		npag *= cdim[i];
	}

	plhs[0] = mxCreateNumericArray(cndim, cdim, mxDOUBLE_CLASS, mxREAL);
	double *C = mxGetPr(plhs[0]);

	ptrdiff_t *csub = (ptrdiff_t*) mxMalloc(cndim * sizeof(ptrdiff_t));

	const double zero = 0, one = 1.0;

	for(int i = 0; i < npag; i++) {
		int ndx = i;
		for (int j = cndim - 1; j > 1; j--) {
			csub[j] = ndx / cprod[j];
			ndx = ndx % cprod[j];
		}

		ptrdiff_t aind = 0;
		int u = 2;
		// cout << "aind ";
		for (int j = 2; j < cndim; j++) {
			if (!acast[j]) {
				aind += csub[j] * aprod[u];
				// cout << " + " << csub[j] << " * " << aprod[u] << " at j=" << j << " u=" << u;
				++u;
			}
		}	
		// cout << endl;

		ptrdiff_t bind = 0;
		u = 2;
		// cout << "bind ";
		for (int j = 2; j < cndim; j++) {
			if (!bcast[j]) {
				bind += csub[j] * bprod[u];
				// cout << " + " << csub[j] << " * " << bprod[u] << " at j=" << j << " u=" << u;
				++u;
			}
		}
		// cout << endl;

		// cout << i << " -> (" << aind << ", " << bind << ")" << " -> (" << m << ", " << n << ", " << k << ")" << endl; 

		FORTRAN_WRAPPER(dgemm)("N", "N", &m, &n, &k, &one, A + aind * m * k, &m, B + bind * k * n, &k, &zero, C + i * m * n, &m);
	}

	mxFree(cdim);

	mxFree(acast);
	mxFree(bcast);

	mxFree(aprod);
	mxFree(bprod);
	mxFree(cprod);
	
	mxFree(csub);
}