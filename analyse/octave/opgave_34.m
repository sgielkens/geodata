# Opgave 34

addpath ("./lib")

# Gegeven
Qu = [ 25 0 0 0 ; 0 25 0 0 ; 0 0 49 0 ; 0 0 0 49] ;
variantie_factor = (1)*10^-10 ;

F = [ 0 -1 1 0 ; 1 0 0 -1 ] ;


# Berekening
uitvoer=['Matrix van gewichtscoefficienten:'] ;
disp(uitvoer)
Qv = Qvoort(Qu, F)
disp('')

uitvoer=['Covariantiematrix:'] ;
disp(uitvoer)
Dv = variantie_factor * Qv
disp('')

