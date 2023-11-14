# Opgave 42

addpath ("./lib")

# Gegeven
y = [ 3.425 ; 2.783 ; 0.666 ] ;
B = [ 1 ; -1 ; -1 ] ;
b0 = [ 0 ] ;

vrijheidsgraden = 1 ;

var_y = [ 8 * 10^-6; 16 * 10^-6; 8 * 10^-6] ;
Dy = diag(var_y) ;

variantie_factor_priori = 8 * 10^-6 ;

Qy = Dy / variantie_factor_priori ;

# Vereffening volgens gewogen B-model
[ ydakje, edakje, t, Qt, rdakje, Qrdakje, Qedakje, Qydakje ] = B_vereffening(B, y, b0, Qy) ;

uitvoer=['Geschatte waarden voor toevallige afwijkingen edakje:'] ;
disp(uitvoer)
print_vector(edakje, 'edakje', 4) ;
disp('')

uitvoer=['Waarden voor vereffende waarneming ydakje = y - edakje:'] ;
disp(uitvoer)
print_vector(ydakje, 'ydakje', 3) ;
disp('')

# Controle
nullen = B' * edakje - t ;

uitvoer=['Controle op B'' * edakje - t = 0'] ;
disp(uitvoer)
print_vector(nullen, 'nullen', 4) ;
disp('')


# F-toets
F_toetsgrootheid = F_toets_Bmodel(vrijheidsgraden, variantie_factor_priori, Qt, t) ;

uitvoer=['F-toetsgrootheid via sluittermen'] ;
disp(uitvoer)
print_vector(F_toetsgrootheid, 'F-', 4) ;
disp('')

# Controle F-toets via geschatte toevallige afwijkingen
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
