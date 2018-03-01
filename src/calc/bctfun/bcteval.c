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
#include <stdint.h>

#ifdef _OPENMP
#include <omp.h>
#endif

#include "clustering_coef_wu.h"
#include "efficiency_wei.h"
#include "charpath_w.h"

/*
w = rand(500);
x = w + w';
x(x<0.95) = 0;
y = repmat(x, 1, 1, 10, 10);
bcteval('efficiency_wei', y)
bcteval('charpath_W', y)
bcteval('clusterMean_wu', y)
*/

void mexFunction(int nlhs, mxArray *plhs[],
  int nrhs, const mxArray *prhs[]) {

  char *fn = mxArrayToString(prhs[0]);

  mxLogical *pl;

  double *a;
  double *c;
  ptrdiff_t andim;
  const size_t *adim;
  size_t aprod = 1;

  if (nrhs == 1) {
    plhs[0] = mxCreateLogicalMatrix(1,1);
    pl = mxGetLogicals(plhs[0]);
    pl[0] = 0;

    if (strcmp(fn, "efficiency_wei") == 0) {
      pl[0] = 1;
    } else if (strcmp(fn, "charpath_W") == 0) {
      pl[0] = 1;
    } else if (strcmp(fn, "clusterMean_wu") == 0) {
      pl[0] = 1;
    }

    return;
  }

	const mxArray *aArray = prhs[1];
	a = mxGetPr(aArray);
  andim = mxGetNumberOfDimensions(aArray);
  adim = mxGetDimensions(aArray);

  for (int i = 0; i < andim - 2; i++) {
    aprod *= adim[i + 2];
  }

  ptrdiff_t cndim = andim - 2;
  if (cndim == 0) {
    cndim = 1;
  }
  size_t *cdim = (size_t*) mxMalloc(cndim * sizeof(size_t));
  if (cndim > 1) {
  	for (int i = 0; i < cndim; i++) {
  		cdim[i] = adim[i + 2];
  	}
  } else {
    cdim[0] = 1;
  }

	plhs[0] = mxCreateNumericArray(cndim, cdim, mxDOUBLE_CLASS, mxREAL);
	c = mxGetPr(plhs[0]);

  uint32_t mp = 1;
  #ifdef _OPENMP
  #pragma omp parallel
  #pragma omp single
  {
    mp = omp_get_num_threads();
  }
  #endif

  uint32_t n = adim[0];
  double *w;
  double *v;

  double *d = (double*) mxMalloc(2 * mp * n * n * sizeof(double));

  size_t k = 0;

  #ifdef _OPENMP
  #pragma omp parallel private(w,v)
  #endif
  {
    #ifdef _OPENMP
    #pragma omp critical
    #endif
    {
      w = &d[k];
      k += n*n;
      v = &d[k];
      k += n*n;
    }

    if (strcmp(fn, "efficiency_wei") == 0) {
      #ifdef _OPENMP
      #pragma omp for schedule(static)
      #endif
      for (uint32_t i = 0; i < aprod; i++) {
        c[i] = efficiency_wei(&a[n*n*i], w, n);
      }
    } else if (strcmp(fn, "charpath_W") == 0) {
      #ifdef _OPENMP
      #pragma omp for schedule(static)
      #endif
      for (uint32_t i = 0; i < aprod; i++) {
        c[i] = charpath_w(&a[n*n*i], w, n);
      }
    } else if (strcmp(fn, "clusterMean_wu") == 0) {
      #ifdef _OPENMP
      #pragma omp for schedule(static)
      #endif
      for (uint32_t i = 0; i < aprod; i++) {
        c[i] = clusterMean_wu(&a[n*n*i], w, v, n);
      }
    }
  }

  mxFree(d);
}
