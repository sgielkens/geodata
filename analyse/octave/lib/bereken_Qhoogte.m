# Berekening van voortplanting van gewichtscoefficienten

# Input
# - matrix Q van gewichtscoefficienten
# - matrix F van coefficienten

# Output
# - matrix Q van voortplanting van gewichtscoefficienten


function Qv = bereken_Qhoogte(coef, coef_matrix)

Qu = [] ;

nr=size(coef, 2) ;
F = ones(1, nr) ;

for i=1:nr
  for j=1:i-1
    Qu(j, i) = coef_matrix(coef(j), coef(i)) ;
    Qu(i, j) = Qu(j, i) ;
  end
  Qu(i, i) = coef_matrix(coef(i), coef(i)) ;
end

Qv = F * Qu * F' ;

end
