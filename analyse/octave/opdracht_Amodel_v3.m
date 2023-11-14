# Opdracht volgens A-model

addpath ("./lib")

format short

# Gegeven
naam_project = ['Opdracht']
# Observatiebestand met opzettelijke fouten
# naam_project = ['Opdracht_F_NOK']
pad_project = ['../genobs_0.0.4/data/' naam_project '/output/']
vast_punt='A'

# Eenheid: meter (m)
sigma_1km = 1*10^-3 ;

# y: waarnemingen y
# aantal_x: aantal onbekende parameters
[ station, y, punt_van, punt_naar, afstand_m, aantal_x, vrijheidsgraden, hoogte_vast_punt ] = lees_invoer(naam_project, pad_project, vast_punt) ;

afstand_km = afstand_m * 10^-3 ;

# A: A-matrix
# a0: vector met constante termen
[ A, a0 ] = A_vergelijking(station, punt_van, punt_naar, vast_punt, hoogte_vast_punt) ;


variantie_y = afstand_km * sigma_1km^2 ;
# Covariantiematrix
Dy = diag(variantie_y) ;

variantie_factor_priori = 10^-8 ;
# Gewichtscoefficientenmatrix
Qy = Dy / variantie_factor_priori ;


# Vereffening volgens gewogen A-model
[xdakje , ydakje , edakje, rdakje, Qxdakje, Qydakje, Qedakje, Qrdakje] = A_vereffening(A, y, a0, Qy) ;

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
print_vector(ydakje, 'ydakje', 5) ;
disp('')

# Controle
# Gewichtsmatrix
Wy = inv(Qy) ;
nullen = A' * Wy * edakje ;

uitvoer=['Controle op A'' * Wy * edakje = 0'] ;
disp(uitvoer)
print_vector(nullen, 'nullen', 4) ;
disp('')


# Geschatte hoogtes
uitvoer=[ 'Geschatte hoogtes op basis van vaste hoogte ' num2str(hoogte_vast_punt) ' van punt ' vast_punt ] ;
disp(uitvoer)
print_vector(xdakje, 'hoogte', 4) ;
disp('')


# Standaardafwijking van vereffende waarnemingen
Dydakje = variantie_factor_priori * Qydakje ;
sigma_ydakje = sqrt( diag(Dydakje) );

uitvoer=['Standaardafwijking van vereffende waarnemingen:'] ;
disp(uitvoer)
print_vector(sigma_ydakje, 'sigma_ydakje', 5) ;
disp('')

# Standaardafwijking van geschatte hoogtes
Dxdakje = variantie_factor_priori * Qxdakje ;
sigma_xdakje = sqrt( diag(Dxdakje) );

uitvoer=['Standaardafwijking van geschatte hoogtes:'] ;
disp(uitvoer)
print_vector(sigma_xdakje, 'sigma_xdakje', 5) ;
disp('')

# Covariantie van geschatte hoogtes
uitvoer=['Covariantie van geschatte hoogtes:'] ;
disp(uitvoer)
Dxdakje
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

