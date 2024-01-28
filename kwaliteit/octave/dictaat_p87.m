# Dictaat pagina 87
# Volgens A-model

addpath ("./lib")

# Start

uitvoer=['Eerste benadering'] ;
disp(uitvoer)
disp('')

# Gegeven
y = [2.394; 9.584] ;
A = [ 0.25 ; 1] ;
a0 = [ 0 ; 0 ] ;

# Vereffening volgens A-model
[ xdakje , ydakje , edakje ] = Amodel(A, y, a0) ;

uitvoer=['Geschatte waarden voor parameters xdakje:'] ;
disp(uitvoer)
print_vector(xdakje, 'xdakje', 4) ;
disp('')

uitvoer=['Geschatte waarden voor toevallige afwijkingen edakje:'] ;
disp(uitvoer)
print_vector(edakje, 'edakje', 5) ;
disp('')

uitvoer=['Waarden voor vereffende waarneming ydakje = A * xdakje + a0:'] ;
disp(uitvoer)
print_vector(ydakje, 'ydakje', 4) ;
disp('')

# Controle
nullen = A' * edakje ;

uitvoer=['Controle op A'' * edakje = 0'] ;
disp(uitvoer)
print_vector(nullen, 'nullen', 4) ;
disp('')

