function out = smooth_2d(in,Wx,Wy)

%
% Smoothing input array with Wx points in x and Wy points in y
%
% input: in(x,y,z)
% output:out(x,y,z) 
%

N=size(in);
hWx=round(Wx/2);
hWy=round(Wy/2);
out=zeros(N);
if length(N)==2
   N(3)=1;
end

for k=1:N(3)
   disp(['working on layer=',num2str(k)]);
   tmp=in(:,:,k);
   for i=1:N(1)
      imin=max(1,i-hWx);
      imax=min(N(1),i+hWx);
      for j=1:N(2)
         jmin=max(1,j-hWy);
         jmax=min(N(2),j+hWy);
         if tmp(i,j)~=0
            tmp2=tmp(imin:imax,jmin:jmax);
            tmp2(tmp2==0)=NaN;
            tmp1(i,j)=nanmean(nanmean(tmp2));
         else
            tmp1(i,j)=0;
         end
      end
   end
   out(:,:,k)=tmp1;
end

