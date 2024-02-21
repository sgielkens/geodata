# Opgave 6
# Volgens A-model

addpath ("./lib")

# Volgens B-methode van toetsen: γ0 = 0.8 en α0 = 0.001
lambda_0 = 17.075 ;

# Gegeven
var_y = [ 0.09 * pi^2 ; 0.09 * pi^2 ; 0.09 * pi^2 ; 2.25 ; 2.25 ] ;
variantie_factor = 1 * 10^-10 ;

# Gewichtscoefficientenmatrix
Qy = diag(var_y) ;
# Gewichtsmatrix
Wy = inv(Qy) ;

# Covariantiematrix
Dy = Qy * variantie_factor ;

# Gegeven
y = [ (100.0011 / 200) * pi ; (50.0021 / 200) * pi ; (49.998 / 200) * pi ; 1500.11 / 1000 ; 1499.94 / 1000 ] ;
a0 = [ 0 ; 0 ; 0 ; 0 ; 0 ] ;

# Vergelijkingen
function [ y0 ] = A_non_linear(aA = 0, aB = 0, sAB = 0)
  y1_0 = aA ;
  y2_0 = aB ;
  y3_0 = pi - aA - aB ;
  y4_0 = sAB ;
  y5_0 = sAB * sin(aB)/sin(aA + aB) ;

  y0 = [ y1_0 ; y2_0 ; y3_0 ; y4_0 ; y5_0 ] ;
end

function [ dxA_x0 ] = dxA(aA = 0, aB = 0, sAB = 0)
  dy1_daA = 1 ;
  dy1_daB = 0 ;
  dy1_dsAB = 0 ;

  dy2_daA = 0 ;
  dy2_daB = 1 ;
  dy2_dsAB = 0 ;

  dy3_daA = -1 ;
  dy3_daB = -1 ;
  dy3_dsAB = 0 ;

  dy4_daA = 0 ;
  dy4_daB = 0 ;
  dy4_dsAB = 1 ;

  dy5_daA = -sAB * sin(aB) * cos(aA + aB) * sin(aA + aB)^-2 ;
  dy5_daB = sAB * ( cos(aB) * sin(aA + aB)^-1 - sin(aB) * cos(aA + aB) * sin(aA + aB)^-2 ) ;
  dy5_dsAB = sin(aB) / sin(aA + aB) ;

  dxA_x0 = [ dy1_daA dy1_daB dy1_dsAB ;
             dy2_daA dy2_daB dy2_dsAB ;
             dy3_daA dy3_daB dy3_dsAB ;
             dy4_daA dy4_daB dy4_dsAB ;
             dy5_daA dy5_daB dy5_dsAB ] ;
end

# Benaderde waarden
aA0 = pi / 2 ;
aB0 = pi / 4 ;
sAB0 = 1500 / 1000 ;
x0 = [ aA0 ; aB0 ; sAB0 ] ;

iter_crit = 1*10^-10 ;
iter_max = 3 ;

i = 0 ;

do
  uitvoer=['### Iteratiestap ' num2str(i) ' ###'] ;
  disp(uitvoer)
  disp('')

  y0 = A_non_linear(x0(1), x0(2), x0(3)) ;
  dxA_x0 = dxA(x0(1), x0(2), x0(3)) ;

  delta_y = y - y0 ;
  A = dxA_x0 ;

  aantal_y = size(A,1) ;
  aantal_x = size(A,2) ;
  aantal_voorwaarden = aantal_y - aantal_x ;

  # Opgave 18c1
  C = [ 1 ; 0 ; 0 ; 0 ; 0] ;
  # Opgave 18c2
  # C = [ 0 ; 0 ; 0 ; 1 ; 0 ] ;
  # Opgave 18d
  # C = [ 1 0 ; -1 0 ; 0 0 ; 0 1 ; 0 0 ] ;
  vrijheids_graden = size(C,2) ;

  # Vereffening volgens gewogen A-model
  [ delta_xdakje , delta_ydakje , edakje, rdakje, Qxdakje, Qydakje, Qedakje, Qrdakje ] = A_vereffening(A, delta_y, a0, Qy) ;

  # Vereffening volgens A-model

  uitvoer=['Geschatte waarden voor parameters delta_xdakje:'] ;
  disp(uitvoer)
  print_vector(delta_xdakje, 'delta_xdakje', 4) ;
  disp('')

  uitvoer=['Geschatte waarden voor toevallige afwijkingen edakje:'] ;
  disp(uitvoer)
  print_vector(edakje, 'edakje', 5) ;
  disp('')

  uitvoer=['Waarden voor vereffende waarnemingen delta_ydakje = A * delta_xdakje + a0:'] ;
  disp(uitvoer)
  print_vector(delta_ydakje, 'delta_ydakje', 4) ;
  disp('')

  # Controle
  nullen = A' * Wy * edakje ;

  uitvoer=['Controle op A'' * Wy * edakje = 0'] ;
  disp(uitvoer)
  print_vector(nullen, 'nullen', 4) ;
  disp('')

  # Berekende resultaten
  xdakje = [ x0(1) + delta_xdakje(1) ; x0(2) + delta_xdakje(2) ; x0(3) + delta_xdakje(3) ] ;

  uitvoer=['Berekende waarden voor parameters xdakje:'] ;
  disp(uitvoer)
  print_vector(xdakje, 'xdakje', 4) ;
  disp('')

  ydakje = delta_ydakje + y0 ;

  uitvoer=['Berekende waarden voor vereffende waarnemingen ydakje volgens gelineariseerde vergelijkingen:'] ;
  disp(uitvoer)
  print_vector(ydakje, 'ydakje', 4) ;
  disp('')

  y_non_linear = A_non_linear(xdakje(1), xdakje(2), xdakje(3)) ;

  uitvoer=['Berekende waarden voor vereffende waarnemingen y_non_linear volgens niet-lineaire vergelijkingen:'] ;
  disp(uitvoer)
  print_vector(y_non_linear, 'y_non_linear', 4) ;
  disp('')

  edakje_non_linear = y - y_non_linear ;

  uitvoer=['Berekende waarden voor toevallige afwijkingen edakje_non_linear volgens niet-lineaire vergelijkingen:'] ;
  disp(uitvoer)
  print_vector(edakje_non_linear, 'edakje_non_linear', 4) ;
  disp('')


  abs_diff = norm(xdakje - x0) ;
  i++ ;
  x0 = xdakje ;

  uitvoer=['-------------------------------------------------------'] ;
  disp(uitvoer)
  disp('')
until ( (abs_diff < iter_crit) || (i > iter_max) )

uitvoer = ['### Samenvatting iteratie ###'] ;
disp(uitvoer)

uitvoer = ['Iteratiecriterium: ' num2str(iter_crit)] ;
disp(uitvoer)
uitvoer = ['Aantal iteraties: ' num2str(i-1)] ;
disp(uitvoer)
uitvoer = ['Verschil laatste 2 iteraties x(n) - x(n-1): ' num2str(abs_diff)] ;
disp(uitvoer)
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
w_toetsgrootheid = w_toets(edakje_non_linear, Qedakje, variantie_factor) ;
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
F_toetsgrootheid = F_toets_Amodel(aantal_voorwaarden, variantie_factor, Qy, edakje_non_linear) ;

uitvoer=['Algemene F-toetsgrootheid via geschatte toevallige afwijkingen'] ;
disp(uitvoer)
print_vector(F_toetsgrootheid, 'F-', 4) ;
disp('')

