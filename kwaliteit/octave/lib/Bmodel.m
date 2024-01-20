# Kleinste-kwadratenvereffening volgens B-model

# Input
# - modelmatrix
# - vector met waarnemingen
# - vector met constante termen, default 0
# - gewichtscoefficientenmatrix, default 0

# Output
# - waarden voor vereffende waarnemingen
# - geschatte waarden voor toevallige afwijkingen
# - sluittermen


function [ ydakje , edakje, t] = Bmodel(B, y, b0 = 0, Qy = 0)
  if (b0 == 0)
    nr=size(B,2) ;
    b0 = zeros(nr,1) ;
  endif

# Sluittermen
  t = B' * y - b0 ;

# Correlaten
  if (Qy == 0)
    k = inv(B' * B) * t ;
    edakje = B * k ;
  else
    k = inv(B' * Qy * B) * t ;
    edakje = Qy * B * k ;
  endif

  ydakje = y - edakje ;

end
