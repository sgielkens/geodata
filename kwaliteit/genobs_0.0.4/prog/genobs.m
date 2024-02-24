function genobs(IniFile)
  % genobs - Computes observations from coordinates in 1D, 2D or 3D
  % The first input file "coord.txt" contains heights (1D), 
  % planimetric coordinates (2D) or three dimensional Euclidian 
  % coordinates (3D). Each line contains subsequently the pointname, 
  % E and N coordinate.
  % The second input file "obs.txt" contains points sets. Each line contains
  % one point set: the first point is the instrument point. The second point
  % is the target point.
  % The programme computes for each point set: 
  % 1D: a height difference
  % 2D: a distance and a direction angle 
  % 3D: a distance, a direction angle and a zenith height.
  % Random noise is added for each observation.
  % The observations are output line by line in MOVE3 format
  clc
  format long
  
  if nargin == 0
    IniFile = 'DefaultProject';
  end

  % Add folders with ini-file and sub programmes to path
  [maindir,name,ext] = fileparts(pwd);
  inidir=fullfile(maindir,'ini');
  addpath(inidir);
  progdir=fullfile(pwd);
  addpath(progdir);

  % Read control parameters from ini-file
  [IniData, msg] = read_IniFile(inidir, IniFile, progdir);
  
  % Folder with project data
  prj = IniData.project;
  prjdir = fullfile(maindir, 'data', prj);
  
  % Main programme
  if ~exist(prjdir)
    CreateProject(prjdir, prj)
  else
    % Read input data
    [inputdir, crd, obs, dim, mesg_c, stop] = ReadInputData(prj, prjdir, IniData);
    msg = AddMessage(msg, mesg_c);
    mesg = '1. Coordinates and desired observations have been read';
    
    if ~stop
      % Print header
      PrintHeader(prj, dim, mesg)
      
      % Generate observations
      [dh, s0, alpha, beta, obs, mesg_g] = GenerateObs(crd, obs, dim);
      PrintMsg(ConstructMessage(dh, s0, alpha, beta, dim))
      msg = AddMessage(msg, mesg_g); 
      nobs = size(obs{1,1},1);
      if nobs == 0
        msg = AddMessage(msg, ...
                   {'*** Warning: no observations were generated:'; ...
                   ['             no valid point sets were found in file "obs.txt"']});
      else
        % Add some orientation to directions
%        alpha = AddOrientation(alpha)
        
        % Add noise to observations
        if dim>1
          [s, mesg_s] = AddNoiseToDistances(s0, IniData);
          xyz = 'xy';
          [alpha, mesg_a] = AddNoiseToDirections(xyz, alpha, s0, IniData.a, IniData.idprec);
          mesg_h = '';
        else % dim==1
          [dh, mesg_h] = AddNoiseToHeightDifferences(dh, s0, IniData);
          s = [];
          mesg_s = '';
          mesg_a = '';
        end
        if dim==3
          xyz = 'z';
          [beta, mesg_b] = AddNoiseToDirections(xyz, beta, s0, IniData.z, IniData.idhgt);
          mesg_a = [mesg_a; mesg_b];
        end
        mesg = '3. Noise has been added to observations';
        PrintMsg([mesg; mesg_h; mesg_s; mesg_a])
        
        % Write to MOVE3 files
        WriteToObsfile(obs, dh, s0, s, alpha, beta, prj, prjdir, IniData, dim)
        PrintMsg('4. Observations have been written to MOVE3-file')
        
        WriteToTcofile(crd, prj, prjdir, IniData.idprec, IniData.idhgt, dim)
        PrintMsg('5. Coordinates have been written to MOVE3-file')
        
        mesg = WriteToPrjfile(progdir, prjdir, prj, IniData.sbase, crd, dim);
        PrintMsg('6. Project file of MOVE3 has been written')
        msg = AddMessage(msg, mesg); 
      
      end
    end
    
    % End of programme
    disp('7. End of programme');
    if ~isempty(msg)
      PrintMsg(msg)
    end
    diary off
    fclose('all');
  end
  
  clear
       
end % function genobs
