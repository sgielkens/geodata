function [dh, mesg] = AddNoiseToHeightDifferences(dh, s, IniData)
  % A random supplement is added to each height difference which is normally
  % distributed with a standard deviation, determined from the parameters in
  % the ini-file.
  % Default values, based upon the specifications of the digital level 
  % Leica LS10: 0.3 mm (standard deviation, 1 km double run, ISO 17123-2. 
  % GPCL3 standard Invar staff or equivalent.). This is for 1 km single 
  % run the square root of 2 times 0.3 mm, which is rounded to 0.4 mm/sqrt(km).

  % SigmaDHA = 0 mm;
  % SigmaDHB = 0.4 mm/sqrt(km);
  % SigmaDHC = 0 mm/km;

  SigmaDHA = IniData.SigmaDHA * 1000;
  SigmaDHB = IniData.SigmaDHB * 1000;
  SigmaDHC = IniData.SigmaDHC * 1000;

  n = size(dh, 1);

  % standaardafwijking van de instrument- en reflectorhoogte (idealisatieprecisie)
  idhgt    = IniData.idhgt * 1000 * ones(n,1);

  sA = SigmaDHA * ones(n,1);
  % In the two equations below the standard deviation is in mm
  % and the distance in km (s is in meters).
  sB = SigmaDHB * sqrt(s * 0.001);
  sC = SigmaDHC * s * 0.001;

  std_dh = sA + sB + sC;
  % Idealisation precision of the height is added.
  std_dh = sqrt(std_dh.^2 + 2 * idhgt.^2);

  % For testing purposes
%  disp(sprintf('%12.2f\n',std_dh));

  if (is_octave)
    randomly_added = normrnd_oct(0, 1, n ,1);
  else
    randomly_added = normrnd(0, 1, n ,1);
  end

  % The noise is computed in mm and then converted to m to
  % be added to the height difference, which is in m.
  noise = std_dh .* randomly_added;
  dh = dh + noise .* 0.001;

  % disp(sprintf('%12.7f\n',noise))
  mesg = {['     mean distance = ' sprintf('%.3f', mean(s)) ' m'];
  ['     mean randomly added to height differences     = ' sprintf('%.4f', mean(noise)) ' mm'];
  ['     st. dev. randomly added to height differences = ' sprintf('%.4f', std(noise)) ' mm']};
end % function AddNoiseToHeightDifferences

