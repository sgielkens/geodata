# Opgave 38

addpath ("./lib")

# Gegeven
Qu = [ 1 4 0 ; 4 4 -8 ; 0 -8 1 ] ;
variantie_factor = (6.25)*10^-6 ;

F = [ 2 -3 1 ; 0 0 -1 ] ;


# Berekening
uitvoer=['Matrix van gewichtscoefficienten:'] ;
disp(uitvoer)
Qv = Qvoort(Qu, F)
disp('')

uitvoer=['Covariantiematrix:'] ;
disp(uitvoer)
Dv = variantie_factor * Qv
disp('')

