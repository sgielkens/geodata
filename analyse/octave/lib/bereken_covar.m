# Berekening van voortplanting van gewichtscoefficienten

# Input
# - matrix F van coefficienten
# - vector met indexen van te gebruiken coefficienten uit matrix Q
# - matrix Q van gewichtscoefficienten

# Output
# - matrix Q van voortplanting van gewichtscoefficienten


function Qv = bereken_covar(Fmatrix, obs_idx, obs_Qmatrix)

  Qu = [] ;

  nr=size(obs_idx, 2) ;

  for i=1:nr
    for j=1:i-1
      Qu(j, i) = obs_Qmatrix(obs_idx(j), obs_idx(i)) ;
      Qu(i, j) = Qu(j, i) ;
    end
    Qu(i, i) = obs_Qmatrix(obs_idx(i), obs_idx(i)) ;
  end

  Qu ;

  Qv = Fmatrix * Qu * Fmatrix' ;

end
