function [obs, mesg] = ReadPointSets(inputdir, filename)
  % File with point sets is read

  function [instri, targeti] = splitobs(str)
    els = textscan(line,'%s');
    els = els{1,1};
    instri = els{1,1};
    targeti = els{2,1};
  end
  
  mesg = {};
  obsfile = fullfile(inputdir, filename);
  fid = fopen(obsfile, 'r');
  if fid==-1
    mesg = {'*** Error: file "obs.txt" could not be opened'};
    obs = {};
  else
    i = 0;
    while ~feof(fid) % feof(fid) is true when the file ends
      line = fgetl(fid); % read one line
      if ~isempty(line)
        firstword = getspl(line, 1);
        firstch = firstword(1);
        if ~strcmp(firstch, ';')
          i = i + 1;
          [instri, targeti] = splitobs(line);
          instr{i,1} = instri;
          target{i,1} = targeti;
        end
      end
    end
    if exist('instr','var')
      if size(instr{1,1},1)>0
        obs = {instr, target};
      else
        obs = {};
      end
    else
      obs = {};
    end
    fclose(fid);
  end
end