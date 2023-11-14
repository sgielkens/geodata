# Opgave 43

addpath ("./lib")

# Gegeven
y = [ 1.5 ; 2.5 ; 5 ; 8 ] ;
A = [ -1 1 ; 0 1 ; 1 1 ; 2 1 ] ;
a0 = [ 0 ; 0 ; 0 ] ;

vrijheidsgraden = 2 ;

var_y = [ 0.04 ; 0.04 ; 0.04 ; 0.04 ] ;
Dy = diag(var_y) ;

variantie_factor_priori = 0.04 ;

Qy = Dy / variantie_factor_priori ;

# Vereffening volgens gewogen A-model
[xdakje , ydakje , edakje, rdakje, Qxdakje, Qydakje, Qedakje, Qrdakje] = A_vereffening(A, y, a0, Qy) ;

uitvoer=['Geschatte waarden voor parameters xdakje:'] ;
disp(uitvoer)
print_vector(xdakje, 'xdakje', 3) ;
disp('')

uitvoer=['Geschatte waarden voor toevallige afwijkingen edakje:'] ;
disp(uitvoer)
print_vector(edakje, 'edakje', 4) ;
disp('')

uitvoer=['Waarden voor vereffende waarneming ydakje = A * xdakje + a0:'] ;
disp(uitvoer)
print_vector(ydakje, 'ydakje', 3) ;
disp('')

# Controle
Wy = inv(Qy) ;
nullen = A' * Wy * edakje ;

uitvoer=['Controle op A'' * Wy * edakje = 0'] ;
disp(uitvoer)
print_vector(nullen, 'nullen', 4) ;
disp('')


# F-toets
F_toetsgrootheid = F_toets_Amodel(vrijheidsgraden, variantie_factor_priori, Qy, edakje) ;

uitvoer=['F-toetsgrootheid via geschatte toevallige afwijkingen'] ;
disp(uitvoer)
print_vector(F_toetsgrootheid, 'F-', 4) ;
disp('')


# w-toets
w_toetsgrootheid = w_toets(edakje, Qedakje, variantie_factor_priori) ;

uitvoer=['W-toetsgrootheden'] ;
disp(uitvoer)
print_vector(w_toetsgrootheid, 'w-', 4) ;
disp('')
