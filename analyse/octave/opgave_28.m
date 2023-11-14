# Opgave 28

addpath ("./lib")

# Gegeven
Qu = [ 3 -1 ; -1 2 ] ;
variantie_factor = 5 ;

F = [ 1 1 ] ;


# Berekening
uitvoer=['Matrix van gewichtscoefficienten:'] ;
disp(uitvoer)
Qv = Qvoort(Qu, F)
disp('')

uitvoer=['Covariantiematrix:'] ;
disp(uitvoer)
Dv = variantie_factor * Qv
disp('')

uitvoer=['Standaarddeviatie:'] ;
disp(uitvoer)
sigma = sqrt(Dv)

