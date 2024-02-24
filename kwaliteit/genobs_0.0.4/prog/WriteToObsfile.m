function WriteToObsfile(obs, dh, s0, s, alpha, beta, NetworkName, prjdir, IniData, dim)
% distances and directions are written in MOVE3-format
dimstr = [num2str(dim), 'D'];
strline = {'MOVE3 V4.2.1 OBS file'};
strline = [strline ; '$'];
strline = [strline ; NetworkName];
strline = [strline ; '$'];
strline = [strline ; 'ANGLEUNIT GON'];
strline = [strline ; '$'];

instr = obs{1,1};
instr_spc = AddSpaces(instr);
target = obs{1,2};
target_spc = AddSpaces(target);
m = size(instr, 1);
for i=1:m
  strline0 = instr_spc{i,1};
  strline1 = target_spc{i,1};
  
  if dim==1
    % Here, as an exception, MOVE3 expects a
    % value in mm and not in LINEAR UNIT

    SigmaDHA = IniData.SigmaDHA*1000;
    SigmaDHB = IniData.SigmaDHB*1000;
    SigmaDHC = IniData.SigmaDHC*1000;

    strline2   = sprintf('%16.5f',dh(i));
    strline2a  = sprintf('%16.5f',s0(i));
    s_z_fix    = sprintf('%16.4f',SigmaDHA);
    s_z_rel_B  = sprintf('%16.4f',SigmaDHB);
    s_z_rel_C  = sprintf('%16.4f',SigmaDHC);
  end
  
  if dim>1
    strline2 = sprintf('%16.5f',alpha(i));
    strline3 = sprintf('%16.4f',s(i));
    s_s_fix  = sprintf('%16.4f',IniData.sfixed);
    s_s_rel  = sprintf('%15.1f',IniData.srel);
    s_a_fix  = sprintf('%16.5f',IniData.a.fixed);
    s_a_rel  = sprintf('%15.5f',IniData.a.rel);
  end
  
  if dim==3
    strline4 = sprintf('%16.5f',beta(i));
    s_z_fix  = sprintf('%16.5f',IniData.z.fixed);
    s_z_rel  = sprintf('%15.5f',IniData.z.rel);
    zen = ['  Z0  ' strline4 '  ' s_z_fix '  ' s_z_rel];
  else
    zen = '';
  end
  if dim==1
    strlinen=['DH     '  strline0  '  ' strline1  ... 
        '     ' strline2 strline2a ...
        s_z_fix, '  ', s_z_rel_B, '  ', s_z_rel_C];    
  end
  if dim>1
    strlinen=['TS     '  strline0  '  ' strline1  ... 
        '     0.00000        0.00000  R0     ' strline2 ... 
        '  ' s_a_fix  '  ' s_a_rel  '  S0  ' strline3 ...
        '  ' s_s_fix  '  ' s_s_rel zen '  ' dimstr];
  end
  strline=[strline;strlinen];
end
strline=[strline ; '$'];

% Write the observations to a MOVE3 OBS-file
fName = strrep(NetworkName,' ','_');
fName = strcat(fName, '.Obs');
fName=fullfile(prjdir, 'output', fName);
fid = fopen(fName,'w');
if fid ~= -1
  nstrline=size(strline,1);
  for i=1:nstrline
    fprintf(fid,'%s\r\n',strtrim(char(strline{i,1:end})));
  end
end
fclose(fid);

% From the manual of MOVE3 comes the following information
% about the fields in the Obs-file.
%
% Height difference (= DH):
%
% height difference ID:          DH
% station name:                  maximum 16 characters
% target name:                   maximum 16 characters
% reading[#]:                    in LINEARUNIT
% length levelling line:         in LINEARUNIT
% absolute standard deviation A: in mm
% relative standard deviation B: in mm/sqrt(km)
% relative standard deviation C: in mm/km
%
% The length of the levelling line followed during the measurement of a height difference must be included. If this length is specified as 0.0, MOVE3 will compute this length using the approximate coordinates.
