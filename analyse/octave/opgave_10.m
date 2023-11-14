# Opgave 10

y = [-2.2032; 11.2247] ;

A = [ 0.12 -0.54 ; 0.45 0.33 ] ;

c = [2.4 ; -3.4] ;

B = inv(A) ;

x = B * (y - c) ;

# Controle
uitvoer=['Controle op I = A * inv(A):'] ;
disp(uitvoer)
I = A * B

yc = A * x + c;

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
