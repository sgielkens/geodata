# Opgave 33

addpath ("./lib")

# Deel a
# Gegeven
Qu = [ 1 0 0 0 0 ; 0 9 0 0 0 ; 0 0 18 0 0 ; 0 0 0 18 0 ; 0 0 0 0 18 ] ;
variantie_factor = (1) ;

F = [ 1 1 0 0 -1 ; 1 1 1 1 0 ] ;


# Berekening
uitvoer=['######## Deel a ########'] ;
disp(uitvoer)
disp('')

uitvoer=['Matrix van gewichtscoefficienten:'] ;
disp(uitvoer)
Qv = Qvoort(Qu, F)
disp('')

uitvoer=['Covariantiematrix:'] ;
disp(uitvoer)
Dv = variantie_factor * Qv
disp('')


# Deel b
# Gegeven
Qu = [ 14 5 ; 5 23 ] ;
variantie_factor = (2) ;

F = [ 1 -1 ] ;


# Berekening
uitvoer=['######## Deel b ########'] ;
disp(uitvoer)
disp('')

uitvoer=['Matrix van gewichtscoefficienten:'] ;
disp(uitvoer)
Qv = Qvoort(Qu, F)
disp('')

uitvoer=['Covariantiematrix:'] ;
disp(uitvoer)
Dv = variantie_factor * Qv
disp('')



# Deel c
# Gegeven
Qu = [ 1 0 0 ; 0 1 0 ; 0 0 1 ] ;
variantie_factor = (18) ;

F = [ -1 -1 -1 ] ;


# Berekening
uitvoer=['######## Deel c ########'] ;
disp(uitvoer)
disp('')

uitvoer=['Matrix van gewichtscoefficienten:'] ;
disp(uitvoer)
Qv = Qvoort(Qu, F)
disp('')

uitvoer=['Covariantiematrix:'] ;
disp(uitvoer)
Dv = variantie_factor * Qv
disp('')

