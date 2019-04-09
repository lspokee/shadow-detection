filename = 'databasev1.xlsx';
xlRange = 'D6:O38';
azimuth = xlsread(filename,2,xlRange);
slength = xlsread(filename,3,xlRange);
[~, datetxt] = xlsread(filename,2,'B1:R1');
[~, timetxt] = xlsread(filename,2,'A2:A42');
%http://www.hko.gov.hk/gts/astronomy/SunPathDay3_ue.htm
angle=210.9;
aoe= 52.6;
object_height=159;
object_shadow=object_height/tan(deg2rad(aoe));
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
   time=time(1);
end
if(size(date,1)>1)
   date=date(1);
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
message = sprintf('The date is from %s to %s .\n And the time is from %s to %s .',datetxt{date+1},datetxt{date+3},timetxt{time+2},timetxt{time+6});
%message = sprintf('The date is from %s  .\n And the time is to %s .',datetxt{date+2},timetxt{time+4});
prompt = msgbox(message, 'Result');
%{
drawnow;	% Refresh screen to get rid of dialog box remnants.
if strcmpi(button, 'Cancel')
	close(gcf);	% Get rid of window.
	return;
end
%}

