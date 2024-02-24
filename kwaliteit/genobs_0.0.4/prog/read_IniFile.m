function [IniData, mesg] = read_IniFile(inidir, IniFile, progdir);
  [filepath,name,ext] = fileparts(IniFile);
  if isempty(ext)
    IniFile = [IniFile '.ini'];
  end % if
  IniFile = fullfile(inidir, IniFile);
  check = exist(IniFile, 'file') == 2;
  if ~check
    % File does not exist.
    fid = fopen(IniFile, 'w'); 
    inif = fullfile(progdir, 'Sample.ini');
    copyfile(inif, IniFile, 'f');
    [filepath,name,ext] = fileparts(IniFile);
    Pname = ['project = ', name];
    txtfilechange(IniFile, Pname, 9);
    fclose(fid);
    mesg = {'Advice:';
            ['1. Command File "', [name ext], '" is in folder "ini".'];
            ['   If it is needed, edit this file and change the dimension,']; 
            ['   S-base points, idealisation precisions and other standard'];
            ['   deviations.'];
            ['2. Go to folder "data", then to subfolder "', name ,'", and finally'];
            ['   to subfolder "input".'];
            ['3. Edit files "coord.txt" and "obs.txt" in this subfolder.']};
    PrintMsg(mesg)
  end
  [IniData, mesg] = ReadIniFile(IniFile);
end
