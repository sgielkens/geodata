# Kleinste-kwadratenvereffening volgens B-model

# Input
# - modelmatrix
# - vector met waarnemingen
# - vector met constante termen, default 0
# - gewichtscoefficientenmatrix, default 0

# Output
# - waarden voor vereffende waarnemingen
# - sluittermen
# - geschatte waarden voor toevallige afwijkingen en reciproque
# - matrices van gewichtscoefficienten

function [ydakje, edakje, t, Qt, rdakje, Qrdakje, Qedakje, Qydakje] = B_vereffening(B, y, b0 = 0, Qy = 0)
  nr_rij=size(B,2) ;
  nr_kolom=size(B,1) ;

  if (b0 == 0)
    b0 = zeros(nr_rij,1) ;
    eentjes = ones(nr_kolom,1) ;
  endif

  if (Qy == 0)
    Qy = diag(eentjes) ;
  endif

# Sluittermen
  t = B' * y - b0 ;
# Cofactorenmatrix
  Qt = B' * Qy * B ;
# Correlaten
  k = inv(Qt) * t ;

# Geschatte reciproque toevallige afwijkingen
  rdakje = B * k ;
# Geschatte toevallige afwijkingen
  edakje = Qy * rdakje ;
# Vereffende waarneming
  ydakje = y - edakje ;

# Matrices van gewichtscoefficienten
  Qrdakje = B * inv(Qt) * B' ;
  Qedakje = Qy * Qrdakje * Qy ;
  Qydakje = Qy - Qedakje ;

end
