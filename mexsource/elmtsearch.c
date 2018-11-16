/***********************************************************
 * elmtsearch - generalization of tsearch
 *
 * Using technique described in
 *    http://www.blackpawn.com/texts/pointinpoly/default.html
 **********************************************************/


#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  mxArray *mxX, *mxY, *mxElmts, *mxXi, *mxYi;
  double *X, *Y, *Elmts, *Xi, *Yi, *T, NaN, ca, da;
  int nNodes, nElmts, nElmtNodes, eNodes, nIn, i, j, k, a, b, c, stop, found;
  char debug[1024];

  // check the argument counts
  if (nrhs != 5) mexErrMsgIdAndTxt("mzTool:elmtsearch:inputError","Incorrect number of input arguments.");
  
  // Extract arguments
  mxX     = prhs[0];
  mxY     = prhs[1];
  mxElmts = prhs[2];
  mxXi    = prhs[3];
  mxYi    = prhs[4];
  
  // Extract arguments pointers
  X     = mxGetPr(mxX);
  Y     = mxGetPr(mxY);
  Elmts = mxGetPr(mxElmts);
  Xi    = mxGetPr(mxXi);
  Yi    = mxGetPr(mxYi);
  
  // Check sizes of X and Y
  nNodes = mxGetNumberOfElements(mxX);
  if (mxGetNumberOfElements(mxY) != nNodes) {
    mexErrMsgIdAndTxt("mzTool:elmtsearch:inputError","X and Y must be equal in size.");
  }
  // Get size of Elmts
  nElmts     = mxGetM(mxElmts);
  nElmtNodes = mxGetN(mxElmts);
  // Check number of columns
  if (nElmtNodes < 3) {
    mexErrMsgIdAndTxt("mzTool:elmtsearch:inputError","Elmts must have minimum 3 columns.");
  }
  
  // Check node indices in Elmts
  for (j=0; j < nElmts; j++) {
    for (i=0; i < nElmtNodes ; i++) {
      if (Elmts[i*nElmts+j] < 1 || Elmts[i*nElmts+j] > nNodes) {
        if (!( Elmts[i*nElmts+j] == 0 && i > 2 )) {
          sprintf(debug,"%i %i %i",j,i,Elmts[i*nElmts+j]);
          mexWarnMsgTxt(debug);
          mexErrMsgIdAndTxt("mzTool:elmtsearch:inputError","Elmts node indeces out of range.");
        }
      }
    }
  }
  
  // Check sizes of Xi and Yi
  nIn = mxGetNumberOfElements(mxXi);
  if (nIn != mxGetNumberOfElements(mxYi)) {
    mexErrMsgIdAndTxt("mzTool:elmtsearch:inputError","Xi and Yi must be equal in size.");
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
    // count number of nodes for this element
    eNodes = 0;
    for (i = 0; i < nElmtNodes; i++) {
      if (Elmts[i*nElmts+j] > 0) {
        eNodes++;
      } else {
        break;
      }
    }
    // Elements with less than 3 nodes are bad (should not happen)
    if (eNodes < 3) continue;
    // Stop when all input points are found.
    stop = 1;
    // For all input points
    for (i = 0; i < nIn; i++) {
      if (T[i] > 0) continue;
      stop  = 0;
      found = 1;
      // for all nodes in element
      for (k = 0; k < eNodes; k++) {
        // Get local node number
        a    =  k;
        b    = (k+1)%eNodes;
        c    = (k+2)%eNodes;
        // Get node indeces (Remember that Matlab is 1 based, C is zero based.)
        a    = Elmts[a*nElmts+j]-1;
        b    = Elmts[b*nElmts+j]-1;
        c    = Elmts[c*nElmts+j]-1;
        // Cross product of (b-a,c-a)
        ca   = (X[b]-X[a])*(Y[c] -Y[a]) - (Y[b]-Y[a])*(X[c] -X[a]);
        // Cross product of (b-a,p-a)
        da   = (X[b]-X[a])*(Yi[i]-Y[a]) - (Y[b]-Y[a])*(Xi[i]-X[a]);
        //sprintf(debug,"   (ca,da) = (%f,%f)",ca,da);
        //mexWarnMsgIdAndTxt("mzTool:elmtsearch:inputError",debug);
        // da and ca should have same sign
        if (da * ca < 0) {
          found = 0;
          break;
        }
      } 
      if (found) {
        T[i] = j+1;
      }
    }
    // If stop = 1, then all T[i] have a value and we are done
    if (stop) break;
  }
}

