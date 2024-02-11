# grenswaarden voor geschatte onbekende parameters bij conventionele w-toets

# Input
# - gewichtscoefficientenmatrix van geschatte parameters
# - matrix van A-model
# - gewichtsmatrix van de waarnemingen
# - grenswaardenvector van de waarnemingen

# Output
# - grenswaardenvectoren van geschatte parameters

function [ w_toets_nabla_0_x ] = w_toets_grenswaarden_x(Qxdakje, A, Wy, w_toets_nabla_0)

  aantal_y = size(w_toets_nabla_0,1) ;
  aantal_x = size(A,2) ;

  w_toets_nabla_0_matrix = diag(w_toets_nabla_0) ;

  for i=1:aantal_y
      w_toets_nabla_0_y = w_toets_nabla_0_matrix(:,i) ;

      w_toets_nabla_0_xi = Qxdakje * A' * Wy * w_toets_nabla_0_y ;

      if (i == 1)
          w_toets_nabla_0_x = w_toets_nabla_0_xi ;
      else
          w_toets_nabla_0_x = [ w_toets_nabla_0_x w_toets_nabla_0_xi ] ;
      endif
  end

end
