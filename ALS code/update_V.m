function [V, b_v] = update_V(data,str_from_prod,U,V,b_u,b_v,k,lam,offset)
for i = 1:size(V,1) % i indicates product number
    extract = str_from_prod{i}(:,1); % vector containing all strain numbers that made by product i
    U_extract = U(extract,:); % extract a subset of U containing only the strain row vectors that made product i
    titer_extract = str_from_prod{i}(:,2); % vector containing all titers of product i
    if offset == 1
        b_u_extract = titer_extract - b_u(extract);
    elseif offset == 0
        b_u_extract = titer_extract;
    else
        error('offset var must be 0 (without offset) or 1 (with offset)')
    end
    [V_update, b_v_update] = ridge_analytic(U_extract,b_u_extract,lam,offset);
    V(i,:) = V_update';
    b_v(i) = b_v_update;
end
end