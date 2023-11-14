function [inputdir, crd, obs, dim, mesg, stop] = ReadInputData(prj, prjdir, IniData);
% ReadInputData  
  stop = false;
  %  IniData
  if isfield(IniData, 'networknamebase')
    NetworkNameBase = IniData.networknamebase;
  else
    NetworkNameBase = 'Generated observations';
  end

  global inputdir
  inputdir = fullfile(prjdir,'input');
  
  % Logfile
  logdir = fullfile(prjdir,'output');
  [status,msg]=mkdir(logdir);
  logfilename=fullfile(logdir,[prj '.txt']);
  fopen(logfilename,'w');
  diary(logfilename);
  diary on
  
  % File with coordinates is read
  [crd, dim, mesg, stop] = ReadCoordinates(inputdir, 'coord.txt',IniData.dim);
%  disp(crd)
%  for j=1:dim
%    disp(length(crd{1,j}))
%  end
 
  % File with point sets is read
  % For these point sets observations will be generated
  [obs, mesg_o] = ReadPointSets(inputdir, 'obs.txt');
  mesg = AddMessage(mesg, mesg_o);
  
end % function ReadInputData  
