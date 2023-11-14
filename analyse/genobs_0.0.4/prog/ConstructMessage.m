function mesg = ConstructMessage(dh, s, alpha, beta, dim)
  strnwline = @(strng) sprintf('%s\n', strng);

  number_h = num2str(size(dh,1));
  
  n =size(s,1);
  if dim==1
    number_s = '0';
  else
    number_s = num2str(size(s,1));
  end
  
  number_a = num2str(size(alpha,1));
  number_b = num2str(size(beta,1));

  % anonymous function to determine, whether a word should be in 
  % singular or plural.
  if n == 1 plural = ''; else plural = 's'; end
  obstp = @(str) [' ' str plural];
  
  nwln = sprintf('%s\n     ','');
  mesg1 = ['2. Generated: '];
  mesg2 = [nwln, number_h, obstp('height difference')];
  mesg3 = [nwln, number_s, obstp('distance')];
  mesg4 = [nwln, number_a, obstp('direction')];
  mesg5 = [nwln, number_b, obstp('zenith height')];
  
  if dim==1
    mesgheader = [mesg1, mesg2];
  else
    if dim==2
      mesgheader = [mesg1, mesg3, mesg4];
    else
      mesgheader = [mesg1, mesg3, mesg4, mesg5];
    end
  end
  
  % Not used, but usable to show all generated heights etc. Remove %
  % from last lines below.
  mesg10 = strnwline('Heights:');
  mesg11 = strnwline('Distances:');
  mesg12 = strnwline('Directions:');
  mesg13 = strnwline('Zenith heights:');
  
  mesgh = sprintf('%12.5f\n', dh);
  mesgs = sprintf('%12.5f\n', s);
  mesga = sprintf('%12.5f\n', alpha);
  mesgz = sprintf('%12.5f\n', beta);

  mesg = mesgheader;
%  mesg = [strnwline(mesgheader), mesg10, mesgh, mesg11, mesgs, ...
%  mesg12, mesga, mesg13, mesgz];
end
