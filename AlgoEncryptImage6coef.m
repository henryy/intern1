clc;
close all;
clear all;

%read the original image
imgRead= imread ('bar.bmp');
%weight W1 and Length of the original image
[W1,L1] = size(imgRead)

%number of block S
n=8;
img8=reshape(imgRead,n,n,[]);
[W2,L2,S]=size(img8)

%initialisation 
column=1 ;


% generate a random number of 12 bits
X = round(rand*(2^8-1));
Xbin = de2bi(X,12);

% create file txt to write in it the random number
fileKey = fopen ( 'myRandomKeyForImage.txt', 'wt');
fprintf(fileKey, num2str(X));
fclose(fileKey);

%put in integer
img=int8(double(imgRead)-128);

for jtemp = 1 : 64
    for itemp = 1 : 64
        
        % decomposing the image in 8x8 block 
        temp = img((itemp-1)*8+1 : (itemp-1)*8+8, (jtemp-1)*8+1 : (jtemp-1)*8+8);
     
        %DCT transformation  
        tempDct = dct2(temp);

       %Select the 6 coefficients 
        coefSelected = [tempDct(1,1), tempDct(1,2), tempDct(1,3), tempDct(2,1), tempDct(2,2), tempDct(3,1)];
        
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
        %coefSelectedRoundAbsBin
        
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
    tempDct(1,1) = coefSelectedRoundAbsBinXorInt(1);
    tempDct(1,2) = coefSelectedRoundAbsBinXorInt(2);
    tempDct(1,3) = coefSelectedRoundAbsBinXorInt(3);
    tempDct(2,1) = coefSelectedRoundAbsBinXorInt(4);
    tempDct(2,2) = coefSelectedRoundAbsBinXorInt(5);
    tempDct(3,1) = coefSelectedRoundAbsBinXorInt(6);
                  
    %transform with idct to obtain A protected
        tempIdct = idct2(tempDct);
    %transform with integer
        tempProtectedInt=int16(tempIdct);
    
         % put in a colonne W1*L1 
        for j = 1 : 8
           for i = 1 : 8
                imgProtectedCol(column)= tempProtectedInt(i,j);
               column = column + 1;
           end
        end   

        
        
    end
end
size(imgProtectedCol)

%Put the image in matrix W1 x L1
imgProtected = zeros(512,512);
k=1; m=1;
while m < 65
    while k < m*(W1*8) +1
        for j=1 : 512
            for i = 1 + (m-1)*8 : 8 +(m-1)*8
                imgProtected(i,j)= imgProtectedCol(k);
                k=k+1;
            end
           
        end
    end
    m=m+1;
end
imgProtected;

%Decrypt to find the original image

recover = double(imgProtected);
columnRecover = 1;
imgRecover = zeros(512,512);

for jtemp = 1 : 64
   for itemp = 1 : 64
        
    % decomposing the image in 8x8 block 
        tempRecover = recover((itemp-1)*8+1 : (itemp-1)*8+8, (jtemp-1)*8+1 : (jtemp-1)*8+8);
       
    %DCT transformation  
        tempRecoverDct = dct2(tempRecover);
    
    %Select the 6 coefficients 
    coefRecover = [tempRecoverDct(1,1), tempRecoverDct(1,2), tempRecoverDct(1,3), tempRecoverDct(2,1), tempRecoverDct(2,2), tempRecoverDct(3,1)];
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
    coefRecoverRoundAbsBin;
    
     
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
    tempRecoverDct(1,1) = coefRecoverRoundAbsBinXorInt(1);
    tempRecoverDct(1,2) = coefRecoverRoundAbsBinXorInt(2);
    tempRecoverDct(1,3) = coefRecoverRoundAbsBinXorInt(3);
    tempRecoverDct(2,1) = coefRecoverRoundAbsBinXorInt(4);
    tempRecoverDct(2,2) = coefRecoverRoundAbsBinXorInt(5);
    tempRecoverDct(3,1) = coefRecoverRoundAbsBinXorInt(6);
    
    %transform with idct to obtain A protected
        tempRecoverIdct = idct2(tempRecoverDct);
    %transform with integer
        tempRecoverIdctInt=int16(tempRecoverIdct +128 );
   
    % put in a colonne W1*L1 
        for j = 1 : 8
           for i = 1 : 8
            imgRecoverCol(columnRecover)= tempRecoverIdctInt(i,j);
               columnRecover = columnRecover + 1;
           end
        end 
        
   end
end

size(imgRecoverCol)

k=1; m =1;
while m < 65
    while k < m*(512*8) +1
        for j=1 : 512
            for i = 1 + (m-1)*8 : 8 +(m-1)*8
                imgRecover(i,j)= imgRecoverCol(k);
                k=k+1;
            end
        end
     end  
m=m+1;
end
 
imgRecover;



% poster of the original image
subplot (1,3,1); imshow(imgRead);title(' original image');

%poster of encrypted image
subplot (1,3,2); imshow(int8(imgProtected)); title('encrypted image');

%poster of the decrypted image
subplot (1,3,3); imshow(uint8(imgRecover)); title('decrypted image');

%put the encrypted image in a file
%imwrite (fullImgCrypt, 'myEncryptImage.png');
