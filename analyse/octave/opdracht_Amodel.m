# Opdracht volgens A-model

addpath ("./lib")

format long

# Gegeven
# Eenheid: meter (m)
hA = 2.042 ;
sigma_1km = 1*10^-3 ;

# Waarnemingen
y = [ -0.54582 ;
      1.74976 ;
      -1.20458 ;
      -0.77829 ;
      0.23306 ;
      0.54492 ;
      1.20398 ;
      -1.74799 ;
      -0.23445 ;
      0.77747
] ;

# A-matrix
A = [ 1 0 0 ;
      -1 1 0 ;
      0 -1 0 ;
      0 0 1 ;
      1 0 -1 ;
      -1 0 0 ;
      0 1 0 ;
      1 -1 0 ;
      -1 0 1;
      0 0 -1
] ;

# Vector met constante termen
a0 = [ -hA ;
       0 ;
       hA ;
       -hA ;
       0 ;
       hA ;
       -hA ;
       0 ;
       0 ;
       hA
] ;

vrijheidsgraden = 7 ;

# Berekende afstanden uit coordinaten
afstand_m = [ 1598.4 ;
              1496.4 ;
              1696.5 ;
              1816.1 ;
              784.1 ;
              1598.4 ;
              1696.5 ;
              1496.4 ;
              784.1 ;
              1816.1
] ;

afstand_km = afstand_m * 10^-3 ;

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


# Berekende hoogtes
hA = hA ;
hB = xdakje(1) ;
hC = xdakje(2) ;
hD = xdakje(3) ;

h = [ hA ; hB ; hC ; hD ] ;

uitvoer=['Berekende hoogtes op basis van vaste hoogte hA'] ;
disp(uitvoer)
print_vector(h, 'hoogte', 4) ;
disp('')


# F-toets
F_toetsgrootheid = F_toets_Amodel(vrijheidsgraden, variantie_factor_priori, Qy, edakje) ;

uitvoer=['F-toetsgrootheid via geschatte toevallige afwijkingen'] ;
disp(uitvoer)
print_vector(F_toetsgrootheid, 'F-', 5) ;
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


