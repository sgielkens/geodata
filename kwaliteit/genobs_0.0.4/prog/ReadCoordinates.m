function [crd, dim, mesg, stop] = ReadCoordinates(inputdir, filename, dim)
  crd = {};
  mesg = {};
  stop = false;
  coordfile = fullfile(inputdir, filename);
  fid = fopen(coordfile,'r');
  if fid==-1
    mesg = {'*** Error: file "coord.txt" could not be opened'};
    crd = {};
    dim = -1;
  else
    if dim == -1
        % If dim > -1, dim was entered by the user in the ini-file,
        % there is no need to determine it from "coord.txt".
        % If dim == -1, determine dim from the number of columns 
        % in "coord.txt". If getdim fails, dim remains -1.
        dim = getdim(fid); 
        frewind(fid);
    end
    if dim<0
      crd = {};
      mesg = {['*** Warning: no valid points with coordinates '];
              ['             were found in "coord.txt"        ']};
    else
      if dim==1 || dim==2 || dim==3
        ncol = dim;
        if ncol == 1
          ncol = 3;
        end
        for xyz=1:ncol
          crd_empty{xyz,1} = true;
        end
        i = 0;
        while ~feof(fid) % feof(fid) is true when the file ends
          % read one line
          line = fgetl(fid);
          % remove leading and trailing spaces and tabs
          line = strtrim(line);
          % check whether line is empty, or contains only spaces and tabs
          if ~isempty(line)
            firstword = getspl(line, 1);
            firstch = firstword(1);
            if ~strcmp(firstch, ';')
              % line is not a comment line (starts with ;)
              % split line in its elements separate "words"
              [pnt, notused, code] = splitstr(line);
              if code == 0
                % code == 0, that is: splitstr has delivered a 
                % point name, and also a x, y and possibly z coordinate.
                % Therefore, a point can be added to crd, and variable "i"
                % can be raised by 1.
                i = i + 1;
                ptnm{i,1} = pnt{1,1};
                % xyz is 1, 2 or 3 for x, y or z
                for xyz=1:ncol
                  if crd_empty{xyz,1}
                    pntcrd{xyz} = str2num(pnt{xyz+1,1});
                    crd_empty{xyz,1} = false;
                  else
                    pntcrd{xyz} = [pntcrd{xyz}; str2num(pnt{xyz+1,1})];
                  end
                end
              end
            end
          end
        end
      else
        mesg = {['*** Error: dimension parameter is wrong: dim = ', num2str(dim)]};
        stop = true;
      end % if dim==1 etc.
      if ~stop
        crd = {ptnm};
        for xyz=1:ncol
          crd{1, xyz+1} = pntcrd{xyz};
        end
      end % ~stop
    end % if dim<0
    fclose(fid);
  end
 end