function [th,th0] = ridge_analytic(X,Y,lam,offset)
k = size(X,2);
if offset == 1
    xm = mean(X,1);
    ym = mean(Y);
    Z = X-xm;
    T = Y-ym;
    th = linsolve(Z'*Z+lam*eye(k),Z'*T);
    th0 = ym-xm*th;
elseif offset == 0
    th = linsolve(X'*X+lam*eye(k),X'*Y);
    th0 = 0;
end