function [zz] = mzCalcNodeValuePL(nn,NodeToElmt,xe,ye,ze,xn,yn)
%MZCALCNODEVALUEPL Calculate node value from element center values.
%
%   Use MZCALCNODEVALUES to calculate node values for an entire mesh.
%
%   Calculate node value from element center values. Based on a Pseudo
%   Laplace procedure by [Holmes, Connell 1989]. Uses an inverse distance
%   average if the pseudo laplace procedure fails. 
%
%   Usage:
%       zz = mzCalcNodeValuePL(nn,NodeToElmt,xe,xn,ye,yn,ze)
%
%   Input:
%       nn         : node number for reconstruction (integer)
%       NodeToElmt : node to element table (nnodes x ?)
%       xe         : element center x coordinates (nelements x 1)
%       ye         : element center y coordinates (nelements x 1)
%       ze         : z value at element centers   (nelements x 1)
%       xn         : node x coordinates (nelements x 1)
%       yn         : node y coordinates (nelements x 1)
%
%   Output:
%       zz         : reconstructed z value at node nn
%
%   NodeToElmt table describes for each node which element is adjacent to
%   this node. May contain padded zeroes. 
%
%   Holmes, D. G. and Connell, S. D. (1989), Solution of the
%       2D Navier-Stokes on unstructured adaptive grids, AIAA Pap.
%       89-1932 in Proc. AIAA 9th CFD Conference.
%
%   See also MZCALCNODEVALUES TRITABLES

% Copyright, DHI, 2007-11-09. Author: JGR

zz = 0;

nelmts = length(find(NodeToElmt(nn,:)));
if (nelmts<1)
  zz = NaN;
  return
end

Rx   = 0;
Ry   = 0;
Ixx  = 0;
Iyy  = 0;
Ixy  = 0;
for i = 1:nelmts
  id = NodeToElmt(nn,i);
  if id==0
    disp('ups') 
    continue;
  end
  dx  = xe(id) - xn(nn);
  dy  = ye(id) - yn(nn);
  Rx  = Rx  + dx;
  Ry  = Ry  + dy;
  Ixx = Ixx + dx*dx;
  Iyy = Iyy + dy*dy;
  Ixy = Ixy + dx*dy;
end
lamda   = Ixx*Iyy - Ixy*Ixy;
if (abs(lamda) > 1.0d-10*(Ixx*Iyy))
  lamda_x = (Ixy*Ry - Iyy*Rx)/lamda;
  lamda_y = (Ixy*Rx - Ixx*Ry)/lamda;

  omega_sum = 0.0;
  zz = 0;
  for i = 1:nelmts
    id = NodeToElmt(nn,i);
    if (id==0)
      continue;
    end
    omega     = 1.0 + lamda_x*(xe(id)-xn(nn)) + lamda_y*(ye(id)-yn(nn));
    % Clipping
    if omega < 0 %-0.5
        omega = 0; %-0.5;
    elseif omega > 2
        omega = 2;
    end
    omega_sum = omega_sum + omega;
    zz = zz + omega*ze(id);
  end
  
  if (abs(omega_sum) > 1.0d-10)
      zz  = zz/omega_sum;
  else
    omega_sum = 0.0d0;
  end
else
  omega_sum = 0.0d0;
end

% We did not succeed using pseudo laplace procedure, 
% use inverse distance instead
if (omega_sum == 0.0d0)
  %disp('Pseudo-Laplace failed - using inverse distance average');
  zz = 0.0d0;
  for i = 1:nelmts
    id = NodeToElmt(nn,i);
    if (id==0)
      continue;
    end
    dx  = xe(id) - xn(nn);
    dy  = ye(id) - yn(nn);

    omega     = 1.0d0/sqrt(dx*dx+dy*dy);
    omega_sum = omega_sum + omega;
    zz = zz + omega*ze(id);
  end   
  if (omega_sum ~= 0.0d0)
    zz = zz/omega_sum;
  else 
    zz = 0.0d0;
  end
end
