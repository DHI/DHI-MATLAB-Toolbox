function mzMeshPropertiesHist(area,face_lengths,angles,dt)
%MZMESHPROPERTIESHIST  Histograms of mesh properties
%
%   Used by mzMeshAnalyse, input arguments from mzMeshProperties.

% Copyright, DHI, 2007-11-09. Author: JGR

F = figure(43);
nbins = 100;
nsubs = 4;
isub  = 1;

% Find quads
if (size(face_lengths,2) == 3)
  hasquads = false;
  quads    = false(size(face_lengths,1),1);
else
  hasquads = true;
  quads    = face_lengths(:,4) > 0;
end

% Calculate minimum of face lengths and angles
min_length = min(face_lengths(:,1:3),[],2);
min_angle  = min(angles(:,1:3),[],2);
if (hasquads)
  min_length(quads) = min(min_length(quads),face_lengths(quads,4));
  min_angle(quads)  = min(min_angle(quads) ,angles(quads,4));
end

%% Timestep
subplot(1,nsubs,isub); isub = isub+1;
%e = linspace(0,max(dt),nbins+1);
e  = linspace(0,3*mean(dt),nbins+1);
Nt = histc(dt(~quads),e);
if (hasquads)
  Nq = histc(dt(quads),e);
else
  Nq = zeros(size(Nt));
end
N  = [Nt,Nq]; 
h  = bar(e,N,'stacked');
setStyle(h);
axis tight
title('Timestep, dt (s)');
xlabel(sprintf('(min,max) = (%4.2f,%4.2f)',min(dt),max(dt)));


%% Internal angles
subplot(1,nsubs,isub); isub = isub+1;
if (hasquads)
  e = 0:1:95;
else
  e = 0:1:65;
end
Nt = histc(min_angle(~quads),e);
if (hasquads)
  Nq = histc(min_angle(quads),e);
else
  Nq = zeros(size(Nt));
end
N  = [Nt,Nq]; 
h  = bar(e,N,'stacked');
setStyle(h);
axis tight
title('Smallest internal angle (degrees)');
xlabel(sprintf('(min,max) = (%3.1f,%3.1f)',min(min_angle),max(min_angle)));


%% Element side lengths
subplot(1,nsubs,isub); isub = isub+1;
e = linspace(0,max(min_length),nbins+1);
Nt = histc(min_length(~quads),e);
if (hasquads)
  Nq = histc(min_length(quads),e);
else
  Nq = zeros(size(Nt));
end
N  = [Nt,Nq]; 
h  = bar(e,N,'stacked');
setStyle(h);
axis tight
title('element side (m)');
xlabel(sprintf('(min,max) = (%4.1f,%4.1f)',min(min_length),max(min_length)));


%% Element areas
subplot(1,nsubs,isub); isub = isub+1;
%e = linspace(0,max(area),nbins+1);
e  = linspace(0,3*mean(area),nbins+1);
Nt = histc(area(~quads),e);
if (hasquads)
  Nq = histc(area(quads),e);
else
  Nq = zeros(size(Nt));
end
N  = [Nt,Nq];
h  = bar(e,N,'stacked');
setStyle(h);
axis tight
title('Element area (m^2)');
%xlabel(sprintf('(min,max) = (%5.2f,%5.2f)',min(area),max(area)));
xlabel(sprintf('min = %5.2f',min(area)));

%% Global figure properties

subplot(1,nsubs,1)
ylabel(sprintf('Number of elements (total=%i)\n blue = triangels, green = quads',length(dt)),'fontsize',15);

set(figure(F),'Units','normalized','Position',[0.03,0.4,0.90,0.4])


function setStyle(h)
col{1} = 'b';
col{2} = 'g';
set(h(1),'edgecolor',col{1},'facecolor',col{1});
set(h(2),'edgecolor',col{2},'facecolor',col{2});
% set(h(1),'edgecolor',col{1},'facecolor',col{1},'linestyle','none');
% set(h(2),'edgecolor',col{2},'facecolor',col{2},'linestyle','none');
