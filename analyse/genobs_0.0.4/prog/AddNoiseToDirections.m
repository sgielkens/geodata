function [alpha, mesg] = AddNoiseToDirections(xyz, alpha, s, stdev, idprec)
% A random supplement is added to each direction which is normally
% distributed with a standard deviation of 0.3 * sqrt(2) mgon 
% (0.4 mgon), based upon the specifications of Leica Viva TS11 for 
% horizontal and vertical angle measurements
  afixed = stdev.fixed;
  arel   = stdev.rel;

  n = size(alpha, 1);

  rl = arel ./ s * 1000;
  std_alpha = afixed * ones(n,1) +  rl;
  a = std_alpha.^2;

  idpr = idprec * ones(n,1);
  b = 2 * (idpr ./ s * 200 / pi ).^2 ;

  stdev = sqrt(a + b);

  if (is_octave)
    randomly_added = normrnd_oct(0, 1, n ,1);
  else
    randomly_added = normrnd(0, 1, n ,1);
  end

  noise = stdev .* randomly_added;
  alpha = alpha + noise;

  % disp(sprintf('%12.7f\n',noise))
  
  if xyz == 'xy'
    obstype = 'directions';
  else % xyz == 'z'
    obstype = 'zenith heights';
  end
  mesg = {['     mean randomly added to ' obstype, '     = ' ...
           num2str(mean(noise)*1000) ' mgon'];
  ['     st. dev. randomly added to ' obstype, ' = ' ... 
           num2str(std(noise)*1000) ' mgon']};
  
end % function AddNoiseToDirections

