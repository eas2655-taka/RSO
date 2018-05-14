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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%--- do not modify under this line---

dx=diff(xn);
dy=diff(yn);
disp(char(['x0=',num2str(xn(1)-dx(1)/2)]));
disp(char(['y0=',num2str(yn(1)-dy(1)/2)]));
[x2,y2]=meshgrid(xn,yn);

you=getenv('USER');
caseroot=['/data/',you,'/'];

disp('===== develop side bcs based on SODA 2.2.4 ');
vars={'u' 'v' 'temp' 'salt'};
vars1={'U' 'V' 'TEMP' 'SALT'};
srcdir='/data/dataset/ocean/SODA/'
mon={'01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12'};

for i=1:length(yr);
 yr0=yr(i);
 if yr0 >= 2009
   vars = vars1;
 end

 disp('===== side boundary condition');
 for m=1:12
  fn=[srcdir,'SODA_2.2.4_',num2str(yr0),mon{m},'.cdf'];
  disp(['working on ',fn]);
  if i==1 & m == 1
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

   % eastern bc
   tmpE = squeeze(tmp(I(end),Jw,:));
   for k=1:length(z0);
    tmpEk = tmpE(:,k);
    tmpEkm= nanmean(tmpEk,1);
    if isnan(tmpEkm)
       tmpEkm = nanmean(tmpE(:,k-1));
    end
    tmpEk(isnan(tmpEk))=tmpEkm;
    tmpE(:,k)=tmpEk;
   end
   [y1,z1]=meshgrid(y0(Jw),z0);
   [y2,z2]=meshgrid(yn,zn);
   tmpE1(:,:,m,n) = griddata(y1',z1',tmpE,y2',z2');

   % western bc
   tmpW = squeeze(tmp(I(1),Jw,:));
   for k=1:length(z0);
    tmpWk = tmpW(:,k);
    tmpWkm= nanmean(tmpWk,1);
    if isnan(tmpWkm)
       tmpWkm = nanmean(tmpW(:,k-1));
    end
    tmpWk(isnan(tmpWk))=tmpWkm;
    tmpW(:,k)=tmpWk;
   end
   tmpW1(:,:,m,n) = griddata(y1',z1',tmpW,y2',z2');

   % northern bc
   tmpN = squeeze(tmp(Iw,J(end),:));
   for k=1:length(z0);
    tmpNk = tmpN(:,k);
    tmpNkm= nanmean(tmpNk,1);
    if isnan(tmpNkm)
       tmpNkm = nanmean(tmpN(:,k-1));
    end
    tmpNk(isnan(tmpNk))=tmpNkm;
    tmpN(:,k)=tmpNk;
   end
   [x1,z1]=meshgrid(x0(Iw),z0);
   [x2,z2]=meshgrid(xn,zn);
   tmpN1(:,:,m,n) = griddata(x1',z1',tmpN,x2',z2');

   % southern bc
   tmpS = squeeze(tmp(Iw,J(1),:));
   for k=1:length(z0);
    tmpSk = tmpS(:,k);
    tmpSkm= nanmean(tmpSk,1);
    if isnan(tmpSkm)
       tmpSkm = nanmean(tmpS(:,k-1));
    end
    tmpSk(isnan(tmpSk))=tmpSkm;
    tmpS(:,k)=tmpSk;
   end
   tmpS1(:,:,m,n) = griddata(x1',z1',tmpS,x2',z2');

  end

 end % end loop for months

 % writing the files
 for n=1:length(vars)
   fid=fopen(char([caseroot,runcase,'/SODA_',vars{n},'_east_',num2str(yr0),'.bin']),'w','ieee-be');
   fwrite(fid,tmpE1(:,:,:,n),'float32');
   fclose(fid);
   fid=fopen(char([caseroot,runcase,'/SODA_',vars{n},'_west_',num2str(yr0),'.bin']),'w','ieee-be');
   fwrite(fid,tmpW1(:,:,:,n),'float32');
   fclose(fid);
   fid=fopen(char([caseroot,runcase,'/SODA_',vars{n},'_north_',num2str(yr0),'.bin']),'w','ieee-be');
   fwrite(fid,tmpN1(:,:,:,n),'float32');
   fclose(fid);
   fid=fopen(char([caseroot,runcase,'/SODA_',vars{n},'_south_',num2str(yr0),'.bin']),'w','ieee-be');
   fwrite(fid,tmpS1(:,:,:,n),'float32');
   fclose(fid);
 end

end
