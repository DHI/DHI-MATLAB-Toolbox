function mzMeshAnalyse(filepathname,s)
%MZMESHANALYSE  Analyse and improve mesh.
%
%   mzMeshAnalyse analyses a mesh and highlights elements which gives the
%   mesh a "bad" quality. The user can zoom in on the worse element or
%   toggle between the 20 worse elements in the mesh. And the user can edit
%   and modify the mesh in order to improve on the quality.
%
%   Usage:
%       mzMeshAnalyse()
%       mzMeshAnalyse(meshfilename)
%       mzMeshAnalyse(meshfilename,s)
%
%   Inputs:
%       meshfilename  : filename of mesh file. Leave out or use [] to open 
%                       a file selection dialog
%       s             : Initial constant surface elevation, 
%                       optional, default s=0
%
%   The quality of the mesh is measured in three different ways:
%    1) Simulation timestep (dt) based on a CFL condition (sqrt(g*h)).
%       Using this measure, the user can decrease simulation runtime, often
%       by only editing a few number of elements, significant amount of
%       time is saved.
%    2) Smallest angle of elements. Elements with small angles give more
%       inaccurate results and should be avoided.
%    3) Smallest area of elements. Small elements close to larger elements
%       can give more inaccurate results
%
%   Note that the plot title contains status information of the current
%   edit mode, and current quality measure values. 3 values of the current
%   quality measure are presented on the form
%
%       smallest [1 5 20]th dt : [3.35  3.74  4.74]s  (original 2.37s)
%
%   By pressing 'p' the values in percentage are shown on the form
%
%       smallest [1 5 20]th dt: [70.7 63.2 49.9]% of original 2.37s
%
%   This means that the original minimum dt before editing the mesh was
%   2.37, and the current worse, 5th worse and 20th worse dt is 3.35, 3.74,
%   and 4.74 respectively, which is  70.7, 63.2 or 49.9 percent of the
%   original minimum time step. If correcting the 4 (or 19) worse elements
%   of the current mesh, the minimum dt increases from 3.35 to 3.74 (or
%   4.74). When the difference between the three values in the vector is
%   small, further modifications will only have a minor effect on
%   simulation time.
%
%   The dt calculated here relate closely to the dt that is used in the
%   MikeZero engines. This dt is only static and does not add effect of
%   current speed on the dt limitations.
%
%   You can zoom in to the "bad" elements and manually edit the mesh.
%    1) Collapse a face: Select a face, and the two end-nodes of the face
%       is collapsed to one node at the center of the face.
%    2) Collapse an element: Select an element, and the element nodes are
%       collapsed to one node at the center of the element.
%    3) Create a quad from two neighbouring triangles, by deleting the face
%       in between the two.
%    4) Delete a node: Mesh is updated accordingly. 
%    5) Mode a node
%    6) Add a node
%   Whenever editing the mesh, it is the users responsibility that the mesh
%   is still valid and is a good quality mesh. With this tool you can
%   modify the mesh such that it is no longer valid for simulations, or
%   will give inaccurate results.
%
%   In the plot there are 3 different indicators on bad elements, when
%   the measure is dt.
%    1) A mark at one node indicates that the position/existence of this
%       node limits the timestep. The node is a candidate for being
%       moved/deleted.
%    2) A mark on a face (and its end-nodes) indicate that the
%       length/existence of this face limits the timestep. The face is a
%       candidate for a collapse.
%    3) A mark at the center of the element indicates that no special
%       features where found that limits the timestep, apart from the size
%       of the element and its total water depth. You may try to collapse
%       the element.
%
%   Several shortcuts can be used (when focus is on the mesh figure)
%
%   Keys controlling zoom
%       'g' : Global view 
%       'v' : Zoom to worse element
%       'b' : Zoom toggling between the 20 worse elements
%       'i' : Zoom in  (not global view)
%       'o' : Zoom out (not global view)
%
%   Keys controlling measure
%       '1' : Use dt as measure
%       '2' : Use smallest angle as measure
%       '3' : Use element area as measure
%       'p' : Toggle between absolute measure and percentage of original
%
%   Keys controlling edit mode
%       'f' : Collapse face
%       'e' : Collapse element
%       'q' : Create quad from two triangles sharing a face
%       'd' : Delete node
%       'm' : Move node
%       'a' : Add node
%       'z' : Undo last action (at most 10 actions can be undone)
%       's' : Save mesh using new file name (modXX_originalfilename)
%
%   Other keys
%       'h' : Print help text to Matlab console
%       'y' : Plot histograms of mesh properties
%       'c' : Toggle color/black-white mesh (color is less performant)
%
%   Note: If using the figure toolbar, e.g., for zooming, you need to
%   unselect the tool on the toolbar before the shortcuts will work again. 
%
%   Due to performance issues in the Matlab plotting routines, for larger
%   meshes, only a fraction of the internal elements are plotted. All
%   element on the boundary are plotted. Also all "bad" elements and their
%   neighbours are plotted.
%
%   Based on the concepts and initial analysis code presented in Lambkin,
%   D.O. (2007) 'Optimising mesh design in MIKE FM'. DHI website and In:
%   Dix, J.K., Lambkin, D.O. and Cazenave, P.W. (2008) 'Development of a
%   Regional Sediment Mobility Model for Submerged Archaeological Sites'.
%   English Heritage ALSF project  5224.

