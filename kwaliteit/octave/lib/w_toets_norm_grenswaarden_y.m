# genormaliseerde grenswaarden voor waarnemingen bij conventionele w-toets

# Input
# - gewichtscoefficientenmatrix van geschatte toevallige recoproque afwijkingen
# - a priori variantiefactor

# Output
# - grenswaarden van waarnemingen

function [ w_toets_sqrt_lambda_y ] = w_toets_norm_grenswaarden_y(w_toets_nabla_0, var_y)

  aantal = size(var_y,1) ;
  w_toets_sqrt_lambda_y = zeros(aantal,1) ;

  for i=1:aantal
    w_toets_sqrt_lambda_y(i) = w_toets_nabla_0(i) / sqrt(var_y(i) ) ;
  end

end
