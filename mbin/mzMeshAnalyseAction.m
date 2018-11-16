function mzMeshAnalyseAction(src,eventdata,F)
%MZMESHANALYSEACTION Used by mzMeshAnalyse
%
%   Do not call this function directly
%

% Copyright, DHI, 2007-11-09. Author: JGR
%
% Based on the concepts and initial analysis code presented in Lambkin,
% D.O. (2007) 'Optimising mesh design in MIKE FM'. DHI website and In: Dix,
% J.K., Lambkin, D.O. and Cazenave, P.W. (2008) 'Development of a Regional
% Sediment Mobility Model for Submerged Archaeological Sites'. English
% Heritage ALSF project  5224.

if (src ~= F)
  return
end

% Set to 1 if replot is needed
replot  = 0;
% Set to 1 if repositioning is needed
repos   = 0;
% Set to 1 if mesh has been changed
changed = 0;

data  = guidata(F);
Elmts = data.Elmts;
Nodes = data.Nodes;
if (size(Elmts,2) == 3)
  hasquads = false;
  quads    = false(size(Elmts,1),1);
else
  hasquads = true;
  quads    = Elmts(:,4) > 0;
end

statustext = '';

%% Key input - change mode
if (numel(eventdata) > 0)

  s = eventdata.Character;
  k = eventdata.Key;

  % exit on certain keys
  if (strcmp(k,'alt') || strcmp(k,'control'))
    return
  end
  
  switch (lower(s))
    
    % face collapse
    case 'f'
      data.editmode = 'collapseface';

    % element collapse
    case 'e'
      data.editmode = 'collapseelmt';

    % element collapse
    case 'q'
      data.editmode = 'quadfromtriface';

    % Delete node
    case 'd'
      data.editmode = 'deletenode';

    % Move node
    case 'm'
      data.editmode = 'movenode';
      
    % Add a node
    case 'a'
      data.editmode = 'addnode';

    % Undo last change
    case 'z'
      if (numel(data.undos) > 0)
        undodata = data.undos{end};
        Elmts    = undodata.Elmts;
        Nodes    = undodata.Nodes;
        meas     = undodata.Measure;
        data.undos(end) = [];
        data.Elmts      = Elmts;
        data.Nodes      = Nodes;
        data.Measure    = meas;
        data.changes    = data.changes-1;
        if (size(Elmts,2) == 3)
          hasquads = false;
          quads    = false(size(Elmts,1),1);
        else
          hasquads = true;
          quads    = Elmts(:,4) > 0;
        end
        replot = 1;
      else
        statustext = 'No more undo data available';
      end

    % Save file
    case 's'
      [Elmts,Nodes] = mzReorderMesh(Elmts,Nodes);
      changed = 1;
      replot  = 1;
      for i = 1:99
        filepathname = [data.filepath 'mod' sprintf('%02i',i) '-' data.filename];
        if (~exist(filepathname,'file') || i == 99)
          mzWriteMesh(filepathname,Elmts,Nodes,data.Proj);
          statustext = ['Saved file as: ' filepathname];
          statustext = strrep(statustext,'\','\\');
          statustext = strrep(statustext,'_','\_');
          break;
        end
      end
      
    % Global view
    case 'g'
      data.bad_no = 0;
      data.paxis = [];
      repos  = 1;
      replot = 1;
    
    case 'v'
    % Center on worse element
      data.bad_no = 1;
      data.zoomfactor = 5;
      repos  = 1;
      replot = 1;

    % Center on next bad element
    case 'b'
      data.bad_no = data.bad_no + 1;
      if (data.bad_no > length(data.measure))
        data.bad_no = 1;
      end
      data.zoomfactor = 5;
      repos  = 1;
      replot = 1;
    
    % Zoom in
    case 'i'
      data.zoomfactor = data.zoomfactor*(2/3);
      repos  = 1;
      replot = 1;
    % Zoom in
    case 'o'
      data.zoomfactor = data.zoomfactor*(3/2);
      repos  = 1;
      replot = 1;

      
    % dt mode
    case '1'
      data.analysemode = 'dt';
      replot = 1;

    % Min angle mode
    case '2'
      data.analysemode = 'angle';
      replot = 1;
      
    % Min area mode
    case '3'
      data.analysemode = 'area';
      replot = 1;

    % Relative (percentage) or absolute measure values
    case 'p'
      data.measurerelative = ~data.measurerelative;
      
    % Print help text
    case 'h'
      if (exist('mzMeshAnalyseHelp.txt','file'))
        fid = fopen('mzMeshAnalyseHelp.txt');
        while 1
          tline = fgetl(fid);
          if ~ischar(tline), break, end
          fprintf('%s\n',tline);
        end
        fclose(fid);
        statustext = 'Help printed to the Matlab console';
      else
        statustext = 'Help file could not be found';
      end 
      
    % Make histograms
    case 'y'
      [area,face_lengths,angles,dt] = mzMeshProperties(Elmts,Nodes,data.surfaceelev);
      mzMeshPropertiesHist(area,face_lengths,angles,dt);
      return;
      %statustext = 'Histogram plot opened in new window';
 
    % Make histograms
    case 'c'
      data.meshcolor = ~data.meshcolor;
      replot = 1;
      
  end
  if (data.editconfirm == 1)
    replot = 1;
  end
  data.editconfirm = 0;
  data.selectednodes = {};
      

%% Mouse input - edit mesh
% Each action here should set
%    data.selectednodes
%    data.editconfirm
%    replot = 1 - optional, only if replot is needed.
else
  
  % Get mouse position
  pt = get(gca,'currentpoint');
  % Mouse coordinages
  x  = pt(1,1);
  y  = pt(1,2);
  X  = Nodes(:,1);
  Y  = Nodes(:,2);
  
  switch(data.editmode)
    
    case 'collapseface'
      % Find node pairs closest to mouse click
      % All unique face node pairs
      FN =     Elmts(:,[1,2]);
      FN = [FN;Elmts(:,[2,3])];
      if (~hasquads)
        FN = [FN;Elmts(:,[3,1])];
      else
        FN = [FN;Elmts(~quads,[3,1])];
        FN = [FN;Elmts(quads,[3,4])];
        FN = [FN;Elmts(quads,[4,1])];
      end
      FN = sort(FN,2);
      FN = unique(FN,'rows');
      % Face center coordinates
      FX = 0.5*sum(X(FN),2);
      FY = 0.5*sum(Y(FN),2);
      % Minimum distance
      [dist,fn] = min((FX-x).^2+(FY-y).^2);
      % Length of face (squared)
      facelen = (X(FN(fn,1)) - X(FN(fn,2)))^2 + (Y(FN(fn,1)) - Y(FN(fn,2)))^2;
      % The two nodes defining the face
      nn = FN(fn,:);
      if (data.editconfirm == 0)
        % First click, find closest face
        % If (xn,yn) is "to far away", do nothing
        if (dist > 0.25*facelen)
          statustext = 'No face nearby/uniquely to select';
        else
          data.selectednodes        = {};
          data.selectednodes{end+1} = nn;
          data.editconfirm          = 1;
        end
      else
        % Second click, confirm collaps
        if (numel(data.selectednodes) > 0)
          sn            = data.selectednodes{1};
          if (sn==nn)
            [Elmts,Nodes] = mzMeshCollapseFace(Elmts,Nodes,nn(1),nn(2));
            changed = 1;
          else
            statustext = 'Collapse cancelled';
          end
        end
        data.selectednodes = {};
        data.editconfirm   = 0;
        replot  = 1;
      end
        
    case 'quadfromtriface'
      % Find node pairs closest to mouse click
      % All unique face node pairs
      FN =     Elmts(:,[1,2]);
      FN = [FN;Elmts(:,[2,3])];
      if (~hasquads)
        FN = [FN;Elmts(:,[3,1])];
      else
        FN = [FN;Elmts(~quads,[3,1])];
        FN = [FN;Elmts(quads,[3,4])];
        FN = [FN;Elmts(quads,[4,1])];
      end
      FN = sort(FN,2);
      FN = unique(FN,'rows');
      % Face center coordinates
      FX = 0.5*sum(X(FN),2);
      FY = 0.5*sum(Y(FN),2);
      % Minimum distance
      [dist,fn] = min((FX-x).^2+(FY-y).^2);
      % Length of face (squared)
      facelen = (X(FN(fn,1)) - X(FN(fn,2)))^2 + (Y(FN(fn,1)) - Y(FN(fn,2)))^2;
      % The two nodes defining the face
      nn = FN(fn,:);
      if (data.editconfirm == 0)
        % First click, find closest face
        % If (xn,yn) is "to far away", do nothing
        if (dist > 0.25*facelen)
          statustext = 'No face nearby/uniquely to select';
        else
          data.selectednodes        = {};
          data.selectednodes{end+1} = nn;
          data.editconfirm          = 1;
        end
      else
        % Second click, confirm collaps
        if (numel(data.selectednodes) > 0)
          sn            = data.selectednodes{1};
          if (sn==nn)
            [Elmts,Nodes,err] = mzMeshQuadFromTriFace(Elmts,Nodes,nn(1),nn(2));
            if (err == 1)
              statustext = 'Only one element using this face, quad creation cancelled';
            elseif (err == 2)
              statustext = 'Elements using this face are not all triangels, quad creation cancelled';
            else
              changed = 1;
            end
          else
            statustext = 'Quad creation cancelled';
          end
        end
        data.selectednodes = {};
        data.editconfirm   = 0;
        replot  = 1;
      end
      
    case 'collapseelmt'
      e = elmtsearch(X,Y,Elmts,x,y);

      if (data.editconfirm == 0)
        % First click, find element

        if (isnan(e))
          statustext = 'No element to select';
        else
          sn  = Elmts(e,[1 2 3 1]);
          if (quads(e))
            sn  = Elmts(e,[1 2 3 4 1]);
          end
          data.selectedelmts        = {};
          data.selectedelmts{end+1} = e;
          data.selectednodes        = {};
          data.selectednodes{end+1} = sn;
          data.editconfirm          = 1;
        end
      else
        % Second click, confirm collaps
        if (numel(data.selectedelmts) > 0)
          se = data.selectedelmts{1};
          if (se==e)
            [Elmts,Nodes] = mzMeshCollapseElement(Elmts,Nodes,e);
            changed = 1;
          else
            statustext = 'Collapse cancelled';
          end
        end
        data.selectedelmts = {};
        data.selectednodes = {};
        data.editconfirm   = 0;
        replot  = 1;
      end
        
      
    case 'movenode'
      if (data.editconfirm == 0)
        % First click, find closest node
        [dist,nn] = min((X-x).^2+(Y-y).^2);
        %dist      = sqrt(dist);
        data.selectednodes{end+1} = nn;
        data.editconfirm          = 1;
      else
        % Second click, new position
        if (numel(data.selectednodes) > 0)
          sn            = data.selectednodes{1};
          [Elmts,Nodes] = mzMeshMoveNode(Elmts,Nodes,sn(end),x,y);
          changed = 1;
        end
        data.selectednodes = {};
        data.editconfirm   = 0;
        replot = 1;
      end

    case 'deletenode'
      if (data.editconfirm == 0)
        % First click, find closest node
        [dist,nn] = min((X-x).^2+(Y-y).^2);
        %dist      = sqrt(dist);
        data.selectednodes        = {};
        data.selectednodes{end+1} = nn;
        data.editconfirm          = 1;
      else
        % Second click, confirm node
        if (numel(data.selectednodes) > 0)
          % Find closest node
          [dist,nn] = min((X-x).^2+(Y-y).^2);
          sn            = data.selectednodes{1};
          if (nn == sn(end))
            [Elmts,Nodes] = mzMeshDeleteNode(Elmts,Nodes,nn);
            changed = 1;
          else
            statustext = 'Delete node cancelled';
          end
        end
        data.selectednodes = {};
        data.editconfirm   = 0;
        replot = 1;
      end

    case 'addnode'
      [Elmts,Nodes,err]         = mzMeshAddNode(Elmts,Nodes,x,y,1);
      if (~err)
        data.selectednodes{end+1} = size(Nodes,1);
        data.editconfirm          = 0;
        changed = 1;
        replot = 1;
      else
        statustext = 'Node could not be added here';
      end
      
  end
  
end

%% If mesh changed, update undo information
if (changed)
  undodata          = struct;
  undodata.Elmts    = data.Elmts;
  undodata.Nodes    = data.Nodes;
  undodata.Measure  = data.measure;
  data.undos{end+1} = undodata;
  % Only save the last 10 undos
  for i = 11:numel(data.undos);
    data.undos(1) = [];
  end
  data.changes = data.changes+1;
  % Reset b counter
  data.bad_no  = 0;
  if (size(Elmts,2) == 3)
    hasquads = false;
    quads    = false(size(Elmts,1),1);
  else
    hasquads = true;
    quads    = Elmts(:,4) > 0;
  end
end


%% Do all the plotting
F = figure(42);

X  = Nodes(:,1);
Y  = Nodes(:,2);

% If coloring mesh (using patch and not plot in mzMeshAnalysePlot), always replot
if (data.meshcolor || replot)
%if (replot)

  % Recalculate mesh properties
  [area,face_lengths,angles,dt] = mzMeshProperties(Elmts,Nodes,data.surfaceelev);

  % Select which to analyse
  switch (data.analysemode)
    case 'dt'
      meas = dt;
    case 'angle'
      meas = min(angles(:,1:3),[],2);
      if (hasquads)
        meas(quads) = min(meas(quads),angles(quads,4));
      end
    case 'area'
      meas = area;
    otherwise
      meas = zeros(size(area));
  end
  % Sort the measure
  [meas,bad_E] = sort(meas);
  % Take out the top 20 of bad elements
  bad_e_max = min(20,length(bad_E));
  bad_E = bad_E((1:bad_e_max)');

  % Find all nodes that are used by elements in E
  N = Elmts(bad_E,:);
  N = unique(N(:));
  % Remove 0's (triangles in mixed meshes produces such)
  N(N==0) = [];
  % Find elements that use any of the nodes in N (neighbours of E)
  En = false(size(Elmts,1),1);
  for nn = N'
    En = En | (sum(Elmts==nn,2) > 0);
  end

  % Reposition plot by changing axis
  if (repos)
    if (data.bad_no == 0)
      paxis = data.paxis;
      if (numel(paxis) && data.zoomlength > 0)
        ds = data.zoomfactor*data.zoomlength;
        paxis(1) = mean(paxis(1:2)) - ds;
        paxis(2) = mean(paxis(1:2)) + ds;
        paxis(3) = mean(paxis(3:4)) - 0.8*ds;
        paxis(4) = mean(paxis(3:4)) + 0.8*ds;
      end
    else
      e     = bad_E(data.bad_no);
      I     = [1 2 3];
      if (quads(e))
        I = [1 2 3 4];
      end
      xmin = min(X(Elmts(e,I)));
      xmax = max(X(Elmts(e,I)));
      ymin = min(Y(Elmts(e,I)));
      ymax = max(Y(Elmts(e,I)));
      xc   = mean([xmin,xmax]);
      yc   = mean([ymin,ymax]);
      data.zoomlength = mean([xmax - xmin,ymax - ymin]);
      ds    = data.zoomfactor*data.zoomlength;
      paxis = [xc-ds xc+ds yc-0.8*ds yc+0.8*ds];
    end
    data.paxis = paxis;
  else
    paxis = axis;
    data.paxis = paxis;
  end

  % Plot main mesh
  mzMeshAnalysePlot(paxis,Elmts,Nodes,3000,En,data.meshcolor);
  if (data.meshcolor)
    colorbar;
  end

  % Plot bad element details
  hold on
  % Fill bad elements in special colors
  for eno = bad_e_max:-1:1
    pl = 0.6;
    if (eno > 5), ps = [pl pl 1]; elseif (eno > 1), ps = [pl 1 pl]; else ps = [1 pl pl]; end
    e  = bad_E(eno);
    if (quads(e))
      I = [1 2 3 4 1];
    else
      I = [1 2 3 1];
    end
    ni = Elmts(e,I);
    fill(X(ni),Y(ni),ps);
  end
  % Highlight the element in focus
  if (data.bad_no > 0)
    e  = bad_E(data.bad_no);
    if (quads(e))
      d = Elmts(e,[1 2 3 4 1])';
    else
      d = Elmts(e,[1 2 3 1])';
    end
    plot(X(d),Y(d),'k','LineWidth',3);
  end
  % Highlight bad node(s) of bad elements
  for eno = bad_e_max:-1:1
    if (eno > 5), ps = 'b-o'; elseif (eno > 1), ps = 'g-o'; else ps = 'r-o'; end
    e          = bad_E(eno);
    [fls,flsi] = sort(face_lengths(e,:),'descend');
    if (~quads(e))
      % Try to find a sinner for the bad measure
      if ((fls(1)-fls(3))/fls(1) < 0.25)
        % The element is very nicely shaped, not a specific node/face is bad
        xe = mean(X(Elmts(e,1:3)));
        ye = mean(Y(Elmts(e,1:3)));
        plot(xe,ye,ps,'LineWidt',4,'MarkerSize',15);
      elseif ((fls(1)-fls(2))/fls(2) > 0.1)
        % The opposing node of the longest face is the sinner.
        [fl,fli] = max(face_lengths(e,1:3));
        ni       = Elmts(e,mod(fli+1,3)+1);
        plot(X(ni),Y(ni),ps,'LineWidt',4,'MarkerSize',15);
      else
        % The shortest face is the sinner.
        [fl,fli] = min(face_lengths(e,1:3));
        ni       = Elmts(e,[fli,mod(fli,3)+1]);
        plot(X(ni),Y(ni),ps,'LineWidt',4,'MarkerSize',15);
      end
    else
      % For quads, always mark the shortest face
      fli      = flsi(end);
      ni       = Elmts(e,[fli,mod(fli,4)+1]);
      plot(X(ni),Y(ni),ps,'LineWidt',4,'MarkerSize',15);
    end
  end
  hold off

  % save measure for later use
  data.measure = meas;
else
  % load measure from last replot
  meas = data.measure;
end

%% Additional plotting
hold on
% Plot selected nodes.
for i = 1:length(data.selectednodes)
  NN = data.selectednodes{i};
  plot(X(NN),Y(NN),'c-o','LineWidt',4,'MarkerSize',15);
end
hold off

%% Create title text
titletext = '';
switch (data.editmode)
  case 'collapseface'
    if (data.editconfirm == 0)
      titletext = 'Mode: Collapse face (select a face)';
    else
      titletext = 'confirm collapse by selecting face again (f to cancel)';
    end
  case 'collapseelmt'
    if (data.editconfirm == 0)
      titletext = 'Mode: Collapse element (select an element)';
    else
      titletext = 'confirm collapse by selecting element again (e to cancel)';
    end
  case 'quadfromtriface'
    if (data.editconfirm == 0)
      titletext = 'Mode: Create quad from two triangels (select a face)';
    else
      titletext = 'confirm quad creation by selecting face again (q to cancel)';
    end
  case 'movenode'
    if (data.editconfirm == 0)
      titletext = 'Mode: Move Node (select a node)';
    else
      titletext = 'Select new position for Node (m to cancel)';
    end
  case 'deletenode'
    if (data.editconfirm == 0)
      titletext = 'Mode: Delete Node (select a node)';
    else
      titletext = 'confirm deletion by selecting node again (d to cancel)';
    end
  case 'addnode'
    titletext = 'Mode: Add Node (select a position for node)';
end

% Print worse original measure
switch (data.analysemode)
  case 'dt'
    min_ori = data.min_dt;
    unit    = 's';
  case 'angle'
    min_ori = data.min_angle;
    unit    = 'deg';
  case 'area'
    min_ori = data.min_area;
    unit    = 'm^2';
  otherwise
    min_ori = 0;
end
outs = [1,2,5,20];
if (length(meas)<20)
  outs = [1,2,5];
end
if (length(meas)<5)
  outs = [1,2];
end
if (data.measurerelative)
  resulttext = [ 'smallest [1 2 5 20]^{th} ' data.analysemode ' : [ ' sprintf('%4.1f  ',100*min_ori./meas(outs)) ']%  of original ' sprintf('%5.2f',min_ori) ' ' unit];
else
  resulttext = [ 'smallest [1 2 5 20]^{th} ' data.analysemode ' : [ ' sprintf('%5.2f  ',meas(outs)) ']' unit ' (original ' sprintf('%5.2f',min_ori) ' ' unit ')'];
end

if (~isempty(resulttext))
  titletext = [titletext sprintf('\n') resulttext];
end
title(titletext,'FontSize',15);

if (isempty(statustext))
  statustext = sprintf('Number of changes = %i',data.changes);
end
xlabel(statustext,'FontSize',15);

ylabel(sprintf('#nodes = %i, #elements = %i',size(Nodes,1),size(Elmts,1)),'FontSize',15);

%% Save data again
data.Elmts = Elmts;
data.Nodes = Nodes;

guidata(F,data);

