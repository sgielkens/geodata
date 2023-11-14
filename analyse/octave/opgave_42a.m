# Opgave 42a

# Volgens A-model

addpath ("./lib")

# Gegeven
hA = 2.334 ;

y = [ 3.425 ; 2.783 ; 0.666 ] ;
A = [ 1 0 ; 1 -1 ; 0 1 ] ;
a0 = [ -hA ; 0 ; -hA ] ;

vrijheidsgraden = 1 ;

var_y = [ 8 * 10^-6; 16 * 10^-6; 8 * 10^-6] ;
Dy = diag(var_y) ;

variantie_factor_priori = 8 * 10^-6 ;

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
