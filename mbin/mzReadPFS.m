function pfs = mzReadPFS(filename)
%MZREADPFS  Reads PFS type file to pfs structure
%
%   Reads a PFS type file and saves result into a PFS structure that
%   follows the structure of the file closely
%
%   Usage:
%       pfs = mzReadPFS(filename)
%
%   Outputs:
%       pfs : A PFS structure, a recursive structure following tightly the
%             structure of the PFS file
%
%   A PFS structure is a recursive structure following tightly the
%   structure of the PFS file. Each structure has the following fields
%     * Name : The name of the PFS section. The outermost section
%       name is 'MainSection', and is not used in the file.
%     * Comments : If any lines start with //, they are considered a 
%       comment and stored in Comments.
%     * Sections : A struct containing named fields corresponding to
%       PFS section names. Each named field is a cell array, since there
%       can be more than one PFS section with the same name. Each element
%       of the cell array is another PFS structure (recursively)
%     * Keys : A struct containing named fields corresponding to a PFS
%       keyword. Each named field is a cell array, since there can be more
%       than one PFS node with the same keyword. Each element of the cell
%       array is a PFS keyword value.
%
%   Note that all sections and keys are struct arrays, and each element in
%   the  struct is text. The user must himself make sure to format each key
%   as text.
%
%   Loading a file on the form:
%   -----------------------------------
%   [MIKE_11_Network_editor]
%      [DATA_AREA]
%         x0 = 19001
%         y0 = 0
%         x1 = 19000
%         y1 = 12500
%         projection = 'NON-UTM'
%      EndSect  // DATA_AREA
%      [POINTS]
%         point = 1, 100, 0, 0, 0, 0
%         point = 2, 1100, 0, 0, 1000, 0
%         point = 3, 1300, 0, 0, 0, 0
%      EndSect  // POINTS
%   EndSect  // MIKE_11_Network_editor
%   -----------------------------------
%   to access the x0 coordinate in [DATA_AREA], do:
%       pfs.Sections.MIKE_11_Network_editor{1}.Sections.DATA_AREA{1}.Keys.x0{1}
%
%   to access the second point in [POINTS], do:
%       pfs.Sections.MIKE_11_Network_editor{1}.Sections.POINTS{1}.Keys.point{2}
%
%   to alter the x0 coordinate in [DATA_AREA], do: 
%       pfs.Sections.MIKE_11_Network_editor{1}.Sections.DATA_AREA{1}.Keys.x0{1} = num2str(1902);
%   or
%       pfs.Sections.MIKE_11_Network_editor{1}.Sections.DATA_AREA{1}.Keys.x0 = {num2str(1902)};
%
%   If reading a PFS file read using MZREADPFS and writing it back using
%   MZWRITEPFS, the two files will not necessarily match 100%. MZWRITEPFS
%   always writes keywords before sections, and the original file does not
%   need to obey this and can match sections and keywords. However, the
%   sections will be written in the same order as the original file, and
%   similar with the keywords.
%
%   See also MZWRITEPFS

% Copyright, DHI, 2008-09-15. Author: JGR

if (nargin == 0)
  [uifilename,uifilepath] = uigetfile('*','Select a setup (PFS) file');
  filename = [uifilepath,uifilename];
end

fid    = fopen(filename,'rt');
if fid == -1
  error(id('fileNotFound'),['Could not find file: ' filename]);
end

pfs = readSection(fid);

fclose(fid);
  

end

function line = readLine(fid)
% Read one line, skip blank lines, check for length>2, return eof when hit
  while 1
    line = fgetl(fid);
    % Check if it is a line (and not EOF)
    if ~ischar(line)
      return
    end
    % Trim leading and trailing spaces
    line = strtrim(line);
    % Check for empty line, continue with next if so
    if (isempty(line))
      continue;
    end
    % We assume each line to have at least length 3
    if (length(line) <= 2)
      error(id('ErrorInFormat'),['Error in format on line: ' tline]);
    end
    return;
  end
end

function [pfs, eofflag] = readSection(fid)
% Read an entire PFS section. Returns eofflag=true if end-of-file is met.

  pfs.Name = 'MainSection';
  pfs.Comments = {};
  pfs.Sections = struct();
  pfs.Keys = struct();
  while 1

    % Read line
    tline = readLine(fid);
    % If end-of-file - return
    if ~ischar(tline)
      eofflag = true; 
      return;
    end

    % Check if section has ended
    if strncmpi(tline,'EndSect',7)
      eofflag = false;
      return;
    end

    % Check if it is a comment
    if strncmpi(tline,'//',2)
      pfs.Comments{end+1} = tline(3:end);
      continue
    end

    % Check if new section has started
    if strncmpi(tline,'[',1)
      sectionName = tline(2:end-1);
      [pfsread, eofflag] = readSection(fid);
      pfsread.Name = sectionName;
      if (isfield(pfs.Sections,sectionName))
        pfs.Sections.(sectionName){end+1} = pfsread;
      else
        pfs.Sections.(sectionName) = {pfsread};
      end
      if (eofflag)
        return;
      end
      continue
    end

    % Try read key = value
    split = regexp(tline, '=', 'split', 'once');
    if (numel(split) ~= 2)
      error(id('ErrorInFormat'),['Error in format on line: ' tline]);
    end
    % Remove leading/trailing spaces on key and value
    key = strtrim(split{1});
    val = strtrim(split{2});
    if (isfield(pfs.Keys,key))
      pfs.Keys.(key){end+1} = val;
    else
      pfs.Keys.(key) = val;
    end

  end

end

function str = id(str)
  str = ['mzTool:mzWritePFS:' str];
end
