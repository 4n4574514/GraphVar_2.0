function S= genlouvain_multislice(varargin)

%% combine all W´s per subjects (n_dyn) in cell array A of square symmetric NxN matrices of equal size each representing one of the T ordered, undirected network "slices".
A = rot90(varargin,3);

%% multislice modularity with nearest-slice identity arcs of equal strength omega is calculated
gamma = 1;
omega = 1;

N=length(A{1});
T=length(A);
B=spalloc(N*T,N*T,N*N*T+2*N*T);
twomu=0;
for s=1:T
    k=sum(A{s});
    twom=sum(k);
    twomu=twomu+twom;
    indx=[1:N]+(s-1)*N;
    B(indx,indx)=A{s}-gamma*k'*k/twom;
end
twomu=twomu+2*omega*N*(T-1);
B = B + omega*spdiags(ones(N*T,2),[-N,N],N*T,N*T);
[S,Q] = genlouvain(B);
Q = Q/twomu
So = reshape(S,N,T);
S = flipud(rot90(So)); %T x N martrix

 %%Note that the last command conveniently reshapes the community assignment vector into an N (nodes) by T (slices) matrix
 %%so that the movement of identified nodes between communities can be easily tracked through the slices. 
