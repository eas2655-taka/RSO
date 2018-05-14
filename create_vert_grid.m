close all
clear all

% create vertical grid

% set parameters
N1 = 15;
N2 = 65;
N3 = 100;

% vertical discretization 
dzmin = 10;
Ht = 5700;

% solve for a factor
a = (Ht - dzmin*N3)/((N2-N1)^3/3+(N2-N1)^2*(N3-N2));

% create dz array
n = 1:N3;
dz(1:N1)    = dzmin; 
dz(N1+1:N2) = dzmin+a*(n(N1+1:N2)-N1).^2;
dz(N2+1:N3)  = dz(N2);

% print out result
dztxt = num2str(dz(1));
zf(1)=0;
zf(2)=dz(1);
zc(1)=dz(1)/2;
for k=2:N3
 dztxt = [dztxt,', ',num2str(dz(k))];
 zf(k+1)=zf(k)+dz(k);
 zc(k)=zc(k-1)+.5*(dz(k-1)+dz(k));
end

figure(1);
subplot(2,1,1);
plot(dz);
subplot(2,1,2);
plot(zf);


