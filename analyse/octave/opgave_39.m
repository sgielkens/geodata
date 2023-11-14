# Opgave 39

addpath ("./lib")

# Deel (a)
# Gegeven
Qu = [ 1 0 0 ; 0 2 0 ; 0 0 1 ] ;
variantie_factor = (4) ;

F = [ 1 1 -1 ] ;


# Berekening
uitvoer=['Matrix van gewichtscoefficienten:'] ;
disp(uitvoer)
Qv = Qvoort(Qu, F)
disp('')

uitvoer=['Covariantiematrix:'] ;
disp(uitvoer)
Dv = variantie_factor * Qv
disp('')


# Deel (c)
# Gegeven
Qu = [ 4 0 ; 0 3 ] ;
variantie_factor = (4) ;

F = [ 0.5 0.5 ] ;


# Berekening
uitvoer=['Matrix van gewichtscoefficienten:'] ;
disp(uitvoer)
Qv = Qvoort(Qu, F)
disp('')

uitvoer=['Covariantiematrix:'] ;
disp(uitvoer)
Dv = variantie_factor * Qv
disp('')




# Deel (d)
# Gegeven
Qu = [ 1 0 0 0 ; 0 2 0 0 ; 0 0 1 0 ; 0 0 0 3 ] ;
variantie_factor = (4) ;

F = [ 1 1 0 0 ; 0.5 0.5 -0.5 0.5 ] ;


# Berekening
uitvoer=['Matrix van gewichtscoefficienten:'] ;
disp(uitvoer)
Qv = Qvoort(Qu, F)
disp('')

uitvoer=['Covariantiematrix:'] ;
disp(uitvoer)
Dv = variantie_factor * Qv
disp('')
