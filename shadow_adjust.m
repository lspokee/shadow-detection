%%
clear all
close all
clc
% They want to pick their own.
		% Change default directory to the one containing the standard demo images for the MATLAB Image Processing Toolbox. 
originalFolder = pwd; 
folder = sprintf('%s\test',pwd); 
if ~exist(folder, 'dir') 
	folder = pwd;
end 
cd(folder); 
% Browse for the image file. 
[baseFileName, folder] = uigetfile('*.*', 'Specify an image file'); 

fullImageFileName = fullfile(folder, baseFileName); 
% Set current folder back to the original one. 
cd(originalFolder);
if ~exist(fullImageFileName, 'file')
	message = sprintf('This file does not exist:\n%s', fullImageFileName);
	uiwait(msgbox(message));
	return;
end
if(strcmp(baseFileName,'P2062172.mov'))
    
    newim1=imread(fullfile(pwd, 'images','sem2','LL.png'));
    newim2=imread(fullfile(pwd, 'images','sem2','ML.png'));
    newim3=imread(fullfile(pwd, 'images','sem2','M.png'));
    newim4=imread(fullfile(pwd, 'images','sem2','MR.png'));
    newim5=imread(fullfile(pwd, 'images','sem2','R.png'));  
end
%% Read Images:


%im = imread('test/PB230058.jpg');
im=newim3; 
figure, imshow(im);
im = im2double(im);
im2=im;


%imwrite(im,'adjusted1.jpg');
% NOTE: You might need different median filter size for your test image.
r = medfilt2(double(im(:,:,1)), [3,3]); 
g = medfilt2(double(im(:,:,2)), [3,3]);
b = medfilt2(double(im(:,:,3)), [3,3]); 

%% Calculate Shadow Ratio:

shadow_ratio = ((4/pi).*atan(((r+g))./(r-g)));
%figure, imshow(shadow_ratio, []); colormap(jet); colorbar;

% NOTE: You might need a different threshold value for your test image.
% You can also consider using automatic threshold estimation methods.
shadow_mask = shadow_ratio>-1.83;


shadow_mask(1:5,:) = 0;
shadow_mask(end-5:end,:) = 0;
shadow_mask(:,1:5) = 0;
shadow_mask(:,end-5:end) = 0;
shadow_mask(1:1700*3/4,:)=1;
shadow_mask(end-300*3/4:end,:) = 1;
shadow_mask(:,1:300*3/4) = 1;
shadow_mask(:,end-300*3/4:end) = 1;
figure, imshow(shadow_mask, []); 
% NOTE: Depending on the shadow size that you want to consider,
% you can change the area size threshold
shadow_mask = bwareaopen(shadow_mask, 100);
J = shadow_mask;
Kmedian = medfilt2(J);
K = wiener2(Kmedian,[5 5]);
K = wiener2(K,[7 7]);
%figure,imshow(Kmedian);
L=~K;
im3=im2;
figure,imshow(K);

n = nnz(L)
if(n>26000)
    figure,imshow(im2);
    for i=1900:2400
        for j=1:3200
            for k=1:3
                if(im2(i,j,k)<0.27)
                    im2(i,j,1)=im2(i,j,1)*146/54;
                    im2(i,j,2)=im2(i,j,2)*144/66;
                    im2(i,j,3)=im2(i,j,3)*149/88;
                    im3(i,j,1)=im2(i,j,1);
                    im3(i,j,2)=im2(i,j,2);
                    im3(i,j,3)=im2(i,j,3);
                elseif(im2(i,j,k)<0.53)
                    im2(i,j,1)=im2(i,j,1)*146/107-0.24;
                    im2(i,j,2)=im2(i,j,2)*144/107-0.24;
                    im2(i,j,3)=im2(i,j,3)*149/117-0.24;
                    im3(i,j,1)=im2(i,j,1)+0.24;
                    im3(i,j,2)=im2(i,j,2)+0.24;
                    im3(i,j,3)=im2(i,j,3)+0.24;
                end
            end
        end
    end
    r2 = medfilt2(double(im2(:,:,1)), [3,3]); 
    g2 = medfilt2(double(im2(:,:,2)), [3,3]);
    b2 = medfilt2(double(im2(:,:,3)), [3,3]); 
    figure,imshow(im3);
    shadow_ratio2 = ((4/pi).*atan(((r2+g2))./(r2-g2)));
    shadow_mask2 = shadow_ratio2>-1.84;
    shadow_mask2(1:5,:) = 0;
    shadow_mask2(end-5:end,:) = 0;
    shadow_mask2(:,1:5) = 0;
    shadow_mask2(:,end-5:end) = 0;
    shadow_mask2(1:1700,:)=1;
    shadow_mask2(end-530:end,:) = 1;
    shadow_mask2(:,1:300) = 1;
    shadow_mask2(:,end-300:end) = 1;
    figure, imshow(shadow_mask2, []);
    J = shadow_mask2;
    Kmedian = medfilt2(J);
    K = wiener2(Kmedian,[5 5]);
    K = wiener2(K,[7 7]);
    K = wiener2(K,[5 5]);
%figure,imshow(Kmedian);
    L=~K;
    figure,imshow(K);
    %[row,col]=find(L);
end
[row,col]=find(L);
y1=min(row)
%y2=max(row);
%x1=min(col);
%x2=max(col);
exrow=L(y1,:);
x1=min(find(exrow))
distance=sqrt((x1-1600)^2+(y1-1850)^2)/1.76
%distance=sqrt((y2-y1)^2+(x2-x1)^2);
arg=190+0.76*(180/pi*atan((x1-1600)/(1850-y1)))

