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
ax1 = subplot(1,5,1);
imshow(newim1)
ax2 = subplot(1,5,2);
imshow(newim2)
%setAllowAxesZoom(h,ax2,false);
ax3 = subplot(1,5,3);
imshow(newim3)
%setAxesZoomMotion(h,ax3,'horizontal');
ax4 = subplot(1,5,4);
imshow(newim4)
%setAxesZoomMotion(h,ax4,'vertical');
ax5 = subplot(1,5,5);
imshow(newim5)
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
shadow_mask = shadow_ratio>-1.2;


shadow_mask(1:5,:) = 0;
shadow_mask(end-5:end,:) = 0;
shadow_mask(:,1:5) = 0;
shadow_mask(:,end-5:end) = 0;
shadow_mask(1:1500,:)=1;
shadow_mask(1720:end,:) = 1;
shadow_mask(:,1:1780) = 1;
shadow_mask(:,2200:end) = 1;
figure, imshow(shadow_mask, []); 
% NOTE: Depending on the shadow size that you want to consider,
% you can change the area size threshold
shadow_mask = bwareaopen(shadow_mask, 100);
%J = shadow_mask;

M_S= im2double(imread(fullfile(pwd, 'images','sem2','M_S_fin.png')));
J(:,:)=M_S(:,:,1)>0.5;

Kmedian = medfilt2(J);
K = wiener2(Kmedian,[5 5]);
K = wiener2(K,[7 7]);
%figure,imshow(Kmedian);
L=~K;
%im3=imread(fullfile(pwd, 'images','sem2','M_S_fin.png'));
figure,imshow(K);


[row,col]=find(L);
y1=min(row);
%y2=max(row);
%x1=min(col);
%x2=max(col);
exrow=L(y1,:);
x1=find(exrow, 1 );
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


filename = 'databasev2.xlsx';
xlRange = 'D6:O38';
azimuth = xlsread(filename,5,xlRange);
slength = xlsread(filename,6,xlRange);
[~, datetxt] = xlsread(filename,5,'B1:R1');
[~, timetxt] = xlsread(filename,5,'A2:A42');
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
Datearray(5,2)=0;
Datearray(1,1)=date;
Datearray(1,2)=time-4;
Datearray(2,1)=date-1;
Datearray(2,2)=time-3;
Datearray(3,1)=date-1;
Datearray(3,2)=time-1;
Datearray(4,1)=date-1;
Datearray(4,2)=time-2;
Datearray(5,1)=date;
Datearray(5,2)=time-1;


FrameName = {'Frame1';'Frame2';'Frame3';'Frame4';'Frame5'};
AzumithResult = [229.8655;231.0028;229.7664;234.2316;235.6439];
ShadowLengthResult= [271.2232;252.1261;263.5773;236.6169;240.6422];
DateResult = Datearray(:,1);
TimeResult = Datearray(:,2);
T = table(AzumithResult,ShadowLengthResult,DateResult,TimeResult,'RowNames',FrameName);
%LastName = {'Smith';'Johnson';'Williams';'Jones';'Brown'};
%Age = [38;43;38;40;49];
%Height = [71;69;64;67;64];
%Weight = [176;163;131;133;119];
%T = table(Age,Height,Weight,'RowNames',LastName);
figure, uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
    'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);

%figure, uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
%    'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1])
datetxt(date-1)
timetxt(time+4)

message = sprintf('The date is from %s to %s .\n And the time is from %s to %s .',datetxt{date+1},datetxt{date-3},timetxt{time+1},timetxt{time+7});
%message = sprintf('The date is from %s  .\n And the time is to %s .',datetxt{date+2},timetxt{time+4});
prompt = msgbox(message, 'Result');
%{
drawnow;	% Refresh screen to get rid of dialog box remnants.
if strcmpi(button, 'Cancel')
	close(gcf);	% Get rid of window.
	return;
end
%}
