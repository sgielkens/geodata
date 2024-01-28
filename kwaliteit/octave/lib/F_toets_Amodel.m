# F-toets

# Input
# - Gewichtscoefficientenmatrix
# - a priori variantiefactor
# - toevallige afwijkingen

# Output
# - F-toetsgrootheid

function F_toetsgrootheid = F_toets_Amodel(vrijheidsgraden, variantie_factor_priori, Qy, edakje)

# Verschuivingsgrootheid
  Vb = edakje' * inv(Qy) * edakje ;
  variantie_factor_posteriori = Vb / vrijheidsgraden ;

  F_toetsgrootheid = variantie_factor_posteriori / variantie_factor_priori ;

end
