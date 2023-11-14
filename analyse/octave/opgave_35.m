# Opgave 35

addpath ("./lib")

# Gegeven
Qu = [ 9 -5 -4 ; -5 7 -2 ; -4 -2 6] ;
variantie_factor = (10) ;

F = [ 5 4 -8 ; 1 0 -3 ] ;


# Berekening
uitvoer=['Matrix van gewichtscoefficienten:'] ;
disp(uitvoer)
Qv = Qvoort(Qu, F)
disp('')

uitvoer=['Covariantiematrix:'] ;
disp(uitvoer)
Dv = variantie_factor * Qv
disp('')

