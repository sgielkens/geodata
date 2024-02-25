# Opdracht 1d
# Volgens A-model

addpath ("./lib")

# Gegeven
var_y = [ 7.84 ; 6.76 ; 7.84 ; 7.29 ; 9.00 ] ;
var_y = var_y * 10^-6 ;
# Covariantiematrix
Dy = diag(var_y) ;

variantie_factor = 9 * 10^-6 ;

# Gewichtscoefficientenmatrix
Qy = Dy / variantie_factor ;
# Gewichtsmatrix
Wy = inv(Qy) ;

# Gegeven
y = [ 399.9972 ; 308.0578 ; 412.3118 ; 360.5547 ; 500.0054 ] ;
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

  abs_diff = norm(delta_xdakje) ;
  i++ ;
  x0 = xdakje ;

  uitvoer=['Norm van delta_xdakje: ' num2str(abs_diff)] ;
  disp(uitvoer)
  disp('')
until ( (abs_diff < iter_crit) || (i > iter_max) )

