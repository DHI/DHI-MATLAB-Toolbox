function  mzWritePFS(filename,pfs)
%MZWRITEPFS  Write PFS structure to file
%
%   Writes a PFS structure to a PFS type file
%
%   Usage:
%       mzWritePFS(filename,pfs)
%
%   See MZWRITEPFS for a description of the input PFS structure
%
%   See also MZWRITEPFS

% Copyright, DHI, 2008-09-15. Author: JGR

fid    = fopen(filename,'wt');
if (fid == -1)
  error(id('fileWriteAccessDenied'),...
        'File can not be opened for writing: %s\n',filename);
end


WriteComments(fid,pfs.Comments,0)
% Write a modification date comment to the file
dvec = datevec(now);
dvec(6) = floor(dvec(6)); % Floor seconds
fprintf(fid,'// Matlab wrote: %04i-%02i-%02i %02i:%02i:%02i\n',dvec);
fprintf(fid,'\n');

WriteSections(fid,pfs.Sections,0);

fclose(fid);
  

end

function WriteSections(fid,subsections,indent)
  sectionnames = fieldnames(subsections);   % All section names
  for i = 1:numel(sectionnames)
    sectionname = sectionnames{i};          % A section name
    sections = subsections.(sectionname);   % sections is a cell array
    for j = 1:numel(sections)
      WriteSection(fid,sections{j},indent);
    end
  end
end

function WriteSection(fid,section,indent)
  indentstring = createIndentString(indent);
  fprintf(fid,'%s[%s]\n',indentstring,section.Name);

  WriteComments(fid,section.Comments,indent+1);
  WriteKeyVals(fid,section.Keys,indent+1);
  WriteSections(fid,section.Sections,indent+1);
  
  fprintf(fid,'%sEndSect  // %s\n\n',indentstring,section.Name);
end

function WriteComments(fid,comments,indent)
  indentstring = createIndentString(indent);
  for comment = comments
    fprintf(fid,'%s//%s\n',indentstring,comment{1});
  end
end

function WriteKeyVals(fid,keyvals,indent)
  keys = fieldnames(keyvals);                % All key names
  indentstring = createIndentString(indent);
  for i = 1:numel(keys)
    key = keys{i};                           % A key name
    vals = keyvals.(key);                    % vals is a cell array
    for j = 1:numel(vals)
      fprintf(fid,'%s%s = %s\n',indentstring,key,vals{j});
    end
  end
end

function indentstring = createIndentString(indent)
  indentstring = repmat('   ',[1,indent]);
end

function str = id(str)
  str = ['mzTool:mzWritePFS:' str];
end
