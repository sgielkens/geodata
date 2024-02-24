function ptnm_spc = AddSpaces(ptnm)
  n = size(ptnm, 1);
  len_ptnm = cellfun('length', ptnm);
  maxptnm = max(len_ptnm(:));
  numel_ptnm = cellfun(@numel, ptnm);
  for i=1:n
    spc = repmat(' ', [1, maxptnm - numel_ptnm(i)]);
    ptnm_spc{i,1} = [ptnm{i,1}  spc];
  end
end
