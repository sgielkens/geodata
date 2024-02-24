function dim = getdim(fid)
  dim = -1;
  i = 0;
  stop = false;
  while ~feof(fid) && ~stop % feof(fid) is true when the file ends
    line = fgetl(fid); % read one line
    line = strtrim(line); % remove leading and trailing spaces and tabs
    % check whether line is empty, or contains only spaces and tabs
    if ~isempty(line)
      firstword = getspl(line, 1);
      firstch = firstword(1);
      % check whether line is a comment line (starts with ;)
      if ~strcmp(firstch, ';')
        [pnt, dim, code] = splitstr(line);
        if code == 0
          % dim has been determined by splitstr(line)
          stop = true;
        end
      end
    end
  end % while
end