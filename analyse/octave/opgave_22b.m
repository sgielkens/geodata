# Opgave 22b

addpath ("./lib")

# Gegeven
y = [57.122; 76.664; 66.211] ;
B = [ 1; 1; 1 ] ;
b0 = [ 200 ] ;

var_y = [0.25 ; 0.25 ; 1] ;
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
