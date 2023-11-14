# Opgave 37

addpath ("./lib")

# Gegeven
Qu = [ 16 0 0 0 ; 0 16 0 0 ; 0 0 9 0 ; 0 0 0 9 ] ;
variantie_factor = (1)*10^-8 ;

F = [ -1 -1 -1 0 ; 0 -1 -1 -1 ] ;


# Berekening
uitvoer=['Matrix van gewichtscoefficienten:'] ;
disp(uitvoer)
Qv = Qvoort(Qu, F)
disp('')

uitvoer=['Covariantiematrix:'] ;
disp(uitvoer)
Dv = variantie_factor * Qv
disp('')

