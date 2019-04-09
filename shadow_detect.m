%% Shadow Detection Source Code
% Shared by Beril Sirmacek
% For Academic & Educational Usage Only
% Please consider citing following reference articles.
% 
% B. Sirmacek and C. Unsalan, "Damaged Building Detection in Aerial Images 
% using Shadow Information", 4th International Conference on Recent Advances 
% in Space Technologies RAST 2009, Istanbul, Turkey, June 2009.
%
% C. Unsalan and K. L. Boyer, "Linearized vegetation indices based on a formal 
% statistical framework," IEEE Transactions on Geoscience and Remote Sensing, 
% vol. 42, pp. 1575-1585, 2004. 

%%
clear all
close all
clc

%% Read Images:

im = imread('im3.jpg');
figure, imshow(im);

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
shadow_mask(1:1700,:)=1;
shadow_mask(end-300:end,:) = 1;
shadow_mask(:,1:300) = 1;
shadow_mask(:,end-300:end) = 1;
figure, imshow(shadow_mask, []); 
% NOTE: Depending on the shadow size that you want to consider,
% you can change the area size threshold
shadow_mask = bwareaopen(shadow_mask, 100);
J = shadow_mask;
Kmedian = medfilt2(J);
K = wiener2(Kmedian,[5 5]);
K = wiener2(Kmedian,[7 7]);
%figure,imshow(Kmedian);
L=~K;
figure,imshow(K);
[row,col]=find(L);
a1=min(row);
a2=max(row);
b1=min(col);
b2=max(col);
distance=sqrt((a2-a1)^2+(b2-b1)^2)
arg=165+180/pi*atan((b2-b1)/(a2-a1))
%figure, imshow(shadow_mask, []);
% [x,y] = find(imdilate(shadow_mask,strel('disk',2))-shadow_mask);

%figure, imshow(im); hold on,
%plot(y,x,'.b'), title('Shadow Boundaries');

%%
for i=1900:2400
   for j=1:3200
      for k=1:3
          if(im(i,j,k)<0.27)
                %im(i,j,1)=0.658;
                %im(i,j,2)=0.639;
                %im(i,j,3)=0.627;
                im(i,j,1)=im(i,j,1)*146/54;
                im(i,j,2)=im(i,j,2)*144/66;
                im(i,j,3)=im(i,j,3)*149/88;
          elseif(im(i,j,k)<0.53)
                im(i,j,1)=im(i,j,1)*146/107;
                im(i,j,2)=im(i,j,2)*144/107;
                im(i,j,3)=im(i,j,3)*149/117;
          end
      end
   end
end


