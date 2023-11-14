# w-toets volgens B-model

# Input
# - gewichtscoefficientenmatrix van toevallige afwijkingen
# - a priori variantiefactor

# Output
# - w-toetsgrootheden

function [ w_toetsgrootheid ] = w_toets(edakje, Qedakje, variantie_factor_priori)

  Dedakje = variantie_factor_priori * Qedakje ;

  edakje_variantie = diag(Dedakje) ;
  edakje_stdev = sqrt(edakje_variantie) ;

  aantal = size(edakje,1) ;
  w_toetsgrootheid = zeros(aantal,1) ;

  for i=1:aantal
    w_toetsgrootheid(i) = edakje(i) / edakje_stdev(i) ;
  end

end
