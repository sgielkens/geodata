# grenswaarden bij w-toets conventioneel

# Input
# - gewichtscoefficientenmatrix van geschatte toevallige recoproque afwijkingen
# - a priori variantiefactor

# Output
# - grenswaarden

function [ w_toets_nabla_0 ] = w_toets_grenswaarden(Qrdakje, variantie_factor_priori)

# Volgens B-methode van toetsen: γ0 = 0.8 en α0 = 0.001
  lambda_0 = 17.075 ;

  aantal = size(Qrdakje,1) ;
  w_toets_nabla_0 = zeros(aantal,1) ;

  factor_const = variantie_factor_priori * lambda_0 ;

  Qrdakje_diag = diag(Qrdakje) ;

  for i=1:aantal
    w_toets_nabla_0(i) = sqrt( factor_const / Qrdakje_diag(i) ) ;
  end

end
