# Opgave 9

y = [9; 33 ; -2] ;

A = [ 2.6 3.1 4.2; 5.7 6.3 -0.5 ; -3.2 1.6 0.3] ;

c = [-0.08 ; 0.12 ; 0.05] ;

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
