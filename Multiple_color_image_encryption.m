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
map1=piecewiselinearchaoticmap(pp,d1,xx);
[psort1,index1]=sort(map1,'descend');
Blocks = cell(s1,d1);
%pwlcm on blocks
for i = 1:s1
    for j=1:d1
    Blocks(i,j)=Block(i,index1(j));
    end
end
%image dependent block division%
[r,s] = size(V);
%conversion to matrix so as to make blocks of size(4,3) from Blocks
Block1 = cell2mat(Blocks);
Block2 = cell(r/m,s/3);
%generating blocks of size (4,3) on Block1
counti = 0;
for i = 1:m:r-(m-1)
   counti = counti + 1;
   countj = 0;
   for j = 1:3:s-2
        countj = countj + 1;
        Block2{counti,countj} = Block1(i:i+(m-1),j:j+2);
   end
end
%logistics map on blocks%
x(1)=0.56;
r=3.999;
for i=1:(255)
    x(i+1)=r*x(i)*(1-x(i));
end
map2 = x;
[psort2,index2]=sort(map2,'descend');
%generating empty blocks of size(4,3)
[s2,d2] = size(Block2);
Blocks2 = cell(s2,d2);
for i = 1:s2
   for j = 1:d2
        Blocks2{i,j} = zeros(m,3);
   end
end
% logistics map on Blocks of size(4,3)
for i = 1:s2
    for j=1:d2
    Blocks2(i,j)=Block2(i,index2(j));
    end
end