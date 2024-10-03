function [U, b_u] = update_U(data,prod_from_str,U,V,b_u,b_v,k,lam,offset)
for i = 1:size(U,1) % i indicates strain number
    extract = prod_from_str{i}(:,1); % vector containing all product numbers that were made by strain i
    V_extract = V(extract,:); % extract a subset of V containing only the product row vectors that were made by strain i
    titer_extract = prod_from_str{i}(:,2); % vector containing all product titers that were made by strain i
    if offset == 1
        b_v_extract = titer_extract - b_v(extract);
    elseif offset == 0
        b_v_extract = titer_extract;
    else
        error('offset var must be 0 (without offset) or 1 (with offset)')
    end
    [U_update, b_u_update] = ridge_analytic(V_extract,b_v_extract,lam,offset);
    U(i,:) = U_update';
    b_u(i) = b_u_update;
end
end