%   Copyright, DHI, 2007-11-09. Author: JGR

disp('Keys controlling zoom');
disp('    ''g'' : Global view ');
disp('    ''v'' : Zoom to worse element');
disp('    ''b'' : Zoom toggling between the 20 worse elements');
disp('    ''i'' : Zoom in');
disp('    ''o'' : Zoom out');
disp('Keys controlling measure');
disp('    ''1'' : Use dt as measure');
disp('    ''2'' : Use smallest angle as measure');
disp('    ''3'' : Use element area as measure');
disp('    ''p'' : Toggle between absolute measure and percentage of original');
disp('Keys controlling edit mode');
disp('    ''f'' : Collapse face');
disp('    ''e'' : Collapse element');
disp('    ''q'' : Create quad from two triangles sharing a face');
disp('    ''d'' : Delete node');
disp('    ''m'' : Move node');
disp('    ''a'' : Add node');
disp('    ''z'' : Undo last action (at most 10 actions can be undone)');
disp('Other keys');
disp('    ''s'' : Save mesh using new file name (modXX-originalfilename)');
disp('    ''y'' : Plot histograms of mesh properties');
disp('    ''c'' : Toggle color/black-white mesh (color is less performant)');
disp('Press ''h'' or write ''help mzMeshAnalyse'' for a detailed description');


if (nargin==0)
  filepathname = [];
end
if (nargin < 2)
  s = 0;
else
  if ischar(s)
    s = str2double(s);
  end
end

if (isempty(filepathname))
  [filename,filepath] = uigetfile('*.mesh','Select the .mesh file to analyse');
elseif (ischar(filepathname))
  filepath = '';
  filename = filepathname;
else
 error('mzTool:mzMeshAnalyse:fileNameTypeError',...
  'File name must be a character array');
end

[Elmts,Nodes,Proj] = mzReadMesh([filepath,filename]);

% Calculate mesh properties
[area,face_lengths,angles,dt] = mzMeshProperties(Elmts,Nodes,s);

F = figure(42);
set(F,'Units','normalized','Position',[0.05,0.10,0.90,0.80])

%% Setup global gui data
data.filepath        = filepath;    % Path to file
data.filename        = filename;    % File name
data.Elmts           = Elmts;       % Elements in file
data.Nodes           = Nodes;       % Nodes in file
data.surfaceelev     = s;           % Initial surface elevation 
data.Proj            = Proj;        % Projection string of file
data.editmode        = 'movenode';  % Current edit mode
data.editconfirm     = 0;           % Set when an edition is ongoing and need confirmation
data.changes         = 0;           % Count the number of changes since last save
data.analysemode     = 'dt';        % Current analyse mode
data.measure         = dt;          % Array of all measures (sorted) 
data.measurerelative = 1;           % Whether to show measure relative (percentage) or absolute
data.min_dt          = min(dt);     % Original minimum measure values
data.min_area        = min(area);
data.min_angle       = min(angles(:));
data.zoomfactor      = 5;           % Zoom factor when zooming on bad element
data.zoomlength      = 0;           % Zoom length used for last zoom action
data.paxis           = [];          % Axis of plot
data.bad_no          = 0;           % 0-20, which "bad" element to zoom on
data.selectednodes   = {};          % List of selected nodes (highlighted)
data.selectedelmts   = {};          % List of selected elements
data.undos           = {};          % Number of undo data, at most 10.
data.meshcolor       = 1;           % Whether to use color while plotting mesh
                                    %  - faster gui if not using colors
guidata(F,data);

set(F,'tag','mzMeshAnalyseFigure');
set(F,'KeyPressFcn',{@mzMeshAnalyseAction,F});
set(F,'WindowButtonDownFcn',{@mzMeshAnalyseAction,F});

% Setup event to draw first plot
eventdata           = struct;
eventdata.Character = 'g';
eventdata.Modifier  = cell(1,0);
eventdata.Key       = 'g';

mzMeshAnalyseAction(F,eventdata,F);


