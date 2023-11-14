# Opgave 18

addpath ("./lib")

# Gegeven
y = [5.5; 6.5; 9.5; 10.5] ;
A = [ 2; 3; 4; 5] ;

nr = size(A,1)
eentjes = ones(nr,1)
A=[A eentjes]

# Vereffening volgens A-model
[ xdakje , ydakje , edakje ] = Amodel(A, y) ;

uitvoer=['Geschatte waarden voor parameters xdakje:'] ;
disp(uitvoer)
print_vector(xdakje, 'xdakje', 1) ;
disp('')

uitvoer=['Geschatte waarden voor toevallige afwijkingen edakje:'] ;
disp(uitvoer)
print_vector(edakje, 'edakje', 2) ;
disp('')

uitvoer=['Waarden voor vereffende waarneming ydakje = A * xdakje + a0:'] ;
disp(uitvoer)
print_vector(ydakje, 'ydakje', 1) ;
disp('')

# Controle
nullen = A' * edakje ;

uitvoer=['Controle op A'' * edakje = 0'] ;
disp(uitvoer)
print_vector(nullen, 'nullen', 2) ;
disp('')

