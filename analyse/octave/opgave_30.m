# Opgave 30

addpath ("./lib")

# Gegeven
Qu = [ 7 -1 ; -1 5 ] ;
variantie_factor = (7/9)*10^-10 ;

F = [ 1 -2 ] ;


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

