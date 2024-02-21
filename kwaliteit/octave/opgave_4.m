# Opgave 4
# Volgens A-model

addpath ("./lib")

# Volgens B-methode van toetsen: γ0 = 0.8 en α0 = 0.001
lambda_0 = 17.075 ;

# Gegeven
var_y = [ 1 * 10^-4 ; 1 * 10^-4 ; 1 * 10^-4 ] ;
# Covariantiematrix
Dy = diag(var_y) ;

variantie_factor = 1 * 10^-4 ;

# Gewichtscoefficientenmatrix
Qy = Dy / variantie_factor ;
# Gewichtsmatrix
Wy = inv(Qy) ;

# Gegeven
y = [ 27.18 ; 24.98 ; 37.12 ] ;
a0 = [ 0 ; 0 ; 0 ] ;

xA = 0 ;
yA = 0 ;

xB = 50 ;
yB = 0 ;

xC = 20 ;
yC = 45 ;

vaste_punten = [ xA xB xC ; yA yB yC ]

# Vergelijkingen
function [ y0 ] = A_non_linear(u = 0, v = 0, punten)
  xA = punten(1, 1) ;
  yA = punten(2, 1) ;

  xB = punten(1, 2) ;
  yB = punten(2, 2) ;

  xC = punten(1, 3) ;
  yC = punten(2, 3) ;

  y1_0 = sqrt( (u - xA)^2 + (v - yA)^2 ) ;
  y2_0 = sqrt( (u - xC)^2 + (yC - v)^2 ) ;
  y3_0 = sqrt( (xB - u)^2 + (v - yB)^2 ) ;

  y0 = [ y1_0 ; y2_0 ; y3_0 ] ;
end

function [ dxA_x0 ] = dxA(u = 0, v = 0, punten)
  xA = punten(1, 1) ;
  yA = punten(2, 1) ;

  xB = punten(1, 2) ;
  yB = punten(2, 2) ;

  xC = punten(1, 3) ;
  yC = punten(2, 3) ;

  dy1_du = (u - xA) / sqrt( (u - xA)^2 + (v - yA)^2 ) ;
  dy1_dv = (v - yA) / sqrt( (u - xA)^2 + (v - yA)^2 ) ;

  dy2_du = (u - xC) / sqrt( (u - xC)^2 + (yC - v)^2 ) ;
  dy2_dv = -(yC - v) / sqrt( (u - xC)^2 + (yC - v)^2 ) ;

  dy3_du = -(xB - u) / sqrt( (xB - u)^2 + (v - yB)^2 ) ;
  dy3_dv = (v - yB) / sqrt( (xB - u)^2 + (v - yB)^2 ) ;

  dxA_x0 = [ dy1_du dy1_dv ; dy2_du dy2_dv ; dy3_du dy3_dv ] ;
end

# Benaderde waarden
u0 = 20 ;
v0 = 20 ;

y0 = A_non_linear(u0, v0, vaste_punten) ;
dxA_x0 = dxA(u0, v0, vaste_punten) ;

delta_y = y - y0 ;
A = dxA_x0 ;

aantal_y = size(A,1) ;
aantal_x = size(A,2) ;
aantal_voorwaarden = aantal_y - aantal_x ;

# Opgave 18c1
C = [ 1 ; 0 ; 0 ] ;
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
xdakje = [ u0 + delta_xdakje(1) ; v0 + delta_xdakje(2) ] ;

uitvoer=['Berekende waarden voor parameters xdakje:'] ;
disp(uitvoer)
print_vector(xdakje, 'xdakje', 4) ;
disp('')

ydakje = delta_ydakje + y0 ;

uitvoer=['Berekende waarden voor vereffende waarnemingen ydakje volgens gelineariseerde vergelijkingen:'] ;
disp(uitvoer)
print_vector(ydakje, 'ydakje', 4) ;
disp('')

y_non_linear = A_non_linear(xdakje(1), xdakje(2), vaste_punten) ;

uitvoer=['Berekende waarden voor vereffende waarnemingen y_non_linear volgens niet-lineaire vergelijkingen:'] ;
disp(uitvoer)
print_vector(y_non_linear, 'y_non_linear', 4) ;
disp('')

edakje_non_linear = y - y_non_linear ;

uitvoer=['Berekende waarden voor toevallige afwijkingen edakje_non_linear volgens niet-lineaire vergelijkingen:'] ;
disp(uitvoer)
print_vector(edakje_non_linear, 'edakje_non_linear', 4) ;
disp('')


disp('#########################################################################################')
disp('# Iteratie 1 - start')
disp('#########################################################################################')
disp('')

# Benaderde waarden
u0 = xdakje(1) ;
v0 = xdakje(2) ;

y0 = A_non_linear(u0, v0, vaste_punten) ;
dxA_x0 = dxA(u0, v0, vaste_punten) ;

delta_y = y - y0 ;
A = dxA_x0 ;

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
xdakje = [ u0 + delta_xdakje(1) ; v0 + delta_xdakje(2) ] ;

uitvoer=['Berekende waarden voor parameters xdakje:'] ;
disp(uitvoer)
print_vector(xdakje, 'xdakje', 4) ;
disp('')

ydakje = delta_ydakje + y0 ;

uitvoer=['Berekende waarden voor vereffende waarnemingen ydakje volgens gelineariseerde vergelijkingen:'] ;
disp(uitvoer)
print_vector(ydakje, 'ydakje', 4) ;
disp('')

y_non_linear = A_non_linear(xdakje(1), xdakje(2), vaste_punten) ;

uitvoer=['Berekende waarden voor vereffende waarnemingen y_non_linear volgens niet-lineaire vergelijkingen:'] ;
disp(uitvoer)
print_vector(y_non_linear, 'y_non_linear', 4) ;
disp('')

edakje_non_linear = y - y_non_linear ;

uitvoer=['Berekende waarden voor toevallige afwijkingen edakje_non_linear volgens niet-lineaire vergelijkingen:'] ;
disp(uitvoer)
print_vector(edakje_non_linear, 'edakje_non_linear', 4) ;
disp('')

disp('#########################################################################################')
disp('# Iteratie 1 - eind')
disp('#########################################################################################')
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

