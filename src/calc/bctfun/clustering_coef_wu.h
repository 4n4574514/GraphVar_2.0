#ifndef __CLUSTERING_COEF_WU_H__
#define __CLUSTERING_COEF_WU_H__

#include "blas.h"
#include <math.h>

#include <stdint.h>

static double clusterMean_wu(double const * const w,
  double *restrict v, double *restrict c, uint32_t n) {

  for (uint32_t i = 0; i < n; i++) {
    for (uint32_t j = 0; j < n; j++) {
      v[i*n+j] = pow(w[i*n+j], 1.0 / 3.0);
    }
  }

  for (uint32_t i = 0; i < n; i++) {
    v[i*n+i] = 0.0;
  }

  ptrdiff_t nn = n;

  const double zero = 0, one = 1.0;
  FORTRAN_WRAPPER(dsymm)("L",
                         "L",
                         &nn,
                         &nn,
                         &one,
                         v,
                         &nn,
                         v,
                         &nn,
                         &zero,
                         c,
                         &nn);

  double e = 0.0;
  for (uint32_t i = 0; i < n; i++) {
    double f = 0.0;
    uint32_t k = 0;
    for (uint32_t j = 0; j < n; j++) {
      f += v[i*n+j] * c[i*n+j];
      k += (v[i*n+j] != 0) ? 1 : 0;
    }
    if (k > 0 && fabs(f) > DBL_EPSILON) {
      e += f / (k * (k - 1));
    }
  }
  e /= n;

  return e;
}

#endif
