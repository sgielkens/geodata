# Opgave transformatie 5
# Volgens A-model

addpath ("./lib")

# Oorspronkelijk puntenveld
pA = [ 0 ; 0 ] ;
pB = [ 50 ; 0 ] ;
pC = [ 60 ; 70 ] ;
pD = [ 20 ; 55 ] ;

# Extra punt
pE = [ 30 ; 50 ]

UT = [ pA pB pC pD ] ;
uT = UT(1,:) ;
vT = UT(2,:) ;

u = uT' ;
v = vT' ;
# plot(u, v, 'o')

# Transformatieparameters
phi = pi / 6 ;
lambda = 1.1 ;
tx = 5 ;
ty = 10 ;

t = [ tx ; ty ] ;
R = [ cos(phi) sin(phi) ; -sin(phi) cos(phi) ] ;

# Ruis
pAn = [ 0.1 ; 0.2 ] ;
pBn = [ -0.05 ; ; 0.1 ] ;
pCn = [ -0.1 ; -0.3 ] ;
pDn = [ 0.2 ; -0.05 ] ;

noiseT = [ pAn pBn pCn pDn ] ;
noise = noiseT' ;

# Getransformeerde parameters
aantal_punten = size(uT, 2) ;
eT = ones(1, aantal_punten) ;

UfT = lambda * R * UT + t * eT ;

ufT = UfT(1,:) ;
vfT = UfT(2,:) ;

uf = ufT' ;
vf = vfT' ;
#plot(u, v, 'o', uf, vf, 'x')

# Extra punt
pEf = lambda * R * pE + t

# Getransformeerde parameters met ruis
UfnT = UfT + noiseT ;
ufnT = UfnT(1,:) ;
vfnT = UfnT(2,:) ;

ufn = ufnT' ;
vfn = vfnT' ;

# plot(uf, vf, 'x', ufn, vfn, '+')

y = [ ufn ; vfn ] ;
# Als onbekende parameters worden gekozen: p, q, tx, ty
e = eT' ;
nT = zeros(1, aantal_punten) ;
n = nT' ;

A = [ u v e n ; v -u n e ] ;

# Volgens B-methode van toetsen: γ0 = 0.8 en α0 = 0.001
lambda_0 = 17.075 ;

# Gegeven
var_y = [e ; e] ;
var_y = var_y * 0.01 ;
# Covariantiematrix
Dy = diag(var_y) ;

variantie_factor = 0.01 ;

# Gewichtscoefficientenmatrix
Qy = Dy / variantie_factor ;
# Gewichtsmatrix
Wy = inv(Qy) ;


# Gegeven
#y = [ 1.5 ; 2.5 ; 5; 8; 9 ] ;
#A = [ -1 1 ; 0 1 ; 1 1 ; 2 1 ; 3 1 ] ;
#a0 = [ 0 ; 0 ; 0 ; 0 ; 0 ] ;
a0 = zeros( size(A,1) , 1) ;

aantal_y = size(A,1) ;
aantal_x = size(A,2) ;
aantal_voorwaarden = aantal_y - aantal_x ;

# Opgave 18c1
# C = [ 0 ; 1 ; 0 ; 0 ; 0 ] ;
#C = zeros( size(A,1) , 1) ;
#C(1) = 1 ;
# Opgave 5.5
C = [ 1  0 ;
      0 -1 ;
      0  0 ;
      0  0 ;
      0  0 ;
      0  0 ;
      0  0 ;
      0  0 ] ;

vrijheids_graden = size(C,2) ;

# Vereffening volgens gewogen A-model
[ xdakje , ydakje , edakje, rdakje, Qxdakje, Qydakje, Qedakje, Qrdakje ] = A_vereffening(A, y, a0, Qy) ;

# Vereffening volgens A-model
uitvoer=['Geschatte waarden voor parameters xdakje:'] ;
disp(uitvoer)
print_vector(xdakje, 'xdakje', 4) ;
disp('')

lambda
phi
tx
ty
disp('')

pdakje = xdakje(1) ;
qdakje= xdakje(2) ;
lambda_dakje = sqrt(pdakje^2 + qdakje^2)
phidakje = atan(qdakje/pdakje)
txdakje = xdakje(3)
tydakje = xdakje(4)
disp('')

# Extra punt terug transformeren
pE = pEf - [ txdakje ; tydakje ]
pE = inv([ pdakje qdakje ; -qdakje pdakje ]) * pE


uitvoer=['Geschatte waarden voor toevallige afwijkingen edakje:'] ;
disp(uitvoer)
print_vector(edakje, 'edakje', 5) ;
disp('')

uitvoer=['Waarden voor vereffende waarneming ydakje = A * xdakje + a0:'] ;
disp(uitvoer)
print_vector(ydakje, 'ydakje', 4) ;
disp('')

# Controle
nullen = A' * Wy * edakje ;

uitvoer=['Controle op A'' * Wy * edakje = 0'] ;
disp(uitvoer)
print_vector(nullen, 'nullen', 4) ;
disp('')

