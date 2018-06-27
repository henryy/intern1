function [ charArrayOutput ] = myXor( charArray1, charArray2)
%MYXOR: xor operation for two strings with the same length
%   Two input elements must be strings (array of char and each element must
%   be '0' or '1'). You better transform the input into binary first then
%   string. e.g. a = '101'; b = '110'; c = myXor(a,b)

    if length(charArray1) ~= length(charArray2)
        error('Input elements must have same size');
    end
    
    charArrayOutput = charArray1;
    
    for i = 1:length(charArray1)
        if charArray1(i) ==  charArray2(i)
            charArrayOutput(i) = '0';
        end
        if charArray1(i) ~= charArray2(i)
            charArrayOutput(i) = '1';
        end
    end


end

