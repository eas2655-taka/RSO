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
N=size(x2);

% load topography
srcdir='grid/';
zn=-squeeze(rdmds([srcdir,'RC']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('===== develop side bcs based on Pham model ');
srcdir=[caseroot,'Ecosystem_28x28/monthly_tracers/']

% load the source data first
temp(:,:,:,1:10,:) = rdmds([srcdir,'PTRD1'],NaN);
temp(:,:,:,11:20,:) = rdmds([srcdir,'PTRD2'],NaN);
temp(:,:,:,21:30,:) = rdmds([srcdir,'PTRD3'],NaN);
temp(:,:,:,31:41,:) = rdmds([srcdir,'PTRD4'],NaN);

disp('===== side boundary condition');

% setting up original model domain (global)
d=360/128;
x0 = d/2:d:360-d/2;
y0 = -90+d/2:d:90-d/2;
load z23.mat; z0=z;
z0(1)=0;
z0(end)=-6000;
z0 = -z0;
I=find(x0>=xn(1)&x0<=xn(end));
J=find(y0>=yn(1)&y0<=yn(end));
Iw=find(x0>=xn(1)-5&x0<=xn(end)+5);
Jw=find(y0>=yn(1)-5&y0<=yn(end)+5);

tmpE1 = zeros(N(1),42,12,41);
tmpW1 = zeros(N(1),42,12,41);
tmpN1 = zeros(N(2),42,12,41);
tmpS1 = zeros(N(2),42,12,41);

% loop over the variables
for n=1:41
 disp(['working on tr=',num2str(n)])
 for m=1:12
   % extract n-th tracer for "m" month
   tmp = squeeze(temp(:,:,:,n,m));
   tmp(tmp==0)=NaN;

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

  end % end for loop: month
end % end for loop: variable 

 % writing the files
 for n=1:41
   fid=fopen(char([caseroot,runcase,'/tr',num2str(n),'_east.bin']),'w','ieee-be'); 
   fwrite(fid,tmpE1(:,:,:,n),'float32'); 
   fclose(fid);
   fid=fopen(char([caseroot,runcase,'/tr',num2str(n),'_west.bin']),'w','ieee-be'); 
   fwrite(fid,tmpW1(:,:,:,n),'float32'); 
   fclose(fid);
   fid=fopen(char([caseroot,runcase,'/tr',num2str(n),'_north.bin']),'w','ieee-be'); 
   fwrite(fid,tmpN1(:,:,:,n),'float32'); 
   fclose(fid);
   fid=fopen(char([caseroot,runcase,'/tr',num2str(n),'_south.bin']),'w','ieee-be'); 
   fwrite(fid,tmpS1(:,:,:,n),'float32'); 
   fclose(fid);
 end


