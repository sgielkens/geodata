# Opgave 32

addpath ("./lib")

# Gegeven
Qu = [ 1 0 0 ; 0 1 0 ; 0 0 1 ] ;
variantie_factor = (1/4)*10^-6 ;

F = [ -1 1 0 ; 0 -1 1 ] ;


# Berekening
uitvoer=['Matrix van gewichtscoefficienten:'] ;
disp(uitvoer)
Qv = Qvoort(Qu, F)
disp('')

uitvoer=['Covariantiematrix:'] ;
disp(uitvoer)
Dv = variantie_factor * Qv
disp('')

