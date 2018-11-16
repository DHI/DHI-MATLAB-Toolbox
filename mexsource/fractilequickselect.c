/*
* This Quickselect routine is based on the algorithm described in
* "Numerical recipes in C", Second Edition,
* Cambridge University Press, 1992, Section 8.5, ISBN 0-521-43108-5
* This code by Nicolas Devillard - 1998. Public domain.
* Modified to do general fractile search, and to be Matlab compatible by JGR - 2008
*/

#include "mex.h"

#define ELEM_SWAP(a,b) { register double t=(a);(a)=(b);(b)=t; }

double quick_select(double *arr, int n, double fractile);

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  mxArray *mxArrIn, *mxArr, *mxFrac;
  double *arr, *res;
  double fractile;
  int n;
  
  // check the argument counts
  if (nrhs != 2) mexErrMsgIdAndTxt("mzTool:fractilequickselect:inputError","Incorrect number of input arguments.");

  // Load input data.
  mxArrIn = prhs[0];
  mxFrac  = prhs[1];

  if (!mxIsDouble(mxArrIn))
    mexErrMsgIdAndTxt("mzTool:fractilequickselect:inputError","First input must be of type double.");
  
  // Allocate output and initialize to NaN
  plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
  res     = mxGetPr(plhs[0]);
  res[0]  = mxGetNaN();

  // Make a deep copy (otherwise element order is not maintained) 
  mxArr   = mxDuplicateArray(mxArrIn);

  // Extract arguments pointers
  arr       = mxGetPr(mxArr);
  fractile  = *mxGetPr(mxFrac);

  
  // total number of elements in array.
  n = mxGetNumberOfElements(mxArr);

  res[0] = quick_select(arr, n, fractile);

}

double quick_select(double *arr, int n, double fractile)
{
  int low, high;
  int median;
  int middle, ll, hh, count;

  low = 0 ; high = n-1 ; 
  // the index in sorted arr to return, modified compared to original.
  if (fractile >= 1.0)
    median = n-1; // last element
  else if (fractile <= 0.0)
    median = 0;   // first element
  else
    median = (int)(fractile*n);
  
  count = 0;
  for (;;) {
    count++;
    if (high <= low) { /* One element only */
      return arr[median] ;
    }

    if (high == low + 1) { /* Two elements only */
      if (arr[low] > arr[high])
        ELEM_SWAP(arr[low], arr[high]) ;
      return arr[median] ;
    }
    
    /* Find median of low, middle and high items; swap into position low */
    middle = (low + high) / 2;
    if (arr[middle] > arr[high])    ELEM_SWAP(arr[middle], arr[high]) ;
    if (arr[low]    > arr[high])    ELEM_SWAP(arr[low],    arr[high]) ;
    if (arr[middle] > arr[low])     ELEM_SWAP(arr[middle], arr[low]) ;
      
    /* Swap low item (now in position middle) into position (low+1) */
    ELEM_SWAP(arr[middle], arr[low+1]) ;
    
    /* Nibble from each end towards middle, swapping items when stuck */
    ll = low + 1;
    hh = high;
    for (;;) {
      do ll++; while (arr[low] > arr[ll]) ;
      do hh--; while (arr[hh] > arr[low]) ;
      
      if (hh < ll)
        break;
        
      ELEM_SWAP(arr[ll], arr[hh]) ;
    }
    
    /* Swap middle item (in position low) back into correct position */
    ELEM_SWAP(arr[low], arr[hh]) ;
    
    /* Re-set active partition */
    if (hh <= median)
      low = ll;
    if (hh >= median)
      high = hh - 1;
  }
}
#undef ELEM_SWAP
