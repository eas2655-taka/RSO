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

% set years of surface forcing to be extracted 
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

% 1. NCEP reanalysis
disp('===== surface bc: NCEP reanalysis ver 1')
srcdir='/data/dataset/atmos/reanalysis/ncep1/matlab/';
fn={'uflx_194801_201412.mat' 'vflx_194801_201412.mat' ... 
    'qnet_194801_201412.mat' 'emp_194801_201412.mat'};
vars={'uflx' 'vflx' 'qnet' 'emp'};

for i=1:length(vars);
  load(char([srcdir,fn{i}]));
  cmd=['tmp=',vars{i},';'];
  eval(char(cmd));
  x=double(x);
  y=double(y);
  tmp=double(tmp);
  [xx,yy]=meshgrid(x,y);
  for k=1:length(yr)
     yr0=yr(k);
     disp(['working on ',vars{i},' in ',num2str(yr0)]);
     nt=((yr0-1948)*12+1):(yr0-1948+1)*12;
     for j=1:12
        tmp3(:,:,j)=griddata(xx',yy',tmp(:,:,nt(j)),x2',y2');
     end
     wn=[caseroot,runcase,'/ncep1_',vars{i},'_',num2str(yr0),'.bin'];
     fid=fopen(char(wn),'w','ieee-be');
     fwrite(fid,tmp3,'float32');
     fclose(fid);
   end
end

% option 2. ERA-Interim
%European Centre for Medium-Range Weather Forecasts. 2012. ERA-Interim Project, Monthly Means. Research Data Archive at the National Center for Atmospheric Research, Computational and Information Systems Laboratory. https://doi.org/10.5065/D68050NT. Accessed 1ST APR 2018.


