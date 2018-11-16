/***********************************************************
 * trisearch - replacement for tsearch
 *
 * trisearch does not require the triangulation domain to be a convex hull
 * as Matlabs tsearch does. This is almost as fast as MATLAB's tsearch
 *
 * Using technique described in
 *    http://www.blackpawn.com/texts/pointinpoly/default.html
 **********************************************************/


#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    mxArray *mxX, *mxY, *mxTRI, *mxXi, *mxYi;
    double *X, *Y, *TRI, *Xi, *Yi, *T, NaN, ca, cb, cc;
    int nNodes, nElmts, nIn, nCols, i, j, a, b, c, stop;

    // check the argument counts
    if (nrhs != 5) mexErrMsgIdAndTxt("mzTool:trisearch:inputError","Incorrect number of input arguments.");
    
    // Extract arguments
    mxX   = prhs[0];
    mxY   = prhs[1];
    mxTRI = prhs[2];
    mxXi  = prhs[3];
    mxYi  = prhs[4];
    
    // Extract arguments pointers
    X   = mxGetPr(mxX);
    Y   = mxGetPr(mxY);
    TRI = mxGetPr(mxTRI);
    Xi  = mxGetPr(mxXi);
    Yi  = mxGetPr(mxYi);
    
    // Check sizes of X and Y
    nNodes = mxGetNumberOfElements(mxX);
    if (mxGetNumberOfElements(mxY) != nNodes) {
        mexErrMsgIdAndTxt("mzTool:trisearch:inputError","X and Y must be equal in size.");
    }
    // Get size of TRI
    nElmts = mxGetM(mxTRI);
    // Check number of columns
    if (mxGetN(mxTRI) != 3) {
        mexErrMsgIdAndTxt("mzTool:trisearch:inputError","TRI must have 3 columns.");
    }
    
    // Check node indices in TRI
    for (i=0; i < nElmts*3; i++) {
        if (TRI[i] < 1 || TRI[i] > nNodes) {
            mexErrMsgIdAndTxt("mzTool:trisearch:inputError","TRI node indeces out of range.");
        }
    }
    
    // Check sizes of Xi and Yi
    nIn = mxGetNumberOfElements(mxXi);
    if (nIn != mxGetNumberOfElements(mxYi)) {
        mexErrMsgIdAndTxt("mzTool:trisearch:inputError","Xi and Yi must be equal in size.");
    }
    
    // Allocate output and initialize to NaN
    plhs[0] = mxCreateNumericArray(1,&nIn,mxDOUBLE_CLASS,mxREAL);
    T       = mxGetPr(plhs[0]);
    NaN     = mxGetNaN();
    for (i = 0; i < nIn; i++) {
        T[i] = NaN;
    }
    
    // For each element
    for (j = 0; j < nElmts; j++) {
        // Get node indeces (Remember that Matlab is 1 based, C is zero based.)
        a    = TRI[         j]-1;
        b    = TRI[1*nElmts+j]-1;
        c    = TRI[2*nElmts+j]-1;
        // Calculate cross product of (b-a,c-a), (c-b,a-b), (a-c,b-c), 
        ca   = (X[b]-X[a])*(Y[c]-Y[a]) - (Y[b]-Y[a])*(X[c]-X[a]);
        cb   = (X[c]-X[b])*(Y[a]-Y[b]) - (Y[c]-Y[b])*(X[a]-X[b]);
        cc   = (X[a]-X[c])*(Y[b]-Y[c]) - (Y[a]-Y[c])*(X[b]-X[c]);
        // Stop if all input points are found.
        stop = 1;
        for (i = 0; i < nIn; i++) {
            if (T[i] > 0) continue;
            stop = 0;
            // Calculate cross product of (b-a,p-a), (c-b,p-b), (a-c,p-c), they should all 
            // have same sign as the c's.
            if (((X[b]-X[a])*(Yi[i]-Y[a]) - (Y[b]-Y[a])*(Xi[i]-X[a])) * ca < 0) continue;
            if (((X[c]-X[b])*(Yi[i]-Y[b]) - (Y[c]-Y[b])*(Xi[i]-X[b])) * cb < 0) continue;
            if (((X[a]-X[c])*(Yi[i]-Y[c]) - (Y[a]-Y[c])*(Xi[i]-X[c])) * cc < 0) continue;
            // Save found result (remember Matlab is 1 based, C is zero based).
            T[i] = j+1;
        }
        // If stop = 1, then all T[i] have a value and we are done
        if (stop) break;
    }
}
