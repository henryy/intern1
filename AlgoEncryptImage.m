clc;
close all;
clear all;

%read the original image
img= imread ('bar.bmp');
%weight W1 and Length of the original image
[W1,L1] = size(img);

%number of block S
n=8;
img8=reshape(img,n,n,[]);
[W2,L2,S]=size(img8);

%initialisation d'une matrice W1xL1, not?fullImgCrypt
fullImgCrypt = zeros(W1,L1);
Column=1 ;
 % générer un nombre aléatoire de 12 bits
 X = round(rand*(2^8-1));
 
Xbin = de2bi(X,12);

% création du fichier txt et inscrption le nombre aléatoire (sera utile
% pour déchiffrer
fileKey = fopen ( 'myRandomKey.txt', 'wt');
fprintf(fileKey, num2str(X));
fclose(fileKey);

for jtemp = 1 : (S/(W2*L2))
    for itemp = 1 : (S/(W2*L2))
        
        % decomposing the image in 8x8 block 
        temp = img((itemp-1)*8+1 : (itemp-1)*8+8, (jtemp-1)*8+1 : (jtemp-1)*8+8);
     

        %DCT transformation  
        imgdct = dct2(temp);

        %arrondir les coefficients de la matrice dct
        imgdctround = round(imgdct);
        
        %valeur absolue
        imgdctabs= abs(imgdctround);
        
        %transformation en tableau de binaire (on obtient 64 tableaux de 12
        %colonnes
        imgdctbin = de2bi(imgdctabs,12);
        
        %chiffrement par  xor avec Xbin
        for i = 1 : 64
              imgXorBin(i, 1:12) = xor(imgdctbin(i,1:12),Xbin);
        end
        
        %Remettre en double les 64 colonnes
        
        for i = 1 :64
            imgXorDouble(i) = bi2de(imgXorBin(i,1:12));
        end
        %mettre les 64 colonnes en matrice 8x8
        %imgXor = zeros(8,8);
           imgXor=reshape(imgXorDouble,8,8);
      
     %remettre le signe
        for i = 1 : 8
            for j = 1 :8
            if imgdctround(i,j)>=0
                   imgXorSign(i,j) = imgXor(i,j);
             else
                  imgXorSign(i,j) = -imgXor(i,j);
            end
            end
        end
      imgXorSign;
        
        %convertion en Idct
        imgIdct = idct2(imgXorSign);
                  
    %conversion en entier
   imgencrypt=uint8(imgIdct);
    
         % put in a colonne W1*L1 
        for j = 1 : 8
           for i = 1 : 8
            fullImgCryptCol(Column)= imgencrypt(i,j);
               Column = Column + 1;
           end
        end   


        
    end
end
size(fullImgCryptCol)
%Put the image in matrix W1 x L1
%fullImgCrypt=reshape(fullImgCryptCol,W1,L1);
k=1; m=1;
while m < 33
    while k < m*(512*8) +1
        for j=1 : 512
            for i = 1 + (m-1)*8 : 8 +(m-1)*8
                fullImgCrypt(i,j)= fullImgCryptCol(k);
                k=k+1;
            end
           
        end
    end
    m=m+1;
end




%affiche de l'image original
subplot (1,2,1); imshow(img);title('image originale');


%affiche l'image chiffrée
subplot (1,2,2); imshow(fullImgCrypt); title('image chiffrée entière');

%mettre l'image chiffrée dans un dossier (pour la récupérer pour la
%déchiffrer
imwrite (fullImgCrypt, 'C:\Users\ENFRIN Nathalie\Desktop\stage_periode5\ApprendreMATLAB\myEncryptImage.png');
