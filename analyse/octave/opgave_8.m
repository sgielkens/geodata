# Opgave 8

y = [15.38; 32.15] ;

A = [ 2.6 3.1; 5.7 6.3] ;

x = inv(A) * y ;

# Controle
yc = A * x ;

mal='%8.1f' ;

uitvoer=['Berekende parameter x:'] ;
disp(uitvoer)

nr=size(x,1) ;
for i=1:nr
  uitvoer=[' x' num2str(i) ':' num2str(sprintf( mal,x(i) ))] ;
  disp(uitvoer)
endfor


uitvoer=['Controle via yc = A*x:'] ;
disp('')
disp(uitvoer)

nr=size(x,1) ;
for i=1:nr
  uitvoer=[' yc' num2str(i) ':' num2str(sprintf( mal,yc(i) ))] ;
  disp(uitvoer)
endfor
