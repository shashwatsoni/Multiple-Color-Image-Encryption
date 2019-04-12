clc;
close all;
clear;
myFolder='D:\WORK\major project';
m=input('Type the Number of Images to Process:');% Ask the amount of image to process
for k = 1:m
  tiffFilename = sprintf('image%d.tiff', k);
  fullFileName = fullfile(myFolder, tiffFilename);
  if exist(fullFileName, 'file')
    imageData = imread(fullFileName);
    IMAGE{k}= mat2cell(imageData);
  else
    warningMessage = sprintf('Warning: image file does not exist:\n%s', fullFileName);%if file doesent exist sends an error message
    uiwait(warndlg(warningMessage));
  end
end
for k = 1:m
    temp = cell2mat(IMAGE{k});
    R= temp(:,:,1); %<1*1>cell containing matrix of size 256*256 uint8%
    G = temp(:,:,2);
    B = temp(:,:,3);
    Vs{k,1}= horzcat(R,G,B);
%concatenation%
end
V = cell2mat(Vs);
[p,q] = size(V);
Block = cell(p/256,q/256);
counti = 0;
for i = 1:256:p-255
   counti = counti + 1;
   countj = 0;
   for j = 1:256:q-255
        countj = countj + 1;
        Block{counti,countj} = V(i:i+255,j:j+255);
   end
end
%pwlcm%
xx=0.275648900231572;
pp=0.347823654894159;
[s1,d1] = size(Block);
map1=piecewiselinearchaoticmap(pp,(s1*d1),xx);
[psort1,index1]=sort(map1,'ascend');
Block = reshape(Block,1,(s1*d1));
Blocks = cell(1,s1*d1);
%pwlcm on blocks
for i = 1
    for j=1:(s1*d1)
    Blocks(i,j)=Block(i,index1(j));
    end
end
Blocks = reshape(Blocks,s1,d1);
%image dependent block division%
[r,s] = size(V);
%conversion to matrix so as to make blocks of size(m,3) from Blocks
Block1 = cell2mat(Blocks);
Block2 = cell(r/m,s/3);
%generating blocks of size (m,3) on Block1
counti = 0;
for i = 1:m:r-(m-1)
   counti = counti + 1;
   countj = 0;
   for j = 1:3:s-2
        countj = countj + 1;
        Block2{counti,countj} = Block1(i:i+(m-1),j:j+2);
   end
end
%logistics map on Block2%
x(1)=0.50;
r=3.998;
for i=1:((256*256)-1)
    x(i+1)=r*x(i)*(1-x(i));
end
map2 = x;
[psort2,index2]=sort(map2,'ascend');
%generating empty blocks of size(m,3)
[s2,d2] = size(Block2);
Blocks2 = cell(s2,d2);
for i = s2
   for j = 1:d2
        Blocks2{i,j} = zeros(m,3);
   end
end
Block2 = reshape(Block2,1,(256*256));
Blocks2 = reshape(Blocks2,1,(256*256));
% logistics map on Blocks of size(m,3)
for i = 1
    for j=1:(s2*d2)
    Blocks2(i,j)=Block2(i,index2(j));
    end
end
Blocks2 = reshape(Blocks2,256,256);
%pwlcm map on Blocks2%
xx=0.275648900231572;
pp=0.347823654894159;
s3 = m;
d3 = 3;
map3=piecewiselinearchaoticmap(pp,(s3*d3),xx);
[psort3,index3]=sort(map3,'ascend');
map3 = reshape(map3,m,3);
for i = 1:m
    for j = 1:3
            while (map3(i,j)-fix(map3(i,j))>0)
                map3(i,j) = (map3(i,j))*(10);
            end
    end
end
Blocks211 = uint8(cell2mat(Blocks2(1,1)));
map3 = mod(map3,256);
Block3(1,1) = mat2cell(bitxor(uint8(map3),Blocks211));
Blocks2 = reshape(Blocks2,1,256*256);
%made linear for proper Bitwise xor
for j = 2:(256*256)
    Block3(1,j)= mat2cell(bitxor(uint8(cell2mat(Blocks2(1,j))),uint8(cell2mat(Block3(1,j-1)))));
end        
% V V IMP
 %double bcoz bitxor without double not possible, cell2mat bcoz bitxor not
 %possible on double and lastly mat2cell bcoz we need to make a cell
Block3 = reshape(Block3,256,256);
Block3 = cell2mat(Block3);
[p,q] = size(Block3);
Blocks3 = cell(p/256,q/256);
counti = 0;
for i = 1:256:p-255
   counti = counti + 1;
   countj = 0;
   for j = 1:256:q-255
        countj = countj + 1;
        Blocks3{counti,countj} = Block3(i:i+255,j:j+255);
   end
end
%logistics map on Blocks3%
y(1)=0.56;
r=3.999;
for i=1:((256*256)-1) % 2 taken as index4(j) in coming lines should be between 1-3
    y(i+1)=r*y(i)*(1-y(i));
end
map4 = y;
[psort4,index4]=sort(map4,'ascend');
%generating empty blocks of size(m,3)
y = reshape(y,256,256);
Blocks3 = reshape(Blocks3,1,(m*3));
Blocks311 = uint8(cell2mat(Blocks3(1,1)));
Block4(1,1) = mat2cell(bitxor(uint8(y),Blocks311));
for j = 2:(m*3)
    Block4(1,j)= mat2cell(bitxor(uint8(cell2mat(Blocks3(1,j))),uint8(cell2mat(Block4(1,j-1)))));
end  
Block4 = reshape(Block4,m,3);
for i = 1:m
    Rc(i,1) = Block4(i,1);
    Gc(i,1) = Block4(i,2);
    Bc(i,1) = Block4(i,3);
end
for i = 1:m
C{i} = zeros(256,256,3);
end
for i = 1:m
    temp2 = C{i};
   temp2(:,:,1) = cell2mat(Rc(i,1));
   temp2(:,:,2) = cell2mat(Gc(i,1));
   temp2(:,:,3) = cell2mat(Bc(i,1));
   C{i} = temp2;
end
for i = 1:m
    C{i} = uint8(C{i});
end
