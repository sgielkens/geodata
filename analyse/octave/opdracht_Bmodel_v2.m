# Opdracht volgens B-model

addpath ("./lib")

format long

# Gegeven
# Eenheid: meter (m)
hA = 2.042 ;
sigma_1km = 1*10^-3 ;

# Waarnemingen
y = [
-0.54495 ;
-0.14624 ;
-0.77697 ;
-0.46775 ;
 0.06225 ;
-0.46983 ;
-0.63104 ;
-0.25787 ;
 0.31024 ;
 0.41938 ;
 0.23061 ;
 0.08970 ;
 0.11899 ;
 0.29627 ;
-0.16141 ;
 0.53282 ;
-0.53217 ;
-0.07602 ;
 0.39951
 ;] ;

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
# In dit geval 0
b0 = 0 ;

vrijheidsgraden = 8 ;

# Berekende afstanden uit coordinaten
afstand_m = [
1547.48203 ;
2650.34442 ;
2273.51579 ;
2397.43458 ;
2393.35362 ;
1942.79108 ;
2066.82757 ;
1248.19917 ;
2558.42845 ;
2601.33811 ;
2375.53412 ;
1504.91773 ;
2452.92694 ;
1157.26258 ;
1248.64164 ;
2553.55154 ;
1950.87953 ;
2145.85161 ;
2121.84159 ;
] ;

afstand_km = afstand_m * 10^-3 ;

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

# Berekende hoogtes
hA = hA ;
hB = ydakje(1) + hA ;
hC = hA - ydakje(3) ;
hD = ydakje(4) + hA ;

h = [ hA ; hB ; hC ; hD ] ;

uitvoer=['Berekende hoogtes op basis van vaste hoogte hA'] ;
disp(uitvoer)
print_vector(h, 'hoogte', 4) ;
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


# Bepaling van varianties en covarianties
#uitvoer=['Matrix van gewichtscoefficienten:'] ;
#disp(uitvoer)
#Qv = Qvoort(Qy, F)
#disp('')

#uitvoer=['Covariantiematrix:'] ;
#disp(uitvoer)
#Dv = variantie_factor * Qv
#disp('')

#uitvoer=['Standaarddeviatie:'] ;
#disp(uitvoer)
#sigma = sqrt(Dv)



