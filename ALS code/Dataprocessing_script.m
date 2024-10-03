clear
clc

load R_pred_revert.mat
load strain_cons_dict
load prod_dict

n = 10; % specify top n results for each strain or product

num_strain = size(R_pred_revert,1)-1;
num_prod = size(R_pred_revert,2);

% find best products for each strain
bestprods = zeros(num_strain,n);
for i = 1:num_strain
    strain = R_pred_revert(i,:);
    [~,index] = maxk(strain,n);
    bestprods(i,:) = R_pred_revert(end,index);
end

bestprods_num = bestprods;

bestprods = [strain_cons_dict(:,2), num2cell(bestprods)];
for i = 1:num_strain
    for j = 2:size(bestprods,2)
        bestprods{i,j} = prod_dict{[prod_dict{:,1}]' == bestprods{i,j},2};
    end
end


% find best strains for each product
beststrains = zeros(num_prod,n+1);
for i = 1:num_prod
    product = R_pred_revert(1:end-1,i);
    [~,index] = maxk(product,n);
    beststrains(i,:) = [R_pred_revert(end,i),index'];
end

beststrains = sortrows(beststrains,1);
beststrains_num = beststrains;
beststrains = num2cell(beststrains);

for i = 1:num_prod
    beststrains{i,1} = prod_dict{[prod_dict{:,1}]' == beststrains{i,1},2};
    for j = 2:size(beststrains,2)
        beststrains{i,j} = strain_cons_dict{[strain_cons_dict{:,1}]' == beststrains{i,j},2};
    end
end
