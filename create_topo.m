%% create a new case of MITgcm regional southern ocean run
close all;
clear all;

%% define model topography ----
disp('set case name');
runcase='Drake.64t.10km.42lev';
toponame='Drake';
xr=[280 320]; % zonal extent
yr=[-70 -45]; % meridional extent 
disp('define a new grid');
xn = linspace(xr(1),xr(2),270);
yn = linspace(yr(1),yr(2),270);
W=2; % running mean window : how much to smooth the topography


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%--- do not modify under this line---

%% set path
addpath matlabfiles

disp('===== set model bathymetry');
you=getenv('USER');
caseroot=['/data/',you,'/'];
cmd=['! mkdir ',caseroot,runcase]; eval(char(cmd));

x3=ncread('/data2/dataset/ocean/etopo/etopo2.nc','lon');
y=ncread('/data2/dataset/ocean/etopo/etopo2.nc','lat');
z3=ncread('/data2/dataset/ocean/etopo/etopo2.nc','topo');
N=size(z3);
topo(1:N(1)/2,:)=z3(N(1)/2+1:N(1),:);
topo(N(1)/2+1:N(1),:)=z3(1:N(1)/2,:);
dx=diff(x3);
x=dx(1)/2:dx(1):(360-dx(1)/2);

I=find(x>xr(1)-1&x<xr(2)+1);
J=find(y>yr(1)-1&y<yr(2)+1);
x0 = double(x(I));
y0 = double(y(J));
topo0 = double(topo(I,J));
disp('===== original grid - etopo 2 min resolution');
disp(char(['Nx = ',num2str(length(I)),' x0=',num2str(x0(1)-dx(1)/2)]));
disp(char(['Ny = ',num2str(length(J)),' y0=',num2str(y0(1)-dx(1)/2)]));
[xx,yy]=meshgrid(x0,y0);
[x2,y2]=meshgrid(xn,yn);
dx=diff(xn);
dy=diff(yn);
disp('===== new grid');
disp(char(['Nx = ',num2str(length(xn)),', x0=',num2str(xn(1)-dx(1)/2),'dx = ',num2str(dx(1))]));
disp(char(['Ny = ',num2str(length(yn)),', y0=',num2str(yn(1)-dy(1)/2),'dy = ',num2str(dy(1))]));
topo1=griddata(xx',yy',topo0,x2',y2');

% -- plot topography
N=size(x2);
for i=1:N(2)
   ir=max(1,i-W/2):min(N(2),i+W/2);
   for j=1:N(1)
      jr=max(1,j-W/2):min(N(1),j+W/2);
      topo2(i,j)=mean(mean(topo1(ir,jr)));
   end
end

figure(1);
pcolor(x2',y2',topo1);
shading flat;
colorbar;
xlabel('longitude');
ylabel('latitude');
title('original topography');
caxis([-6000 0]);
drawnow;

figure(2);
pcolor(x2',y2',topo2);
shading flat;
colorbar;
xlabel('longitude');
ylabel('latitude');
title('smoothed topography');
caxis([-6000 0]);
drawnow;

fid=fopen(char([caseroot,runcase,'/',toponame,'_topography.bin']),'w','ieee-be'); 
fwrite(fid,topo2,'float32'); fclose(fid);

