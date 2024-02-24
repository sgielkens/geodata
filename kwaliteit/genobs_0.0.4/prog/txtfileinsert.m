function txtfileinsert(filename, nwline, linenr)
% Inserts a line after line number "linenr" of textfile "filenam"
% It is used to insert the point names of the S-base in a PRJ-file
%# read the whole file to a temporary cell array:
fid = fopen(filename,'rt');
tmp = textscan(fid,'%s','Delimiter','\n');
fclose(fid);
% Move all lines one line down from "linenr"+1 onwards.
%# replace line "linenr":
tmp = tmp{1};
nres=size(tmp,1);
for ln = nres+1:-1:linenr+1
  tmp{ln,1} = tmp{ln-1,1};
end
tmp{linenr}=nwline;

fid = fopen(filename, 'w');
for i=1:nres+1
  text = tmp{i,1};
  fprintf(fid, '%s\r\n',text);
end %for
fclose(fid);
