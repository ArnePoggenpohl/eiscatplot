function f=myb(nl,cut)
% create palette with nl levels
if nargin<2, cut=[]; end
if nargin==0, nl=[]; end
if isempty(cut), cut=0; end
if isempty(nl)
 nl=size(get(gcf,'colormap'),1);
end
f=[0 0 0 0 0 1 2 2 2 2 2 2 2
   0 0 0 1 2 2 2 1 0 0 0 1 2
   0 1 2 1 0 0 0 0 0 1 2 2 2]'/2;
nc=size(f,1);
n=nc-cut;
b=round([0:n-1]/(n-1)*(nl-1))+1;
%f=sin(interp1(b,f(1:n,:),1:nl)*pi/2);
f=tanh(interp1(b,f(1:n,:),1:nl))/tanh(1);
return