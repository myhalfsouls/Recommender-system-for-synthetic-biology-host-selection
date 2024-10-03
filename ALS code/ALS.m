function [U,V,b_u,b_v] = ALS(data_train,k,lam,max_iter,tol,offset)

% data should be in the format of n-by-3 matrix where the first column
% contains the strain number, second column contains the product number,
% and the third column contains the normalized titer values. Each row is
% then a unique strain/product combination.

% offset = 1 with offset. offset = 0 without offset

% define various sizes
num_strains = max(data_train(:,1)); % number of strains
num_products = max(data_train(:,2)); % number of products
n = size(data_train,1); % number of unique datapoints

% group data into by-strain and by-product categories
str_from_prod = cell(1,num_products); % str_from_prod{i} is an x-by-2 matrix where each row contains the strain number (1st entry) and normalized titer (2nd entry) of all attempts at making product i
prod_from_str = cell(1,num_strains); % prod_from_str{i} is an x-by-2 matrix where each row contains the product number (1st entry) and normalized titer (2nd entry) of all attempts that use strain i
for i = 1:num_products
    str_from_prod{i} = data_train(data_train(:,2)==i,[1 3]);
end
for i = 1:num_strains
    prod_from_str{i} = data_train(data_train(:,1)==i,[2 3]);
end

% set initial guesses for U, b_u, V, b_v
U = randn(num_strains,k) + 1/k; % note that each ROW is a strain entry (num_strains-by-k matrix)
V = randn(num_products,k) + 1/k; % note that each ROW is a product entry (num_products-by-k matrix)
b_u = zeros(num_strains,1);
b_v = zeros(num_products,1);

% begin ALS
if offset == 1
b_u_mat = repmat(b_u,1,size(V,1));
b_v_mat = repmat(b_v,1,size(U,1))';
R_pred_before = U*V'+b_u_mat+b_v_mat;
else
R_pred_before = U*V';
end

for iter = 1:max_iter
    [U,b_u] = update_U(data_train,prod_from_str,U,V,b_u,b_v,k,lam,offset);
    [V,b_v] = update_V(data_train,str_from_prod,U,V,b_u,b_v,k,lam,offset);
    if offset == 1
    b_u_mat = repmat(b_u,1,size(V,1));
    b_v_mat = repmat(b_v,1,size(U,1))';
    R_pred = U*V'+b_u_mat+b_v_mat;
    else
    R_pred = U*V';
    end
    diff = norm(R_pred-R_pred_before);
    if diff < tol
        break
    end
    R_pred_before = R_pred;
end

end