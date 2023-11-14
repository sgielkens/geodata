# Opgave 36c

addpath ("./lib")

# Gegeven
Qu = [ 1 0 0  ; 0 1 0 ; 0 0 1 ] ;
variantie_factor = (0.25)*10^-6 ;

F = [ 1 -1 0 ; -1 0 1 ] ;


# Berekening
uitvoer=['Matrix van gewichtscoefficienten:'] ;
disp(uitvoer)
Qv = Qvoort(Qu, F)
disp('')

uitvoer=['Covariantiematrix:'] ;
disp(uitvoer)
Dv = variantie_factor * Qv
disp('')

