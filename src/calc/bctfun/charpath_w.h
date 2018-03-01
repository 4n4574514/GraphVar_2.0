#ifndef __CHARPATH_W_H__
#define __CHARPATH_W_H__

#include <stdint.h>
#include <math.h>
#include <stdio.h>

#include "distance_wei.h"

static double charpath_w(double const * const d, double *restrict w, uint32_t n) {
  for (uint32_t i = 0; i < n; i++) {
    for (uint32_t j = 0; j < n; j++) {
      w[i*n+j] = 1.0 / d[i*n+j];
    }
  }

  distance_wei(w, n);

  double e = 0.0;
  uint32_t k = 0;
  for (uint32_t i = 0; i < n; i++) {
    for (uint32_t j = 0; j < n; j++) {
      if (!isinf(w[i*n+j])) {
        e += w[i*n+j];
        k++;
      }
    }
  }

  e /= k;

  return e;
}

#endif
