function txtfilechange(filename, nwline, linenr)
% Replaces line number "linenr" of textfile "filenam" with nwline
% It is used to replace the networkname of a PRJ-file
% by a more specific name, including epoch number and
% type of analysis
%# read the whole file to a temporary cell array:
fid = fopen(filename,'rt');
tmp = textscan(fid,'%s','Delimiter','\n');
fclose(fid);
%# replace line "linenr":
tmp = tmp{1};
tmp{linenr}=nwline;

fid = fopen(filename, 'w');
nres=size(tmp,1);
for i=1:nres
  text = tmp{i,1};
  fprintf(fid, '%s\r\n',text);
end %for
fclose(fid);
