clc;
close all;
clear all;

 % générer un nombre aléatoire de 12 bits
 X = round(rand*(2^8-1));
Xbin = de2bi(X,12);
%initialisation 
Column = 1;
% création du fichier txt et inscrption le nombre aléatoire (sera utile
% pour déchiffrer
%fileKey = fopen ( 'C:\Users\ENFRIN Nathalie\Desktop\stage_periode5\ApprendreMATLAB\myRandomKeyTest.txt', 'wt');
%fprintf(fileKey, num2str(X));
%fclose(fileKey);

%test sur matrice 8x8
A = [11 21 31 41 51 61 71 81 ; 
    12 22 32 42 52 62 72 82 ; 
    13 23 33 43 53 63 73 83 ;
    14 24 34 44 54 64 74 84 ; 
    15 25 35 45 55 65 75 85 ; 
    16 26 36 46 56 66 76 86 ; 
    17 27 37 47 57 67 77 87 ; 
    18 28 38 48 58 68 78 88];

%%%% Transform input A into integers:

A = int8(A);
%A = A-128;

%DCT transformation  
        Adct = dct2(A);
%%%% Until here, everything is fine. Then:
%%%% 1. You just need to deal with the first SIX coefficients instead of
%%%% all of them. These six coefficients needs to be rounded (sign kept)
%%%% and then XORed.
%%%% 2. The iDCT is done with the six XORed coefficients and the rest 58
%%%% coefficients without rounding or abs(). This means you pick these six
%%%% coefficients out and XOR them with the Key and then put the results
%%%% back to form a new matrix of frequency coefficients for the iDCT.
%%%% 3. The iDCT for the SIX XORed coefficients and 58 unchanged
%%%% coefficients will generate the matrix in spartial domain and this
%%%% matrix will need to be rounded into integers.

        
%%%% There is no rounding in this step (please read the paper carefully), as most of the coefficients are very close to 0, this rounding will cause big loss.        
%arrondir les coefficients de la matrice dct
%%%%        Adctround = round(Adct);
        
%%%% There is also no abs() function here. Many values are negative, if you
%%%% abs everyone, how to do the reverse DCT.
%valeur absolue
%%%%        Adctabs= abs(Adctround);
%transformation en tableau de binaire (on obtient 64 tableaux de 12
        %colonnes
        
%%%% Now we do the first step: deal with the selected first six coefficients.

coefSelected = [Adct(1,1), Adct(1,2), Adct(1,3), Adct(2,1), Adct(2,2), Adct(3,1)];
coefSelectedRound = round(coefSelected); 
coefSelectedRoundAbs = abs(coefSelectedRound);        
coefSelectedRoundAbsBin = [dec2bin(coefSelectedRoundAbs(1), 12); dec2bin(coefSelectedRoundAbs(2), 12); dec2bin(coefSelectedRoundAbs(3), 12);dec2bin(coefSelectedRoundAbs(4), 12);dec2bin(coefSelectedRoundAbs(5), 12);dec2bin(coefSelectedRoundAbs(6), 12)];       
%%%% Until here, you get the binary of the value but the sign is still missing.
%%%% Then we add the sign, here we define the positive value marked 0 and
%%%% negative value marked 1.
%%%% Due to the DCT theory, the max value of the DCT coefficients for 8*8
%%%% block with input 0-255 is between 0-2048 which means 11 bits is
%%%% enough so the first bit of each line of coefSelectedRoundAbsBin is
%%%% 0.(For this if you don't understand, please ask me).

for indexSelectedCoef = 1:6
     
    %%%% We only need to mark the sign of the negative coefficients.
    if coefSelected(indexSelectedCoef) < 0
        coefSelectedRoundAbsBin(indexSelectedCoef,1) = '1';
    end   
end
   
%%%% Now the coefSelectedRoundAbsBin is the processed results we want for
%%%% XORing.

%%%% Then open the Key file.
fileKey = fopen ('myRandomKey.txt', 'rt');
formatSpec = '%s';
Y= fscanf(fileKey, formatSpec);
fclose(fileKey);
Ynum=str2num(Y);
Ybin=dec2bin(Ynum,12);
%%%% Be careful the dec2bin function will not automatically do the
%%%% truncation so this step will need to be modified in future.

%%%% Next is to XOR the values with the Key. And put the values back into
%%%% the freqeuncy matrix.
coefSelectedRoundAbsBinXor = coefSelectedRoundAbsBin;
for indexSelectedCoef = 1:6
   
    coefSelectedRoundAbsBinXor(indexSelectedCoef,1:12) = myXor(coefSelectedRoundAbsBin(indexSelectedCoef,1:12), Ybin);
    
    coefSelectedRoundAbsBinXorAbs(indexSelectedCoef) = bin2dec(coefSelectedRoundAbsBinXor(indexSelectedCoef,2:12));
    if coefSelectedRoundAbsBinXor(indexSelectedCoef,1) == '1'
        coefSelectedRoundAbsBinXorInt(indexSelectedCoef) = coefSelectedRoundAbsBinXorAbs(indexSelectedCoef) * (-1);
    else
         coefSelectedRoundAbsBinXorInt(indexSelectedCoef) = coefSelectedRoundAbsBinXorAbs(indexSelectedCoef);
    end
end

Adct(1,1) = coefSelectedRoundAbsBinXorInt(1);
Adct(1,2) = coefSelectedRoundAbsBinXorInt(2);
Adct(1,3) = coefSelectedRoundAbsBinXorInt(3);
Adct(2,1) = coefSelectedRoundAbsBinXorInt(4);
Adct(2,2) = coefSelectedRoundAbsBinXorInt(5);
Adct(3,1) = coefSelectedRoundAbsBinXorInt(6);

%%%% then the reverse DCT2 can be done.

ImgProtected = idct2(Adct); %%%% This matrix is floating point numbers.
ImgProtectedInt = int16(ImgProtected);

%%%% Then we get the result.
%%%% However, we can notice that the output 'ImgProtectedInt' contains many
%%%% values larger than 255 or negative which is going to take more storage space than
%%%% input. This is the question I would like you to find in fact. And due
%%%% to this is not a paper with a good implementation, we will try to
%%%% overcome this problem in next step.



%%%% Then we need to reverse the whole process.
Bdct = dct2(ImgProtectedInt);
%%%% Here you will find Bdct and Adct values (except the first six
%%%% coefficients) are very similar but not exactly the same. The reason is
%%%% we rounded the floating point numbers and idct cause the loss. This
%%%% loss cannot be recovered but image can tolerate some loss like this.

%%%% Only the first coefficients need to be delt with.
coefRecover = [Bdct(1,1), Bdct(1,2), Bdct(1,3), Bdct(2,1), Bdct(2,2), Bdct(3,1)];
coefRecoverRound = round(coefRecover); 
coefRecoverRoundAbs = abs(coefRecoverRound);        
coefRecoverRoundAbsBin = [dec2bin(coefRecoverRoundAbs(1), 12); dec2bin(coefRecoverRoundAbs(2), 12); dec2bin(coefRecoverRoundAbs(3), 12);dec2bin(coefRecoverRoundAbs(4), 12);dec2bin(coefRecoverRoundAbs(5), 12);dec2bin(coefRecoverRoundAbs(6), 12)];       

%%%% Then the same step for the xor and transform between the binaries and
%%%% demicals
for indexSelectedCoef = 1:6
     
    %%%% We only need to mark the sign of the negative coefficients.
    if coefRecoverRound(indexSelectedCoef) < 0
        coefRecoverRoundAbsBin(indexSelectedCoef,1) = '1';
    end   
end


coefRecoverRoundAbsBinXor = coefRecoverRoundAbsBin;
for indexSelectedCoef = 1:6
   
    coefRecoverRoundAbsBinXor(indexSelectedCoef,1:12) = myXor(coefRecoverRoundAbsBin(indexSelectedCoef,1:12), Ybin);
    
    coefRecoverRoundAbsBinXorAbs(indexSelectedCoef) = bin2dec(coefRecoverRoundAbsBinXor(indexSelectedCoef,2:12));
    if coefRecoverRoundAbsBinXor(indexSelectedCoef,1) == '1'
        coefRecoverRoundAbsBinXorInt(indexSelectedCoef) = coefRecoverRoundAbsBinXorAbs(indexSelectedCoef) * (-1);
    else
         coefRecoverRoundAbsBinXorInt(indexSelectedCoef) = coefRecoverRoundAbsBinXorAbs(indexSelectedCoef);
    end
end
%%%% Here you will find the 'coefRecoverRoundAbsBinXorInt' is the same with
%%%% the first 6 coefficients of Adct which means we have recovered the
%%%% original coefficients correctly.

%Replace the first six coefficients of Bdct with recovered values.
Bdct(1,1) = coefRecoverRoundAbsBinXorInt(1);
Bdct(1,2) = coefRecoverRoundAbsBinXorInt(2);
Bdct(1,3) = coefRecoverRoundAbsBinXorInt(3);
Bdct(2,1) = coefRecoverRoundAbsBinXorInt(4);
Bdct(2,2) = coefRecoverRoundAbsBinXorInt(5);
Bdct(3,1) = coefRecoverRoundAbsBinXorInt(6);

%%%%Compare Bdct and Adct, They are very similar now.

ImgRecover = idct2(Bdct);
ImgRecoverInt = int8(ImgRecover);

A
ImgProtectedInt
ImgRecoverInt
%%%% Volia.
%%%% Input matrix: A
%%%% Protected matrix: ImgProtectedInt
%%%% Recovered (Decrypted) matrix: ImgRecoverInt
%%%% End for demo of one matrix.
 






        
        
        
        
%         Adctbin = de2bi(Adctabs,12);
% %chiffrement par  xor avec Xbin
%         for i = 1 : 64
%               AXorBin(i, 1:12) = xor(Adctbin(i,1:12),Xbin);
%         end
% %Remettre en double les 64 colonnes
%         for i = 1 :64
%             AXorDouble(i) = bi2de(AXorBin(i,1:12));
%         end
% %mettre les 64 colonnes en matrice 8x8
%           AXor=reshape(AXorDouble,8,8) ;
% %remettre le signe
%         for i = 1 : 8
%             for j = 1 :8
%             if Adctround(i,j)>=0
%                    AXorSign(i,j) = AXor(i,j);
%              else
%                   AXorSign(i,j) = -AXor(i,j);
%             end
%             end
%         end
%       AXorSign;
% %convertion en Idct
%         AIdct = idct2(AXorSign);
% %conversion en entier
%    Aencrypt=round(AIdct)
%    
%  % put in a colonne W1*L1 
%         for j = 1 : 8
%            for i = 1 : 8
%             fullACryptCol(Column)= Aencrypt(i,j);
%                Column = Column + 1;
%            end
%         end  
%         fullACryptCol;
% %Put the image in matrix W1 x L1
% fullACrypt=reshape(fullACryptCol,8,8)  ;
% 
% % récupérer le Xbin aléatoirement génér?dans l'aglo de
% %chiffrement et stock?dans le fichier myRandomKeyTest.txt
% fileKey = fopen ( 'C:\Users\ENFRIN Nathalie\Desktop\stage_periode5\ApprendreMATLAB\myRandomKeyTest.txt', 'rt');
% formatSpec = '%s';
% Y= fscanf(fileKey, formatSpec);
% fclose(fileKey);
% 
% Ynum=str2num(Y);
% Ybin=de2bi(Ynum,12);
% 
% ColumnI = 1;
% B=fullACrypt;
% 
%  %DCT transformation  
%         Bdct = dct2(B);
% %arrondir les coefficients de la matrice Idct
%         BDctround = round(Bdct);
% %valeur absolue
%     BDctAbs = abs(BDctround);
% %transformation en tableau de binaire (on obtient 64 tableaux de 12
%         %colonnes
%         BDctbin = de2bi(BDctAbs,12);
% %chiffrement par  xor avec Ybin
%         for i = 1 : 64
%               BXorBin(i, 1:12) = xor(BDctbin(i,1:12),Ybin);
%         end
% %Remettre en double les 64 colonnes
%         for i = 1 :64
%             BXorDouble(i) = bi2de(BXorBin(i,1:12));
%         end
% %mettre les 64 colonnes en matrice 8x8
%           BXor=reshape(BXorDouble,8,8) ;
% %remettre le signe
%         for i = 1 : 8
%             for j = 1 :8
%             if BDctround(i,j)>=0
%                    BXorSign(i,j) = BXor(i,j);
%              else
%                   BXorSign(i,j) = -BXor(i,j);
%             end
%             end
%         end
%       BXorSign;
%  %convertion en Idct
%         BIdct = idct2(BXorSign);
%         
%  %arrondir
%  Bfinal=round(BIdct);
%  
%  for j = 1 : 8
%            for i = 1 : 8
%             fullBDeCryptCol(ColumnI)= Bfinal(i,j);
%                ColumnI = ColumnI + 1;
%            end
%  end 
%   fullBDeCryptCol   ;  
%  %Put the image in matrix Wc x Lc
% fullBDeCrypt=reshape(fullBDeCryptCol,8,8)