# Toetsing
uitvoer=['-------------------------------------------------------'] ;
disp(uitvoer)
disp('')

uitvoer=['Toetsing'] ;
disp(uitvoer)
disp('')

uitvoer=['Geschatte waarden voor toevallige reciproque afwijkingen rdakje:'] ;
disp(uitvoer)
print_vector(rdakje, 'rdakje', 5) ;
disp('')

uitvoer=['Gewichtscoefficientenmatrix voor toevallige reciproque afwijkingen rdakje:'] ;
disp(uitvoer)
Qrdakje
disp('')

nabla_dakje = inv(C' * Qrdakje * C) * C' * rdakje ;
uitvoer=['Schatting grootte van gemaakte fouten nabla_dakje:'] ;
disp(uitvoer)
print_vector(nabla_dakje, 'nabla_dakje', 5) ;
disp('')

nabla_ydakje = C * nabla_dakje ;
uitvoer=['Schatting gemaakte fouten in waarnemingen nabla_ydakje:'] ;
disp(uitvoer)
print_vector(nabla_ydakje, 'nabla_ydakje', 5) ;
disp('')

Vq = rdakje' * nabla_ydakje ;
uitvoer=['Verschuivingsgrootheid Vq:'] ;
disp(uitvoer)
print_vector(Vq, 'Vq', 4) ;
disp('')

Tq = Vq / variantie_factor ;
uitvoer=['Toetsingsgrootheid Tq:'] ;
disp(uitvoer)
print_vector(Tq, 'Tq', 4) ;
disp('')

Fq = Tq / vrijheids_graden ;
uitvoer=['Toetsingsgrootheid Fq:'] ;
disp(uitvoer)
print_vector(Fq, 'Fq', 5) ;
disp('')


# conventionele w-toets
w_toetsgrootheid = w_toets(edakje, Qedakje, variantie_factor) ;
uitvoer=['Conventionele w-toetsgrootheden'] ;
disp(uitvoer)
print_vector(w_toetsgrootheid, 'w-', 4) ;
disp('')

w_toets_nabla_0 = w_toets_grenswaarden_y(Qrdakje, variantie_factor) ;
uitvoer=['Grenswaarden conventionele w-toets:'] ;
disp(uitvoer)
print_vector(w_toets_nabla_0, 'nabla_0_', 4) ;
disp('')

w_toets_sqrt_lambda_y = w_toets_norm_grenswaarden_y(w_toets_nabla_0, var_y) ;
uitvoer=['Genormaliseerde grenswaarden y conventionele w-toets:'] ;
disp(uitvoer)
print_vector(w_toets_sqrt_lambda_y, 'sqrt_lamda_y_', 4) ;
disp('')

w_toets_redundantie_y =  lambda_0 * w_toets_sqrt_lambda_y .^-2 ;
uitvoer=['Redundantiegetal y conventionele w-toets:'] ;
disp(uitvoer)
print_vector(w_toets_redundantie_y, 'h_', 3) ;
disp('')

# Controle
som_redundantie = sum(w_toets_redundantie_y) ;

uitvoer=['Controle op som der redundanties = aantal voorwaarden:'] ;
disp(uitvoer)
print_vector(som_redundantie, 'som', 4) ;
disp('')

uitvoer=['Aantal voorwaarden: ' num2str(aantal_voorwaarden)] ;
disp(uitvoer)
uitvoer=['Aantal waarnemingen: ' num2str(aantal_y)] ;
disp(uitvoer)
uitvoer=['Gemiddelde redundantie: ' num2str(aantal_voorwaarden / aantal_y)] ;
disp(uitvoer)
disp(' ')


w_toets_nabla_0_x = w_toets_grenswaarden_x(Qxdakje, A, Wy, w_toets_nabla_0) ;
uitvoer=['Grenswaarden xdakje conventionele w-toets:'] ;
disp(uitvoer)
aantal = size(w_toets_nabla_0_x, 2) ;
for i=1:aantal
  uitvoer=['Voor waarneming: ' num2str(i)] ;
  disp(uitvoer)

  w_toets_nabla_0_xi = w_toets_nabla_0_x(:,i) ;
  print_vector(w_toets_nabla_0_xi, 'nabla_0_x_', 4) ;
  disp('')
end

w_toets_sqrt_lambda_xdakje = sqrt( w_toets_sqrt_lambda_y .^2 - lambda_0 ) ;
uitvoer=['Verstoringsfactor xdakje conventionele w-toets:'] ;
disp(uitvoer)
print_vector(w_toets_sqrt_lambda_xdakje, 'sqrt_lamda_xdakje_', 4) ;
disp('')


# Algemene F-toets
F_toetsgrootheid = F_toets_Amodel(aantal_voorwaarden, variantie_factor, Qy, edakje) ;

uitvoer=['Algemene F-toetsgrootheid via geschatte toevallige afwijkingen'] ;
disp(uitvoer)
print_vector(F_toetsgrootheid, 'F-', 4) ;
disp('')
