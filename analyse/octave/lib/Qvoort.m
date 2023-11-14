# Berekening van voortplanting van gewichtscoefficienten

# Input
# - matrix Q van gewichtscoefficienten
# - matrix F van coefficienten

# Output
# - matrix Q van voortplanting van gewichtscoefficienten


function [ Qv ] = Qvoort(Qu, F)

Qv = F * Qu * F' ;

end
