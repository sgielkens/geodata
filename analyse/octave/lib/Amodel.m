# Kleinste-kwadratenvereffening volgens A-model

# Input
# - modelmatrix
# - vector met waarnemingen
# - vector met constante termen, default 0
# - gewichtsmatrix, default 0

# Output
# - geschatte waarden voor parameters
# - waarden voor vereffende waarnemingen
# - geschatte waarden voor toevallige afwijkingen


function [ xdakje , ydakje , edakje] = Amodel_oud(A, y, a0 = 0, Wy = 0)
  if (a0 == 0)
    nr=size(y,1) ;
    a0 = zeros(nr,1) ;
  endif

  if (Wy == 0)
    xdakje = inv (A' * A) * A' * (y - a0) ;
  else
    xdakje = inv(A' * Wy * A) * A' * Wy * (y - a0) ;
  endif

  ydakje = A * xdakje + a0 ;
  edakje = y - ydakje ;

end
