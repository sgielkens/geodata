# Opgave 27

addpath ("./lib")

# Gegeven
y = [ 34.971 ; 57.995 ; 107.114 ; 82.013 ; 82.916 ] ;
B = [ 1 1 ; 1 0; 1 0 ; 0 1 ; 0 1 ] ;
b0 = [ 200 ; 200 ] ;

var_y = [ 4 ; 2 ; 2 ; 2 ; 2 ] ;
Dy = diag(var_y) ;

Qy = Dy ;

# Vereffening volgens gewogen B-model
[ ydakje , edakje, t ] = Bmodel(B, y, b0, Qy) ;

uitvoer=['Geschatte waarden voor toevallige afwijkingen edakje:'] ;
disp(uitvoer)
print_vector(edakje, 'edakje', 4) ;
disp('')

uitvoer=['Waarden voor vereffende waarneming ydakje = y - edakje:'] ;
disp(uitvoer)
print_vector(ydakje, 'ydakje', 3) ;
disp('')

# Controle
nullen = B' *  edakje - t ;

uitvoer=['Controle op B'' * edakje - t = 0'] ;
disp(uitvoer)
print_vector(nullen, 'nullen', 4) ;
disp('')
