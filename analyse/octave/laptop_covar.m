laptop_diag = [ 17 ; 14 ; 14 ; 19 ; 15.4 ; 13.9 ; 17.5 ; 18 ] ;
laptop_dikte = [ 36 ; 12 ; 20 ; 19 ; 16 ; 20 ; 22 ; 28 ] ;

aantal = size(laptop_diag,1) ;
eentjes = ones(aantal,1) ;

gem_diag = (laptop_diag' * eentjes) / (aantal) ;
mean_diag = mean(laptop_diag)
#std_dev_diag = std(laptop_diag)

gem_dikte = (laptop_dikte' * eentjes) / (aantal) ;
mean_dikte = mean(laptop_dikte)
#std_dev_dikte = std(laptop_dikte)

delta_y1 = laptop_diag - mean_diag ;
delta_y2 = laptop_dikte - mean_dikte;

covar = (delta_y1' * delta_y2) / (aantal - 1)

# Controle
var_y1 = ( delta_y1' * delta_y1 ) / (aantal - 1) ;
var_y2 = ( delta_y2' * delta_y2 ) / (aantal - 1) ;

sigma_y1 = sqrt(var_y1)
sigma_y2 = sqrt(var_y2)

rho = covar / (sigma_y1 * sigma_y2)

corrcoef(laptop_diag, laptop_dikte)

