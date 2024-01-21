# Opgave 1
# Volgens A-model, iteratief

addpath ("./lib")

x0 = (40/200) * pi ;
iter_crit = 0.01 ;
iter_max = 9 ;

i = 0 ;
xdakje = x0 ;

do
  uitvoer=['### Iteratiestap ' num2str(i) ' ###'] ;
  disp(uitvoer)
  disp('')

  x = xdakje ;

  # Gegeven
  y = [ 3.12 ; 3.80 ] ;
  A = [ 5 * cos(x) ; -5 * sin(x) ] ;
  a0 = [ 5 * (sin(x) - x * cos(x)) ; 5 * (cos(x) + x * sin(x)) ] ;

  # Vereffening volgens A-model
  [ xdakje , ydakje , edakje ] = Amodel(A, y, a0) ;

  uitvoer=['Geschatte waarden voor parameters xdakje:'] ;
  disp(uitvoer)
  print_vector(xdakje, 'xdakje', 5) ;
  disp('')

  uitvoer=['Geschatte waarden voor toevallige afwijkingen edakje:'] ;
  disp(uitvoer)
  print_vector(edakje, 'edakje', 6) ;
  disp('')

  uitvoer=['Waarden voor vereffende waarneming ydakje = A * xdakje + a0:'] ;
  disp(uitvoer)
  print_vector(ydakje, 'ydakje', 3) ;
  disp('')

  # Controle
  nullen = A' * edakje ;

  uitvoer=['Controle op A'' * edakje = 0'] ;
  disp(uitvoer)
  print_vector(nullen, 'nullen', 6) ;
  disp('')

  diff = xdakje - x ;
  i++ ;

  uitvoer=['-------------------------------------------------------'] ;
  disp(uitvoer)
  disp('')
until (abs(diff) < iter_crit || (i > iter_max))

uitvoer = ['### Samenvatting ###'] ;
disp(uitvoer)

uitvoer = ['Startwaarde parameter: ' num2str(x0)] ;
disp(uitvoer)
uitvoer = ['Iteratiecriterium: ' num2str(iter_crit)] ;
disp(uitvoer)

uitvoer = ['Aantal iteraties: ' num2str(i-1)] ;
disp(uitvoer)
uitvoer = ['Verschil laatste iteratie x(n) - x(n-1): ' num2str(diff)] ;
disp(uitvoer)
disp('')

uitvoer=['Geschatte waarden voor parameters xdakje in gon:'] ;
disp(uitvoer)
print_vector(xdakje * (200/pi), 'xdakje', 5) ;
disp('')



