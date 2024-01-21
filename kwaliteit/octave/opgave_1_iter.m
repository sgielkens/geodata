# Opgave 1
# Volgens A-model, iteratief

addpath ("./lib")

x0 = 1 ;
iter_crit = 0.1 ;
iter_max = 9 ;

i = 0 ;
xdakje = x0 ;

do
  uitvoer=['### Iteratiestap ' num2str(i) ' ###'] ;
  disp(uitvoer)
  disp('')

  x = xdakje ;

  # Gegeven
  y = [2; 6] ;
  A = [ 1 ; 1/sqrt(x) ] ;
  a0 = [ 0 ; sqrt(x) ] ;

  # Vereffening volgens A-model
  [ xdakje , ydakje , edakje ] = Amodel(A, y, a0) ;

  uitvoer=['Geschatte waarden voor parameters xdakje:'] ;
  disp(uitvoer)
  print_vector(xdakje, 'xdakje', 3) ;
  disp('')

  uitvoer=['Geschatte waarden voor toevallige afwijkingen edakje:'] ;
  disp(uitvoer)
  print_vector(edakje, 'edakje', 4) ;
  disp('')

  uitvoer=['Waarden voor vereffende waarneming ydakje = A * xdakje + a0:'] ;
  disp(uitvoer)
  print_vector(ydakje, 'ydakje', 3) ;
  disp('')

  # Controle
  nullen = A' * edakje ;

  uitvoer=['Controle op A'' * edakje = 0'] ;
  disp(uitvoer)
  print_vector(nullen, 'nullen', 4) ;
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


