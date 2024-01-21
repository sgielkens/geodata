# Opgave 1
# Volgens A-model

addpath ("./lib")

# Start

uitvoer=['Eerste benadering'] ;
disp(uitvoer)
disp('')

# Gegeven
y = [ 3.12 ; 3.80 ] ;
A = [ 5 * cos(pi/5) ; -5 * sin(pi/5) ] ;
a0 = [ 5 * sin(pi/5) - pi * cos(pi/5) ; 5 * cos(pi/5) + pi * sin(pi/5) ] ;

# Vereffening volgens A-model
[ xdakje , ydakje , edakje ] = Amodel(A, y, a0) ;

uitvoer=['Geschatte waarden voor parameters xdakje:'] ;
disp(uitvoer)
print_vector(xdakje, 'xdakje', 5) ;
disp('')

uitvoer=['Geschatte waarden voor toevallige afwijkingen edakje:'] ;
disp(uitvoer)
print_vector(edakje, 'edakje', 6) ;
disp('')

uitvoer=['Waarden voor vereffende waarneming ydakje = A * xdakje + a0:'] ;
disp(uitvoer)
print_vector(ydakje, 'ydakje', 3) ;
disp('')

# Controle
nullen = A' * edakje ;

uitvoer=['Controle op A'' * edakje = 0'] ;
disp(uitvoer)
print_vector(nullen, 'nullen', 6) ;
disp('')


# Eerste iteratie

uitvoer=['Eerste iteratie'] ;
disp(uitvoer)
disp('')

# Gegeven
y = [ 3.12 ; 3.80 ] ;
A = [ 5 * cos(0.686) ; -5 * sin(0.686) ] ;
a0 = [ 5 * sin(0.686) - (5 * 0.686) * cos(0.686) ; 5 * cos(0.686) + (5 * 0.686) * sin(0.686) ] ;

# Vereffening volgens A-model
[ xdakje , ydakje , edakje ] = Amodel(A, y, a0) ;

uitvoer=['Geschatte waarden voor parameters xdakje:'] ;
disp(uitvoer)
print_vector(xdakje, 'xdakje', 5) ;
disp('')

uitvoer=['Geschatte waarden voor toevallige afwijkingen edakje:'] ;
disp(uitvoer)
print_vector(edakje, 'edakje', 6) ;
disp('')

uitvoer=['Waarden voor vereffende waarneming ydakje = A * xdakje + a0:'] ;
disp(uitvoer)
print_vector(ydakje, 'ydakje', 3) ;
disp('')

# Controle
nullen = A' * edakje ;

uitvoer=['Controle op A'' * edakje = 0'] ;
disp(uitvoer)
print_vector(nullen, 'nullen', 6) ;
disp('')

