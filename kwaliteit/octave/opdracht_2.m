# Opdracht 2
# Volgens A-model

addpath ("./lib")

# Volgens B-methode van toetsen: γ0 = 0.8 en α0 = 0.001
lambda_0 = 17.075 ;

# Gegeven
y= [
  399.9992 ;
  308.0570 ;
  412.3117 ;
  360.5578 ;
  500.0000
] ;

a0 = 0 ;

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

vaste_punten = [ uB1 uB2 uB3 uB4 uB5 ; vB1 vB2 vB3 vB4 vB5 ] ;

std_vast = 0.001 ;
std_rel = 1.5e-6 ;

std_afw = y * std_rel + std_vast
var_y = std_afw.^2 ;

# Covariantiematrix
Dy = diag(var_y) ;

variantie_factor = 2 * 10^-6 ;

# Gewichtscoefficientenmatrix
Qy = Dy / variantie_factor ;
# Gewichtsmatrix
Wy = inv(Qy) ;


# Vergelijkingen
function [ y0 ] = A_non_linear(uP = 0, vP = 0, punten)
  uB1 = punten(1, 1) ;
  vB1 = punten(2, 1) ;

  uB2 = punten(1, 2) ;
  vB2 = punten(2, 2) ;

  uB3 = punten(1, 3) ;
  vB3 = punten(2, 3) ;

  uB4 = punten(1, 4) ;
  vB4 = punten(2, 4) ;

  uB5 = punten(1, 5) ;
  vB5 = punten(2, 5) ;

  y1_0 = sqrt( (uP - uB1)^2 + (vP - vB1)^2 ) ;
  y2_0 = sqrt( (uP - uB2)^2 + (vP - vB2)^2 ) ;
  y3_0 = sqrt( (uP - uB3)^2 + (vP - vB3)^2 ) ;
  y4_0 = sqrt( (uP - uB4)^2 + (vP - vB4)^2 ) ;
  y5_0 = sqrt( (uP - uB5)^2 + (vP - vB5)^2 ) ;


  y0 = [ y1_0 ; y2_0 ; y3_0 ; y4_0 ; y5_0 ] ;
end

function [ dxA_x0 ] = dxA(uP = 0, vP = 0, punten)
  uB1 = punten(1, 1) ;
  vB1 = punten(2, 1) ;

  uB2 = punten(1, 2) ;
  vB2 = punten(2, 2) ;

  uB3 = punten(1, 3) ;
  vB3 = punten(2, 3) ;

  uB4 = punten(1, 4) ;
  vB4 = punten(2, 4) ;

  uB5 = punten(1, 5) ;
  vB5 = punten(2, 5) ;

  dy1_duP = (uP - uB1) / sqrt( (uP - uB1)^2 + (vP - vB1)^2 ) ;
  dy1_dvP = (vP - vB1) / sqrt( (uP - uB1)^2 + (vP - vB1)^2 ) ;

  dy2_duP = (uP - uB2) / sqrt( (uP - uB2)^2 + (vP - vB2)^2 ) ;
  dy2_dvP = (vP - vB2) / sqrt( (uP - uB2)^2 + (vP - vB2)^2 ) ;

  dy3_duP = (uP - uB3) / sqrt( (uP - uB3)^2 + (vP - vB3)^2 ) ;
  dy3_dvP = (vP - vB3) / sqrt( (uP - uB3)^2 + (vP - vB3)^2 ) ;

  dy4_duP = (uP - uB4) / sqrt( (uP - uB4)^2 + (vP - vB4)^2 ) ;
  dy4_dvP = (vP - vB4) / sqrt( (uP - uB4)^2 + (vP - vB4)^2 ) ;

  dy5_duP = (uP - uB5) / sqrt( (uP - uB5)^2 + (vP - vB5)^2 ) ;
  dy5_dvP = (vP - vB5) / sqrt( (uP - uB5)^2 + (vP - vB5)^2 ) ;

  dxA_x0 = [ dy1_duP dy1_dvP ; dy2_duP dy2_dvP ; dy3_duP dy3_dvP ; dy4_duP dy4_dvP ; dy5_duP dy5_dvP ] ;
end

# Benaderde waarden
x0 = [ 1 ; 1 ] ;

iter_crit = 0.0001 ;
iter_max = 5 ;

i = 0 ;

do
  uitvoer=['### Iteratiestap ' num2str(i) ' ###'] ;
  disp(uitvoer)
  disp('')

  uP0 = x0(1) ;
  vP0 = x0(2) ;

  y0 = A_non_linear(uP0, vP0, vaste_punten)
  dxA_x0 = dxA(uP0, vP0, vaste_punten)

  delta_y = y - y0
  A = dxA_x0 ;

  aantal_y = size(A,1) ;
  aantal_x = size(A,2) ;
  aantal_voorwaarden = aantal_y - aantal_x ;

  # Vereffening volgens gewogen A-model
  [ delta_xdakje , delta_ydakje , edakje, rdakje, Qxdakje, Qydakje, Qedakje, Qrdakje ] = A_vereffening(A, delta_y, a0, Qy) ;

  # Vereffening volgens A-model

  uitvoer=['Geschatte waarden voor parameters delta_xdakje:'] ;
  disp(uitvoer)
  print_vector(delta_xdakje, 'delta_xdakje', 4) ;
  disp('')

  # Standaardafwijking van geschatte parameters
  Dxdakje = variantie_factor * Qxdakje ;
  sigma_xdakje = sqrt( diag(Dxdakje) );

  uitvoer=['Standaardafwijking van geschatte coordinaten:'] ;
  disp(uitvoer)
  print_vector(sigma_xdakje, 'sigma_xdakje', 6) ;
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
  xdakje = [ uP0 + delta_xdakje(1) ; vP0 + delta_xdakje(2) ] ;

  uitvoer=['Berekende waarden voor parameters xdakje:'] ;
  disp(uitvoer)
  print_vector(xdakje, 'xdakje', 4) ;
  disp('')

  ydakje = delta_ydakje + y0 ;

  uitvoer=['Berekende waarden voor vereffende waarnemingen ydakje volgens gelineariseerde vergelijkingen:'] ;
  disp(uitvoer)
  print_vector(ydakje, 'ydakje', 5) ;
  disp('')

  ydakje_non_linear = A_non_linear(xdakje(1), xdakje(2), vaste_punten) ;

  uitvoer=['Berekende waarden voor vereffende waarnemingen ydakje_non_linear volgens niet-lineaire vergelijkingen:'] ;
  disp(uitvoer)
  print_vector(ydakje_non_linear, 'ydakje_non_linear', 5) ;
  disp('')

  edakje_non_linear = y - ydakje_non_linear ;

  uitvoer=['Berekende waarden voor toevallige afwijkingen edakje_non_linear volgens niet-lineaire vergelijkingen:'] ;
  disp(uitvoer)
  print_vector(edakje_non_linear, 'edakje_non_linear', 4) ;
  disp('')

  abs_diff = norm(delta_xdakje) ;
  i++ ;
  x0 = xdakje ;

  uitvoer=['Norm van delta_xdakje: ' num2str(abs_diff)] ;
  disp(uitvoer)
  disp('')
until ( (abs_diff < iter_crit) || (i > iter_max) )



# Toetsing
##uitvoer=['-------------------------------------------------------'] ;
##disp(uitvoer)
##disp('')
##
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


aantal_y = size(A,1) ;
aantal_x = size(A,2) ;
aantal_voorwaarden = aantal_y - aantal_x ;


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

