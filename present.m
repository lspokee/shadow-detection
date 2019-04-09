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
%% Read Images:

%im = imread('test/PB230058.jpg');
im=imread(fullImageFileName); 
%figure, imshow(im);
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
shadow_mask(1:1700,:)=1;
shadow_mask(end-300:end,:) = 1;
shadow_mask(:,1:300) = 1;
shadow_mask(:,end-300:end) = 1;
%figure, imshow(shadow_mask, []); 
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
%figure,imshow(K);
figure,imshow(L);
n = nnz(L)
if(n>26000)
    %figure,imshow(im2);
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
    %figure,imshow(im3);
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
    %figure, imshow(shadow_mask2, []);
    J = shadow_mask2;
    Kmedian = medfilt2(J);
    K = wiener2(Kmedian,[5 5]);
    K = wiener2(K,[7 7]);
    K = wiener2(K,[5 5]);
%figure,imshow(Kmedian);
    L=~K;
    %figure,imshow(K);
    figure,imshow(L);
    %[row,col]=find(L);
end
[row,col]=find(L);
y1=min(row);
%y2=max(row);
%x1=min(col);
%x2=max(col);
exrow=L(y1,:);
x1=min(find(exrow));
if((x1-1600)/(1850-y1)<0)
arg=190+0.56*(180/pi*atan((x1-1600)/(1850-y1)));
else
    arg=180+0.56*(180/pi*atan((x1-1600)/(1850-y1)));
end
azimuth_show=arg
distance_raw=sqrt((x1-1600)^2+(y1-1850)^2)
distance=distance_raw/(1.5+distance_raw/1500+(arg-185)/1850);
shad_length_show=distance
%distance=sqrt((y2-y1)^2+(x2-x1)^2);


filename = 'databasev1.xlsx';
xlRange = 'D6:O38';
azimuth = xlsread(filename,2,xlRange);
slength = xlsread(filename,3,xlRange);
[~, datetxt] = xlsread(filename,2,'B1:R1');
[~, timetxt] = xlsread(filename,2,'A2:A42');
%http://www.hko.gov.hk/gts/astronomy/SunPathDay3_ue.htm
%angle=210.9;
%aoe= 52.6;
%object_height=159;
%object_shadow=object_height/tan(deg2rad(aoe));
angle=arg;
object_shadow=distance;
azimuth_corr=abs(azimuth-angle);
slength_corr=abs(slength-object_shadow);
%Find normalized matice
AM=mean2(azimuth_corr);
azimuth_corr=(azimuth_corr+std2(azimuth_corr))*2/AM;
%azimuth_corr=(azimuth_corr)*2/AM
x=min(min(azimuth_corr));
SM=mean2(slength_corr);
slength_corr=(slength_corr+std2(slength_corr))/SM;
%slength_corr=(slength_corr)/SM
y=min(min(slength_corr));
normalized=azimuth_corr.*slength_corr;

z=min(min(normalized));
[time,date]=find(normalized<=z)
if(size(time,1)>1)
   time=time(2);
end
if(size(date,1)>1)
   date=date(2);
end
[row3,col3] = find(normalized<=0.05*std2(normalized)+z);
%[row,col] = find(azimuth_corr<=1.2*x);
%AC=azimuth_corr<=10*x;
%SC=slength_corr<=10*y;
%[row2,col2] = find(slength_corr<=1.2*y);
%azimuth_corr(AC);
%offset date is 2 and time is 4
datetxt(date+2)
timetxt(time+4)
message = sprintf('The date is from %s to %s .\n And the time is from %s to %s .',datetxt{date},datetxt{date+4},timetxt{time+1},timetxt{time+7});
%message = sprintf('The date is from %s  .\n And the time is to %s .',datetxt{date+2},timetxt{time+4});
prompt = msgbox(message, 'Result');
%{
drawnow;	% Refresh screen to get rid of dialog box remnants.
if strcmpi(button, 'Cancel')
	close(gcf);	% Get rid of window.
	return;
end
%}

