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

% load topography
srcdir='grid/';
zn=-squeeze(rdmds([srcdir,'RC']));

W=5;

disp('===== develop initial cond based on Pham model ');
srcdir=[caseroot,'Ecosystem_28x28/monthly_tracers/']

% load the source data first
temp(:,:,:,1:10,1) = rdmds([srcdir,'PTRD1'],5040060);
temp(:,:,:,11:20,1) = rdmds([srcdir,'PTRD2'],5040060);
temp(:,:,:,21:30,1) = rdmds([srcdir,'PTRD3'],5040060);
temp(:,:,:,31:41,1) = rdmds([srcdir,'PTRD4'],5040060);

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

% initial condition
disp('===== initial condition based on january of first year');
N=size(x2);
tmp3d2 = zeros(N(2),N(1),42,41);
for n=1:41
   tmp = squeeze(temp(:,:,:,n,1));
   [x1,y1]=meshgrid(x0(Iw),y0(Jw));
   x1=x1';
   y1=y1';
   tmp3d = squeeze(tmp(Iw,Jw,:));
   for k=1:length(z0);
      tmp2d=tmp3d(:,:,k);
      tmp2d(tmp2d==0)=NaN;
      N2=size(tmp2d);
      index=find(isnan(tmp2d));
      for l=1:length(index)
         [in,jn]=ind2sub(size(tmp2d),index(l));
         tmp2d(index(l))=nanmean(nanmean(tmp2d(max(1,in-W):min(in+W,N2(1)),max(1,jn-W):min(jn+W,N2(2)))));
         if isnan(tmp2d(index(l)))
            tmp2d(index(l))=nanmean(nanmean(tmp2d));
         end
      end
      if isnan(nanmean(tmp2d))
         tmp3d(:,:,k)=tmp3d(:,:,k-1);
      else
         tmp3d(:,:,k)=tmp2d;
      end
   end
   for i=1:N2(1)
      for j=1:N2(2)
         tmp3d1(i,j,:)=interp1(z0,squeeze(tmp3d(i,j,:))',zn,'linear');
      end
   end
   [x2,y2]=meshgrid(xn,yn);
   for k=1:length(zn)
      disp(['working on layer =',num2str(k)]);
      tmp2d=tmp3d1(:,:,k);
      tmp3d2(:,:,k,n) = griddata(x1,y1,tmp2d,x2',y2');
   end
   
end

  % writing the files
  for n=1:41
   fid=fopen(char([caseroot,runcase,'/tr',num2str(n),'_init.bin']),'w','ieee-be'); 
   fwrite(fid,tmp3d2(:,:,:,n),'float32'); 
   fclose(fid);
  end


