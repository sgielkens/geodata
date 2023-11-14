# Opgave 31

addpath ("./lib")

# Gegeven
Qu = [ 1 -1 ; -1 2 ] ;
variantie_factor = 50 ;

F = [ 2 -1 ; 2 1 ] ;


# Berekening
uitvoer=['Matrix van gewichtscoefficienten:'] ;
disp(uitvoer)
Qv = Qvoort(Qu, F)
disp('')

uitvoer=['Covariantiematrix:'] ;
disp(uitvoer)
Dv = variantie_factor * Qv
