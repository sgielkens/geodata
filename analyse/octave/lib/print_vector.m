# Druk elementen van een vector verticaal af

# Input
# - invoervector
# - te gebruiken naam van invoervectorvector in uitvoer
# - aantal af te drukken decimalen, default 1

# Output
# - scherm

function print_vector(vector_in, vector_naam, ndec = 1)

ndec = num2str(ndec) ;
mal=['%8.'  ndec  'f'] ;

nr=size(vector_in,1) ;

for i=1:nr
  vector_element = num2str(sprintf( mal,vector_in(i) )) ;

  uitvoer=[ vector_naam num2str(i) ':' vector_element] ;

  disp(uitvoer)
end

end
