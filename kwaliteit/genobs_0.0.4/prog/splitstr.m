function [pnt, dim, code] = splitstr(str)
  % Used to read one line of a file "coord.txt"
  % Each line contains a point name and 2 coordinates (dimension is 2D) 
  % or 3 coordinates (dimension is 3D)
  % A line is skipped, if it:
  % - is empty;
  % - contains only spaces or tabs or both;
  % - starts with ;
  % - after the coordinates comments may be put
  % If reading of the line is successfull, "code" is put to 0, otherwise
  % it is put to 1.
  % "pnt" is a cell array:
  % - The first cell contains a cell array of point names
  % - The following two or three cells contain each one vector of coordinates, 
  %   they are the x, y and z coordinates. If dimension is 2D, no z coordinate
  %   is present.
  code = 1;
  dim = 2;
  els = textscan(str,'%s');
  pnt = els{1,1};
  len = length(pnt);
  if len > 2
    % there are at least three fields
    if isnum(pnt{2,1})
      % there is at least one coordinate
      if isnum(pnt{3,1})
        % there are at least two coordinates
        if len > 3
          % there are at least four fields
          if isnum(pnt{4,1})
            % there are three coordinates
            dim = 3;
            code = 0;
            pnt = pnt(1:4, 1);
          else 
            % there are two coordinates
            dim = 2;
            code = 0;
            pnt = pnt(1:3, 1);
          end
        else
          % there are two coordinates
          dim = 2;
          code = 0;
          pnt = pnt(1:3, 1);
        end
      else
        % there is just one coordinate
        dim = 1;
        code = 1;
        pnt = pnt(1:2);
      end
    else
      % there are just two fields
      if isnum(pnt{2,1})
        % there is just one coordinate
        dim = 1;
        code = 1;
        pnt = pnt(1:2);
      else
        % there are no coordinates
        dim = 0;
        code = 1;
        pnt = pnt(1);
      end
    end
  else
    % there are no coordinates
      dim = 0;
      code = 1;
      pnt = pnt(1);
  end
end
