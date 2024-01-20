# Kleinste-kwadratenvereffening volgens A-model

# Input
# - modelmatrix
# - vector met waarnemingen
# - vector met constante termen, default 0
# - gewichtscoefficientenmatrix, default 0

# Output
# - geschatte waarden voor parameters
# - waarden voor vereffende waarnemingen
# - geschatte waarden voor toevallige afwijkingen en reciproque
# - matrices van gewichtscoefficienten

function [xdakje , ydakje , edakje, rdakje, Qxdakje, Qydakje, Qedakje, Qrdakje] = A_vereffening(A, y, a0 = 0, Qy = 0)
  nr=size(y,1) ;

  if (a0 == 0)
    a0 = zeros(nr,1) ;
    eentjes = ones(nr,1) ;
  endif

  if (Qy == 0)
    Qy = diag(eentjes) ;
  endif

# Gewichtsmatrix
  Wy = inv(Qy) ;

# Normaal_matrix
  N = A' * Wy * A ;
# Rechterlid normaalvergelijking
  n = A' * Wy * ( y - a0 ) ;
# Geschatte parameter uit normaalvergelijking
  xdakje = inv(N) * n ;

# Vereffende waarneming
  ydakje = A * xdakje + a0 ;
# Geschatte toevallige afwijkingen
  edakje = y - ydakje ;
# Geschatte reciproque toevallige afwijkingen
  rdakje = Wy * edakje ;

# Matrices van gewichtscoefficienten
  Qxdakje = inv(N) ;
  Qydakje = A * Qxdakje * A' ;
  Qedakje = Qy - Qydakje ;
  Qrdakje = inv(Qy) * Qedakje * inv(Qy) ;

end
