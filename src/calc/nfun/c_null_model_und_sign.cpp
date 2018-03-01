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

#include <cstdlib>
#include <iostream>
#include <list> 
#include <set> 
#include <algorithm> 
#include <string>
#include <numeric> 
#include <vector> 
#include <random> 
#include <cstdint>
#include <cstring>

using namespace std;

template <class T>
int sign(T X) {
  return (X < 0) ? -1 : (X > 0);
}

template <class Real>
void connection_switching(Real * A,
                          int n, int bin_swaps) {
  random_device randomDevice;
  mt19937 mersenneTwister(randomDevice());
  uniform_int_distribution<> uniform(0, n - 1);

  vector<int> nodes(n);
  iota(nodes.begin(), nodes.end(), 0);

  for (int i = 0; 
       i < bin_swaps * (n * (n - 1) / 2);
       ++i) {
    for (int j = 0; j < n / 2; ++j) {

      for (int k = 0; k < 4; ++k) {
        swap(nodes[k],nodes[uniform(mersenneTwister)]);
      }

      int a = nodes[0], b = nodes[1],
          c = nodes[2], d = nodes[3];

      Real *ab = &A[b * n + a], 
           *cd = &A[d * n + c], 
           *ad = &A[d * n + a], 
           *cb = &A[b * n + c];

      Real a_ab = *ab, 
           a_cd = *cd,
           a_ad = *ad,
           a_cb = *cb;

      if (sign(a_ab) == sign(a_cd) &&
          sign(a_ad) == sign(a_cb) &&
          sign(a_ab) != sign(a_ad)) {
      
        Real *ba = &A[a * n + b], 
             *dc = &A[c * n + d], 
             *da = &A[a * n + d], 
             *bc = &A[c * n + b];

        *ad = a_ab; *ab = a_ad;
        *da = a_ab; *ba = a_ad;
        *cb = a_cd; *cd = a_cb;
        *bc = a_cd; *dc = a_cb;

        break;
      } 
    }
  }

}

template <class Real, int sgn>
void distribute_weights(const Real * W,
                        const Real * WR,
                        Real * W0, 
                        int n) {
  random_device randomDevice;
  mt19937 mersenneTwister(randomDevice());

  Real *S = new Real[n];
  Real *P = new Real[n * n];

  vector<Real> A;
  vector<int> I, J, IJ;

  for (int i = 0; i < n; ++i) {
    for (int j = i + 1; j < n; ++j) {

      if (sign(W[j * n + i]) == sgn) {
        Real WA = sgn * W[j * n + i];

        S[i] += WA;
        S[j] += WA;
        A.push_back(WA);
      }

      if (sign(WR[j * n + i]) == sgn) {
        I.push_back(i);
        J.push_back(j);

        IJ.push_back(j * n + i);
      }

    }
  }

  sort(A.begin(), A.end(),
    [](Real i, Real j) {
      return sgn == 1 ? i > j : i < j;
    }
  );

  for (int i = 0; i < n; ++i) {
    for (int j = i + 1; j < n; j++) {
      P[j * n + i] = S[i] * S[j];
    }
  }

  vector<int> PI(I.size());
  iota(PI.begin(), PI.end(), 0);

  while (!A.empty()) { 
    int R = uniform_int_distribution<>(0, A.size() - 1)(mersenneTwister);

    nth_element(PI.begin(), PI.begin() + R, PI.end(), 
      [&IJ, &P, &n](int i, int j) {
        int II = IJ[i], JJ = IJ[j];
        return sgn == 1 ? P[II] > P[JJ] : P[II] < P[JJ];
      }
    );

    int RR = PI[R];

    int NI = I[RR], NJ = J[RR];
    W0[NI * n + NJ] = W0[NJ * n + NI] = sgn * A[R];

    S[NI] -= A[R];
    S[NJ] -= A[R];

    for (int i = 0, j = NJ; i < j; ++i) {
      P[j * n + i] = S[i] * S[j];
    }
    for (int i = 0, j = NI; i < j; ++i) {
      P[j * n + i] = S[i] * S[j];
    }
    for (int i = NJ, j = i + 1; j < n; ++j) {
      P[j * n + i] = S[i] * S[j];
    }
    for (int i = NI, j = i + 1; j < n; ++j) {
      P[j * n + i] = S[i] * S[j];
    }

    A.erase(A.begin() + R);
    I.erase(I.begin() + RR);
    J.erase(J.begin() + RR);
    IJ.erase(IJ.begin() + RR);

    swap(
      *max_element(PI.begin(), PI.end()),
      PI.back()
    );
    PI.pop_back();

  }

  delete[] S;
  delete[] P;
}

template <class Real>
void null_model_und_sign(const Real * W,
                         Real * W0,
                         int n, int bin_swaps) {


  Real *WR = new Real[n * n];
  memcpy(WR, W, sizeof(Real) * n * n);

  connection_switching(WR, n, bin_swaps);

  distribute_weights<Real,  1>(W, WR, W0, n);
  distribute_weights<Real, -1>(W, WR, W0, n);

  delete[] WR;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{	
	if (nrhs != 2) {
		mexErrMsgTxt("c_null_model_und_sign requires two input arguments");
	} 

	if (nlhs > 1) {
		mexErrMsgTxt("c_null_model_und_sign allows only one output argument");
	}

	const mxArray *A_ = prhs[0];

	const int ndim = mxGetNumberOfDimensions(A_);
	if(ndim != 2) {
		mexErrMsgTxt("c_null_model_und_sign requires input to be 2-dimensional");
	}

	const size_t *adim = mxGetDimensions(A_);
	if (adim[0] != adim[1]) {
		mexErrMsgTxt("c_null_model_und_sign requires input to be square");
	}

	double *A = mxGetPr(A_);
	int n = adim[0];
	
	plhs[0] = mxCreateNumericArray(ndim, adim, mxDOUBLE_CLASS, mxREAL);
	double *C = mxGetPr(plhs[0]);

  int bin_swaps = *mxGetPr(prhs[1]);

	null_model_und_sign<double>(A, C, n, bin_swaps);
}