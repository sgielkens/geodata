# Opgave 24b

addpath ("./lib")

# Gegeven
y = [ -9.841; 17.309; -7.451; 37.232 ; -29.783 ] ;
B = [ 1 0; 1 0; 1 1 ; 0 1 ; 0 1] ;
b0 = [ 0 ] ;

var_y = [ 1 ; 2 ; 2 ; 1 ; 3 ] ;
Dy = diag(var_y) ;

Qy = Dy ;

# Vereffening volgens gewogen A-model
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
