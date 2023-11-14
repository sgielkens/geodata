# Opdracht volgens B-model

addpath ("./lib")

format short

# Gegeven
#naam_project = ['Opdracht']
# Observatiebestand met opzettelijke fouten
naam_project = ['Opdracht_F_NOK']
pad_project = ['../genobs_0.0.4/data/' naam_project '/output/']
vast_punt='A'

# Eenheid: meter (m)
sigma_1km = 1*10^-3 ;

# y: waarnemingen y
# aantal_x: aantal onbekende parameters
[ station, y, punt_van, punt_naar, afstand_m, aantal_x, vrijheidsgraden, hoogte_vast_punt ] = lees_invoer(naam_project, pad_project, vast_punt) ;

afstand_km = afstand_m * 10^-3 ;

# B-matrix
# 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19
B_T = [
0  -1  1  0  0  0  -1 0  0  0  0  0  0  0  0  0  0  0  0;
0  0   1 -1  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0;
0  0   0  1 -1  0  0  0  0  0  0  0  0  0  0  1  0  0  0;
0  0   0  0  1 -1  0  0  0  0  0  0  0  0  0  0  1  0  0;
-1 0   0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  1  0;
1  -1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1;
0  0   0  0  0  0 -1  1  0 -1  0 -1  0  1  1  0  0  0  0;
0  0   0  0  0  0  0  0 -1  1 -1  0  1  0  0  0  0  0  0;
] ;

B = B_T' ;

# Vector met constante termen
b0 = 0 ;

variantie_y = afstand_km * sigma_1km^2 ;
# Covariantiematrix
Dy = diag(variantie_y) ;

variantie_factor_priori = 10^-8 ;
# Gewichtscoefficientenmatrix
Qy = Dy / variantie_factor_priori ;

# Vereffening volgens gewogen B-model
[ ydakje, edakje, t, Qt, rdakje, Qrdakje, Qedakje, Qydakje ] = B_vereffening(B, y, b0, Qy) ;

uitvoer=['Geschatte waarden voor toevallige afwijkingen edakje:'] ;
disp(uitvoer)
print_vector(edakje, 'edakje', 5) ;
disp('')

uitvoer=['Waarden voor vereffende waarneming ydakje = y - edakje:'] ;
disp(uitvoer)
print_vector(ydakje, 'ydakje', 5) ;
disp('')

# Controle
nullen = B' * edakje - t ;

uitvoer=['Controle op B'' * edakje - t = 0'] ;
disp(uitvoer)
print_vector(nullen, 'nullen', 4) ;
disp('')

# Geschatte hoogtes
hA = hoogte_vast_punt ;
hoogte = [] ;
Qhoogte = [] ;
idx_ydakje = [] ;

hB = ydakje(1) + hA ;
hoogte(end+1,1) = hB ;
idx_ydakje = [ 1 ] ;

hC = ydakje(2) + hA ;
hoogte(end+1,1) = hC ;
idx_ydakje = [ idx_ydakje 2 ] ;

hD = ydakje(3) + hA ;
hoogte(end+1,1) = hD ;
idx_ydakje = [ idx_ydakje 3 ] ;

hE = ydakje(4) + hA ;
hoogte(end+1,1) = hE ;
idx_ydakje = [ idx_ydakje 4 ] ;

hF = ydakje(5) + hA ;
hoogte(end+1,1) = hF ;
idx_ydakje = [ idx_ydakje 5 ] ;

hG = ydakje(6) + hA ;
hoogte(end+1,1) = hG ;
idx_ydakje = [ idx_ydakje 6 ] ;

hH = ydakje(10) + hD ;
hoogte(end+1,1) = ydakje(10) + ydakje(3) + hA ;
idx_ydakje = [ idx_ydakje 10 ] ;

hI = ydakje(8) + hC ;
hoogte(end+1,1) = ydakje(8) + ydakje(2) + hA ;
idx_ydakje = [ idx_ydakje 8 ] ;

hJ = ydakje(14) + hI ;
hoogte(end+1,1) = ydakje(14) + ydakje(8) + ydakje(2) + hA ;
idx_ydakje = [ idx_ydakje 14 ] ;

hK = ydakje(15) + hJ ;
hoogte(end+1,1) = ydakje(15) + ydakje(14) + ydakje(8) + ydakje(2) + hA ;
idx_ydakje = [ idx_ydakje 15 ] ;

hL = ydakje(13) + hH ;
hoogte(end+1,1) = ydakje(13) + ydakje(10) + ydakje(3) + hA ;
idx_ydakje = [ idx_ydakje 13 ] ;

# Matrix die bovenstaand verband vastlegt tussen hoogtes en waarnemingen
#1 2 3 4 5 6 10 8 14 15 13
F = [
1 0 0 0 0 0 0 0 0 0 0 ;
0 1 0 0 0 0 0 0 0 0 0 ;
0 0 1 0 0 0 0 0 0 0 0 ;
0 0 0 1 0 0 0 0 0 0 0 ;
0 0 0 0 1 0 0 0 0 0 0 ;
0 0 0 0 0 1 0 0 0 0 0 ;
0 0 1 0 0 0 1 0 0 0 0 ;
0 1 0 0 0 0 0 1 0 0 0 ;
0 1 0 0 0 0 0 1 1 0 0 ;
0 1 0 0 0 0 0 1 1 1 0 ;
0 0 1 0 0 0 1 0 0 0 1 ;
] ;

# Berekening van gewichtscoefficientenmatrix voor hoogtes
Qhoogte = bereken_covar(F, idx_ydakje, Qydakje)

uitvoer=[ 'Geschatte hoogtes op basis van vaste hoogte ' num2str(hoogte_vast_punt) ' van punt ' vast_punt ] ;
disp(uitvoer)
print_vector(hoogte, 'hoogte', 4) ;
disp('')

# Standaardafwijking van vereffende waarnemingen
Dydakje = variantie_factor_priori * Qydakje ;
sigma_ydakje = sqrt( diag(Dydakje) );

uitvoer=['Standaardafwijking van vereffende waarnemingen:'] ;
disp(uitvoer)
print_vector(sigma_ydakje, 'sigma_ydakje', 5) ;
disp('')

# Standaardafwijking van geschatte hoogtes
Dhoogte = variantie_factor_priori * Qhoogte ;
sigma_hoogte = sqrt( diag(Dhoogte) ) ;

uitvoer=['Standaardafwijking van geschatte hoogtes:'] ;
disp(uitvoer)
print_vector(sigma_hoogte, 'sigma_hoogte', 5) ;
disp('')

# Covariantie van geschatte hoogtes
uitvoer=['Covariantie van geschatte hoogtes:'] ;
disp(uitvoer)
format short
Dhoogte
disp('')


# F-toets
F_toetsgrootheid = F_toets_Bmodel(vrijheidsgraden, variantie_factor_priori, Qt, t) ;

uitvoer=['F-toetsgrootheid via sluittermen'] ;
disp(uitvoer)
print_vector(F_toetsgrootheid, 'F-', 4) ;
disp('')

# w-toets
w_toetsgrootheid = w_toets(edakje, Qedakje, variantie_factor_priori) ;

uitvoer=['W-toetsgrootheden'] ;
disp(uitvoer)
print_vector(w_toetsgrootheid, 'w-', 4) ;
disp('')

