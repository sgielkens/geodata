function crd = AddIdealisationPrecision(crd, idprec)
  % AddIdealisationPrecision (idprec)
  % Generally a prism cannot be put exactly on a point. A certain 
  % "idealisation precision" is always present. It is here
  % supposed to be very small, because the points are supposed
  % to be monumented, so that the standard deviation is limited
  % to 0.5 mm as default. This is randomly added to the coordinates.
  % idprec is in mm. Therefore it is multiplicated by 1000 to get meters.
  idprec = str2num(idprec) * 1e-3;
  n = size(crd{1,2},1);
  if (is_octave)
      randomly_added = normrnd_oct(0, idprec , 2*n ,1);
  else
      randomly_added = normrnd(0, idprec , 2*n ,1);
  end
  k = 0;
  for i = 2:3
      crd{1,i} = crd{1,i} + randomly_added(k+1:k+n);
      k = k + 1;
%      disp('noise')
%      disp(sprintf('%12.7f\n',randomly_added(k+1:k+n)))
%      disp('coordinates')
%      disp(sprintf('%12.7f\n',crd{1,i}))
  end

end % function  AddIdealisationPrecision

