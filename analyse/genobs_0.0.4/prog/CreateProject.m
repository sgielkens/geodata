function CreateProject(prjdir, prj)
  mkdir(prjdir);
  indir = fullfile(prjdir, 'input');
  mkdir(indir);
  outdir = fullfile(prjdir, 'output');
  mkdir(outdir);

  crdfile = fullfile(indir, 'coord.txt');
  fid = fopen( crdfile, 'w' );
  str = {'; Each line starting with ; will be neglected by the programme.';
         '; ';
         '; Add points and coordinates to this file.';
         '; Use the following format for 2D:';
         '; <point name>    <x-coordinate>    <y-coordinate>';
         '; Use the following format for 1D and 3D:';
         '; <point name>    <x-coordinate>    <y-coordinate>    <z-coordinate>';
         '; For example:';
         '';
         'A    15.3822    -26.9835    2.042';
         'B    23.9640    -13.5091    1.497';
         'C     9.2832    -11.1984    3.246';
         'D    30.7775    -17.3819    1.264';
         };
  fprintf(fid, '%s\n', str{1:end});
  fclose(fid);

  obsfile = fullfile(indir, 'obs.txt');
  fid = fopen( obsfile, 'w' );
  str = {'; Each line starting with ; will be neglected by the programme.';
         '; ';
         '; Add two point names on each line of this file.';
         '; The first one is the instrument point, the second one is';
         '; the target point.';
         '; For 1D a height difference will be generated between them.';
         '; For 2D a distance and a direction will be generated between them.';
         '; For 3D a distance, a direction and a zenith angle will be generated.';
         '; Use the following format:';
         '; <point name>    <point name>';
         '; For example:';
         '';
         'A    B';
         'B    C';
         'C    A';
         'A    D';
         'D    B';
         'B    A';
         'A    C';
         'C    B';
         'B    D';
         'D    A';
         };
  fprintf(fid, '%s\n', str{1:end});
  fclose(fid);

end % function CreateProject
