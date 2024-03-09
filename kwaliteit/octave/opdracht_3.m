# Opdracht 3
# Volgens A-model

addpath ("./lib")

# Volgens B-methode van toetsen: γ0 = 0.8 en α0 = 0.001
lambda_0 = 17.075 ;

# Puntenveld uit opdracht 2 na vereffening
uP = 0.0014 ;
vP = 0.0015 ;

uB1 = 400 ;
vB1 = 0 ;

uB2 = 70 ;
vB2 = 300 ;

uB3 = -400 ;
vB3 = 100 ;

uB4 = -200 ;
vB4 = -300 ;

uB5 = 300 ;
vB5 = -400 ;

crs1 = [ uP uB1 uB2 uB3 uB4 uB5 ;
          vP vB1 vB2 vB3 vB4 vB5 ] ;

# Ruis in mm
Pn = [ -4.1 ; -2.0 ] ;
B1n = [ -0.2 ; 4.0 ] ;
B2n = [ -0.1 ; 1.8 ] ;
B3n = [ -1.3 ; 1.0 ] ;
B4n = [ 2.6 ; 4.1 ] ;
B5n = [ 1.3 ; -3.0 ] ;

noise = [ Pn B1n B2n B3n B4n B5n ] ;
noise = noise / 1000 ;

crs1_noise = crs1 + noise ;

# Transformatieparameters
phi = -0.15 ; # in rad
lambda = 0.1 ;

tu = 135237.93 ;
tv = 455509.29 ;

t = [ tu ; tv ] ;
R = [ cos(phi) sin(phi) ; -sin(phi) cos(phi) ] ;

# Getransformeerde parameters
aantal_punten = size(crs1, 2) ;
eT = ones(1, aantal_punten) ;

crs2 = lambda * R * crs1_noise + t * eT ;

uT = crs1(1,:) ;
vT = crs1(2,:) ;
u = uT' ;
v = vT' ;

ufT = crs2(1,:) ;
vfT = crs2(2,:) ;
uf = ufT' ;
vf = vfT' ;

y = [ uf ;
      vf ] ;

# Als onbekende parameters worden gekozen: p, q, tx, ty
e = eT' ;
nT = zeros(1, aantal_punten) ;
n = nT' ;

A = [ u v e n ;
      v -u n e ] ;

aantal_y = size(A,1) ;
aantal_x = size(A,2) ;
aantal_voorwaarden = aantal_y - aantal_x ;

# Gegeven
a0 = zeros( size(A,1) , 1) ;

var_y = ones(aantal_y,1) ;
var_y = var_y * 1e-8 ;

# Instelparameter
var_factor = 4 ;
var_y = var_y * var_factor ;

# Covariantiematrix
Dy = diag(var_y) ;

variantie_factor = 10^-8 ;
variantie_factor = variantie_factor * var_factor ;

# Gewichtscoefficientenmatrix
Qy = Dy / variantie_factor ;
# Gewichtsmatrix
Wy = inv(Qy) ;

# Vereffening volgens gewogen A-model
[ xdakje , ydakje , edakje, rdakje, Qxdakje, Qydakje, Qedakje, Qrdakje ] = A_vereffening(A, y, a0, Qy) ;

# Vereffening volgens A-model
uitvoer=['Geschatte waarden voor parameters xdakje:'] ;
disp(uitvoer)
print_vector(xdakje, 'xdakje', 4) ;
disp('')

lambda
phi
tu
tv
disp('')

pdakje = xdakje(1) ;
qdakje= xdakje(2) ;
lambda_dakje = sqrt(pdakje^2 + qdakje^2)
phi_dakje = atan(qdakje/pdakje)
tu_dakje = xdakje(3)
tv_dakje = xdakje(4)
disp('')

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
#uitvoer=['-------------------------------------------------------'] ;
#disp(uitvoer)
#disp('')

##uitvoer=['Toetsing'] ;
##disp(uitvoer)
##disp('')
##
##uitvoer=['Geschatte waarden voor toevallige reciproque afwijkingen rdakje:'] ;
##disp(uitvoer)
##print_vector(rdakje, 'rdakje', 5) ;
##disp('')
##
##uitvoer=['Gewichtscoefficientenmatrix voor toevallige reciproque afwijkingen rdakje:'] ;
##disp(uitvoer)
##Qrdakje
##disp('')
##
##nabla_dakje = inv(C' * Qrdakje * C) * C' * rdakje ;
##uitvoer=['Schatting grootte van gemaakte fouten nabla_dakje:'] ;
##disp(uitvoer)
##print_vector(nabla_dakje, 'nabla_dakje', 5) ;
##disp('')
##
##nabla_ydakje = C * nabla_dakje ;
##uitvoer=['Schatting gemaakte fouten in waarnemingen nabla_ydakje:'] ;
##disp(uitvoer)
##print_vector(nabla_ydakje, 'nabla_ydakje', 5) ;
##disp('')
##
##Vq = rdakje' * nabla_ydakje ;
##uitvoer=['Verschuivingsgrootheid Vq:'] ;
##disp(uitvoer)
##print_vector(Vq, 'Vq', 4) ;
##disp('')
##
##Tq = Vq / variantie_factor ;
##uitvoer=['Toetsingsgrootheid Tq:'] ;
##disp(uitvoer)
##print_vector(Tq, 'Tq', 4) ;
##disp('')
##
##Fq = Tq / vrijheids_graden ;
##uitvoer=['Toetsingsgrootheid Fq:'] ;
##disp(uitvoer)
##print_vector(Fq, 'Fq', 5) ;
##disp('')


# conventionele w-toets
w_toetsgrootheid = w_toets(edakje, Qedakje, variantie_factor) ;
uitvoer=['Conventionele w-toetsgrootheden'] ;
disp(uitvoer)
print_vector(w_toetsgrootheid, 'w-', 4) ;
disp('')

w_toets_nabla_0 = w_toets_grenswaarden_y(Qrdakje, variantie_factor) ;
uitvoer=['Grenswaarden conventionele w-toets:'] ;
disp(uitvoer)
print_vector(w_toets_nabla_0, 'nabla_0_', 5) ;
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
  print_vector(w_toets_nabla_0_xi, 'nabla_0_x_', 8) ;
  disp('')
end

# Hoogste waarden
aantal = size(w_toets_nabla_0_x, 1) ;
for i=1:aantal
  uitvoer=['Maximale grenswaarde xdakje voor parameter: ' num2str(i)] ;
  disp(uitvoer)
  w_toets_nabla_0_x_max = max( abs( w_toets_nabla_0_x(i,:) ) )
  sort(w_toets_nabla_0_x(i,:))
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

