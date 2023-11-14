# Opgave 11

y = [1 ; 1] ;

A = [ pi e ; -e pi ] ;

c = [0 ; 0] ;

B = inv(A) ;

x = B * (y - c) ;

# Controle
uitvoer=['Controle op I = A * inv(A):'] ;
disp(uitvoer)
I = A * B

yc = A * x + c;

mal='%8.2f' ;

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
