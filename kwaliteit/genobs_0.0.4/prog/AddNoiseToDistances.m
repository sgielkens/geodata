function [s, mesg] = AddNoiseToDistances(s, IniData)
  % A random supplement is added to each distance which is normally
  % distributed with a standard deviation of 1 mm,
  % based upon the specifications of Leica Viva TS11:
  % 1 mm + 1.5 ppm to prism, which is 1 mm + 0.03 mm / 20 m so
  % the 0.03 mm is neglected.

  sfixed = IniData.sfixed;
  srel   = IniData.srel;

  n = size(s, 1);

  fx = sfixed * ones(n,1);
  rl = srel * 1e-6 * s;
  std_s = fx + rl;
  a = std_s.^2;

  idpr = IniData.idprec * ones(n,1);
  b = 2 * (idpr.^2);

  stdev = sqrt(a + b);

  if (is_octave)
    randomly_added = normrnd_oct(0, 1, n ,1);
  else
    randomly_added = normrnd(0, 1, n ,1);
  end

  noise = stdev .* randomly_added;
  s = s + noise;

  % disp(sprintf('%12.7f\n',noise))
  mesg = {['     mean randomly added to distances     = ' ...
           num2str(mean(noise)*1000) ' mm'];
          ['     st. dev. randomly added to distances = ' ...
           num2str(std(noise)*1000) ' mm']};
end % function AddNoiseToDistances

