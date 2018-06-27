clc;
close all;
clear all;

% generate a random number of 12 bits
X = round(rand*(2^8-1));
Xbin = de2bi(X,12);
%initialisation 
Column = 1;
% create file txt to write in it the random number
fileKey = fopen ( 'myRandomKeyTest4.txt', 'wt');
fprintf(fileKey, num2str(X));
fclose(fileKey);

%test sur 4 matrices 8x8
A1 = [11 21 31 41 51 61 71 81 ; 
    12 22 32 42 52 62 72 82 ; 
    13 23 33 43 53 63 73 83 ;
    14 24 34 44 54 64 74 84 ; 
    15 25 35 45 55 65 75 85 ; 
    16 26 36 46 56 66 76 86 ; 
    17 27 37 47 57 67 77 87 ; 
    18 28 38 48 58 68 78 88];

A2 = [11 21 31 41 51 61 71 81 ; 
    12 22 32 42 52 62 72 82 ; 
    13 23 33 43 53 63 73 83 ;
    14 24 34 44 54 64 74 84 ; 
    15 25 35 45 55 65 75 85 ; 
    16 26 36 46 56 66 76 86 ; 
    17 27 37 47 57 67 77 87 ; 
    18 28 38 48 58 68 78 88];

A3 = [11 21 31 41 51 61 71 81 ; 
    12 22 32 42 52 62 72 82 ; 
    13 23 33 43 53 63 73 83 ;
    14 24 34 44 54 64 74 84 ; 
    15 25 35 45 55 65 75 85 ; 
    16 26 36 46 56 66 76 86 ; 
    17 27 37 47 57 67 77 87 ; 
    18 28 38 48 58 68 78 88];

A4 = [11 21 31 41 51 61 71 81 ; 
    12 22 32 42 52 62 72 82 ; 
    13 23 33 43 53 63 73 83 ;
    14 24 34 44 54 64 74 84 ; 
    15 25 35 45 55 65 75 85 ; 
    16 26 36 46 56 66 76 86 ; 
    17 27 37 47 57 67 77 87 ; 
    18 28 38 48 58 68 78 88];

A=[A1 A2 ; A3 A4]
[W1,L1] = size(A)
n=8;
img8=reshape(A,n,n,[]);
[W2,L2,S]= size(img8)

%transform input A into integers
A = int8(A);

