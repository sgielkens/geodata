# F-toets

# Input
# - Cofactorenmatrix
# - a priori variantiefactor
# - toevallige afwijkingen

# Output
# - F-toetsgrootheid

function F_toetsgrootheid = F_toets_Bmodel(vrijheidsgraden, variantie_factor_priori, Qt, t_sluit)

# Verschuivingsgrootheid
  Vb = t_sluit' * inv(Qt) * t_sluit ;
  variantie_factor_posteriori = Vb / vrijheidsgraden ;

  F_toetsgrootheid = variantie_factor_posteriori / variantie_factor_priori ;

end
