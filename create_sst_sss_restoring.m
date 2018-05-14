%% create a new case of MITgcm regional southern ocean run
close all;
clear all;

%% set path
addpath matlabfiles

%% bathymetry parmeters from create_topo
disp('set case name');
runcase='Drake.64t.10km.42lev';
toponame='Drake';
xr=[280 320]; % zonal extent
yr=[-70 -45]; % meridional extent 
disp('define a new grid');
xn = linspace(xr(1),xr(2),270);
yn = linspace(yr(1),yr(2),270);

% load vertical grid
srcdir='grid42/';
zn=-squeeze(rdmds([srcdir,'RC']));

% set years of side bcs to be extracted 
yr = 1980:1980;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%--- do not modify under this line---

dx=diff(xn);
dy=diff(yn);
disp(char(['x0=',num2str(xn(1)-dx(1)/2)]));
disp(char(['y0=',num2str(yn(1)-dy(1)/2)]));
[x2,y2]=meshgrid(xn,yn);

you=getenv('USER');
caseroot=['/data/',you,'/'];

disp('===== develop side bcs based on SODA 2.2.4 ');
vars={'temp' 'salt'};
vars1={'TEMP' 'SALT'};

srcdir='/data/dataset/ocean/SODA/'
mon={'01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12'};

for i=1:length(yr);
 yr0=yr(i);
 if yr0 >= 2009
   vars=vars1;
 end

 disp('===== restoring boundary condition');
 for m=1:12
  fn=[srcdir,'SODA_2.2.4_',num2str(yr0),mon{m},'.cdf'];
  disp(['working on ',fn]);

  if i == 1 & m == 1
  x0 = ncread(fn,'lon');
  y0 = ncread(fn,'lat');
  z0 = ncread(fn,'depth');
  z0(1)=0;
  z0(end)=6000;
  I=find(x0>=xn(1)&x0<=xn(end));
  J=find(y0>=yn(1)&y0<=yn(end));
  Iw=find(x0>=xn(1)-5&x0<=xn(end)+5);
  Jw=find(y0>=yn(1)-5&y0<=yn(end)+5);
  end

  for n=1:length(vars)
   tmp = ncread(fn,vars{n});

   tmpS = squeeze(tmp(Iw,Jw,1)); 
   I = find(isnan(tmpS));
   siz=size(tmpS);
   Wx=3;
   Wy=3;
   for l=1:length(I)
      [ii,jj]=ind2sub(siz,I(l));
      xr = max(1,ii-Wx):min(ii+Wx,siz(1));
      yr = max(1,jj-Wy):min(jj+Wy,siz(2));
      tmpS(ii,jj)=nanmean(nanmean(tmpS(xr,yr)));
   end
   [x1,y1]=meshgrid(x0(Iw),y0(Jw));
   [x2,y2]=meshgrid(xn,yn);
   tmpS1(:,:,m,n) = griddata(x1',y1',tmpS,x2',y2');

  end % end loop for tracers
 end % end loop for months

 % writing the files
 for n=1:length(vars)
   fid=fopen(char([caseroot,runcase,'/SODA_',vars{n},'_surface_',num2str(yr0),'.bin']),'w','ieee-be'); 
   fwrite(fid,tmpS1(:,:,:,n),'float32'); 
   fclose(fid);
 end

end