for jtemp = 1 : 2
   for itemp = 1 : 2
        
    % decomposing the image in 8x8 block 
        Atemp = A((itemp-1)*8+1 : (itemp-1)*8+8, (jtemp-1)*8+1 : (jtemp-1)*8+8);
       
    %DCT transformation  
        Adct = dct2(Atemp);
    
    %Select the 6 coefficients 
    coefSelected = [Adct(1,1), Adct(1,2), Adct(1,3), Adct(2,1), Adct(2,2), Adct(3,1)]
    %round the 6 coefficients
    coefSelectedRound = round(coefSelected);
    %get absolue value of the 6 coefficients
    coefSelectedRoundAbs = abs(coefSelectedRound);
    %transformation into binary (but sign missing: positive =0; negative =1)
    coefSelectedRoundAbsBin = [dec2bin(coefSelectedRoundAbs(1), 12); 
        dec2bin(coefSelectedRoundAbs(2), 12); 
        dec2bin(coefSelectedRoundAbs(3), 12);
        dec2bin(coefSelectedRoundAbs(4), 12);
        dec2bin(coefSelectedRoundAbs(5), 12);
        dec2bin(coefSelectedRoundAbs(6), 12)];
    
    %put the sign in the 12th bit (it is already 0 for the positive number)
     for indexSelectedCoef = 1:6
        if coefSelected(indexSelectedCoef) < 0
            coefSelectedRoundAbsBin(indexSelectedCoef,1) = '1';
        end   
     end
    %check
    coefSelectedRoundAbsBin
    
    %Then open the Key file (always the same key for the moment).
    fileKey = fopen ('myRandomKey.txt', 'rt');
    formatSpec = '%s';
    Y= fscanf(fileKey, formatSpec);
    fclose(fileKey);
    Ynum=str2num(Y);
    Ybin=dec2bin(Ynum,12);
    
    %crypt with  xor (with the function myxor (Han) avec Ybin the 6 coefficients
    %initialization
    coefSelectedRoundAbsBinXor = coefSelectedRoundAbsBin;
     
    for indexSelectedCoef = 1:6
        %xor with function myxor
       coefSelectedRoundAbsBinXor(indexSelectedCoef,1:12) = myXor(coefSelectedRoundAbsBin(indexSelectedCoef,1:12), Ybin);
       %put binary in decimal
       %initialisation (without the sign)
       coefSelectedRoundAbsBinXorAbs(indexSelectedCoef) = bin2dec(coefSelectedRoundAbsBinXor(indexSelectedCoef,2:12));
        %put the sign 
        if coefSelectedRoundAbsBinXor(indexSelectedCoef,1) == '1'
            coefSelectedRoundAbsBinXorInt(indexSelectedCoef) = coefSelectedRoundAbsBinXorAbs(indexSelectedCoef) * (-1);
        else
            coefSelectedRoundAbsBinXorInt(indexSelectedCoef) = coefSelectedRoundAbsBinXorAbs(indexSelectedCoef);
        end
    end
    
    %put the 6 coefficients (XORed) in the matrice Adct
    Adct(1,1) = coefSelectedRoundAbsBinXorInt(1);
    Adct(1,2) = coefSelectedRoundAbsBinXorInt(2);
    Adct(1,3) = coefSelectedRoundAbsBinXorInt(3);
    Adct(2,1) = coefSelectedRoundAbsBinXorInt(4);
    Adct(2,2) = coefSelectedRoundAbsBinXorInt(5);
    Adct(3,1) = coefSelectedRoundAbsBinXorInt(6);
    
    %transform with idct to obtain A protected
        AIdct = idct2(Adct);
    %transform with integer
        AProtectedInt=int16(AIdct)
   
    % put in a colonne W1*L1 
        for j = 1 : 8
           for i = 1 : 8
            fullACryptCol(Column)= AProtectedInt(i,j);
               Column = Column + 1;
           end
        end  
   end
end
size(fullACryptCol)
%Put the image in matrix W1 x L1
%initialisation d'une matrice W1xL1, noté fullImgCrypt
%fullImgCrypt = zeros(16,16);
%fullACrypt=reshape(fullACryptCol,16,16)  ;
k=1; m =1;
while m <3;
    while k <= m*(16*8) 
        for j=1 : 16
            for i =  1 + (m-1)*8 : 8 +(m-1)*8
            fullImgCrypt(i,j)= fullACryptCol(k);
            k=k+1;
            end
        end
     end  
m=m+1;
end

fullImgCrypt 

%DECRYPT TO find the original matrix

%transform input A into integers
B = int16(fullImgCrypt);
ColumnB = 1;

for jtemp = 1 : 2
   for itemp = 1 : 2
        
    % decomposing the image in 8x8 block 
        Btemp = B((itemp-1)*8+1 : (itemp-1)*8+8, (jtemp-1)*8+1 : (jtemp-1)*8+8)
       
    %DCT transformation  
        Bdct = dct2(Btemp);
    
    %Select the 6 coefficients 
    coefRecover = [Bdct(1,1), Bdct(1,2), Bdct(1,3), Bdct(2,1), Bdct(2,2), Bdct(3,1)]
    %round the 6 coefficients
    coefRecoverRound = round(coefRecover);
    %get absolue value of the 6 coefficients
    coefRecoverRoundAbs = abs(coefRecoverRound);
    %transformation into binary (but sign missing: positive =0; negative =1)
    coefRecoverRoundAbsBin = [dec2bin(coefRecoverRoundAbs(1), 12); 
        dec2bin(coefRecoverRoundAbs(2), 12); 
        dec2bin(coefRecoverRoundAbs(3), 12);
        dec2bin(coefRecoverRoundAbs(4), 12);
        dec2bin(coefRecoverRoundAbs(5), 12);
        dec2bin(coefRecoverRoundAbs(6), 12)];
    
    %put the sign in the 12th bit (it is already 0 for the positive number)
     for indexSelectedCoef = 1:6
        if coefRecoverRound(indexSelectedCoef) < 0
            coefRecoverRoundAbsBin(indexSelectedCoef,1) = '1';
        end   
     end
    %check
    coefRecoverRoundAbsBin
    
     
    %crypt with  xor (with the function myxor (Han) avec Ybin the 6 coefficients
    %initialization
    coefRecoverRoundAbsBinXor = coefRecoverRoundAbsBin;
     
    for indexSelectedCoef = 1:6
        %xor with function myxor
       coefRecoverRoundAbsBinXor(indexSelectedCoef,1:12) = myXor(coefRecoverRoundAbsBin(indexSelectedCoef,1:12), Ybin);
       %put binary in decimal
       %initialisation (without the sign)
       coefRecoverRoundAbsBinXorAbs(indexSelectedCoef) = bin2dec(coefRecoverRoundAbsBinXor(indexSelectedCoef,2:12));
        %put the sign 
        if coefRecoverRoundAbsBinXor(indexSelectedCoef,1) == '1'
            coefRecoverRoundAbsBinXorInt(indexSelectedCoef) = coefRecoverRoundAbsBinXorAbs(indexSelectedCoef) * (-1);
        else
            coefRecoverRoundAbsBinXorInt(indexSelectedCoef) = coefRecoverRoundAbsBinXorAbs(indexSelectedCoef);
        end
    end
    
    %put the 6 coefficients (XORed) in the matrice Adct
    Bdct(1,1) = coefRecoverRoundAbsBinXorInt(1);
    Bdct(1,2) = coefRecoverRoundAbsBinXorInt(2);
    Bdct(1,3) = coefRecoverRoundAbsBinXorInt(3);
    Bdct(2,1) = coefRecoverRoundAbsBinXorInt(4);
    Bdct(2,2) = coefRecoverRoundAbsBinXorInt(5);
    Bdct(3,1) = coefRecoverRoundAbsBinXorInt(6);
    
    %transform with idct to obtain A protected
        BIdct = idct2(Bdct);
    %transform with integer
        BRecoverInt=int16(BIdct)
   
    % put in a colonne W1*L1 
        for j = 1 : 8
           for i = 1 : 8
            fullBDeCryptCol(ColumnB)= BRecoverInt(i,j);
               ColumnB = ColumnB + 1;
           end
        end  
   end
end

k=1; m =1;
while m <3;
    while k <= m*(16*8) 
        for j=1 : 16
            for i =  1 + (m-1)*8 : 8 +(m-1)*8
            fullImgDeCrypt(i,j)= fullBDeCryptCol(k);
            k=k+1;
            end
        end
     end  
m=m+1;
end

fullImgDeCrypt 