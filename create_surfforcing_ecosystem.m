%% create a new case of MITgcm regional southern ocean run
close all;
clear all;

user=getenv('USER');
disp('set case name');
runcase='ecoRSO.64t.10km.42lev';
caseroot=['/gpfs/pace1/project/eas-ito/',user,'/RSO_cases/'];
cmd=['! mkdir -p ',caseroot,runcase]; eval(char(cmd));

%% set path
addpath matlabfiles

%% subdomain----
xn0=rdmds('grid/XC'); xn=xn0(:,1)';
yn0=rdmds('grid/YC'); yn=yn0(1,:);
% ---------------
dx=diff(xn);
dy=diff(yn);
disp(char(['x0=',num2str(xn(1)-dx(1)/2)]));
disp(char(['y0=',num2str(yn(1)-dy(1)/2)]));
[x2,y2]=meshgrid(xn,yn);

srcdir=[caseroot,'Ecosystem_28x28/forcing/']
fn={'solfe_fed.bin' 'ndep_mod.bin' 'par_g3d.bin' 'wndsp128x64.bin'};
wn0={'solfe_ufz.bin' 'ndep_ufz.bin' 'par_ufz.bin' 'wspd_ufz.bin'};

% load the source data first
for n=1:4
   temp(:,:,:,n) = loadbin([srcdir,fn{n}],[128 64 12]);
end

% setting up original model domain (global)
d=360/128;
x0 = d/2:d:360-d/2;
y0 = -90+d/2:d:90-d/2;
load z23.mat; z0=z;
z0(1)=0;
z0(end)=-6000;
z0=-z0;
I=find(x0>=xn(1)&x0<=xn(end));
J=find(y0>=yn(1)&y0<=yn(end));
Iw=find(x0>=xn(1)-5&x0<=xn(end)+5);
Jw=find(y0>=yn(1)-5&y0<=yn(end)+5);

for i=1:4
  tmp=temp(:,:,:,i);
  x=x0;
  y=y0;
  tmp=double(tmp);
  [xx,yy]=meshgrid(x,y);
     for j=1:12
        tmp3(:,:,j)=griddata(xx',yy',tmp(:,:,j),x2',y2');
     end
     wn=[caseroot,runcase,'/',wn0{i}];
     fid=fopen(char(wn),'w','ieee-be');
     fwrite(fid,tmp3,'float32');
     fclose(fid);
end

