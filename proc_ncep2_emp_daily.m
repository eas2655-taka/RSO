close all;
clear all;

% process data year by year
selyear = 2008:2012;
c0=selyear-1979+1;
var = 'latent';

% define grid - Drake Passage -  
xr=[280 320]; % zonal extent
yr=[-70 -45]; % meridional extent
disp('define a new grid');
xn = linspace(xr(1),xr(2),270);
yn = linspace(yr(1),yr(2),270);
you=getenv('USER');
caseroot=['/data/',you,'/'];
[x2,y2]=meshgrid(xn,yn);
x2=x2'; y2=y2';
% ------------------------------
% alternatively just load in x and y
%x2=rdmds('grid_UFZ/XC');
%y2=rdmds('grid_UFZ/YC');
% ------------------------------
N=size(x2);

disp('read coordinates of raw data');
src='/data/dataset/atmos/reanalysis/ncep2/daily/';
x=ncread([src,'NCEP2_daily_',var,'.nc'],'LONN95_97');
y=ncread([src,'NCEP2_daily_',var,'.nc'],'LAT');
time=ncread([src,'NCEP2_daily_',var,'.nc'],'TIME');

% read in net heat flux (Qnet)
disp('read raw data');
xlv = 2.501e6-2370.*10;
var='latent'; vars='LHTFL';
taux=ncread([src,'NCEP2_daily_',var,'.nc'],vars);
var='precip'; vars='PRATE';
taux=(taux/xlv - ncread([src,'NCEP2_daily_',var,'.nc'],vars))/1025;
var='EmP';
%(here taux is used as a dummy variable)

disp('start interpolation, year by year')
taux2=zeros(N(1),N(2),360*length(selyear));

for g=1:length(selyear)

syr = selyear(g)

% count days and set 
cnt=0;
t0(1)=1;
for yr=1979:2017
   if rem(yr-1980,4)==0
     disp(['yr=',num2str(yr),' is a leap year']);
     ds=366;
   else
     ds=365;
   end
   cnt=cnt+1;
   if cnt>=2
      t0(cnt)=1+t1(cnt-1);
   end
   t1(cnt)=t0(cnt)+ds-1;
   % tr is the indices for the selected year
   tr=[t0(cnt):t1(cnt)];
      if yr == syr
         taux0(:,:,1:ds)=taux(:,:,tr);
         for i=1:length(x)
            for j=1:length(y)
               % interpolate the 365/366 days into 360 days
               taux1(i,j,:)=interp1([1:ds]/ds',squeeze(taux0(i,j,1:ds)),[1:360]/360');
            end % y
         end % x
      end % if statement to select year
end %loop year

% this should work for western hemisphere %
[x1,y1]=meshgrid(x+360,y);
N=size(x2); % x2 is the model grid from grid file
for n=1:360 % for each day interpolate onto model grid points
   taux2(:,:,(g-1)*360+n) = griddata(x1',y1',taux1(:,:,n),x2,y2);
end

end % loop over selyear

% write it out
taux2(isnan(taux2))=0;
fn=['NCEP2_',var,'_',num2str(selyear(1)),'_',num2str(selyear(end)),'.bin'];
fid=fopen(fn,'w','ieee-be');
fwrite(fid,taux2,'float32');
fclose(fid);


