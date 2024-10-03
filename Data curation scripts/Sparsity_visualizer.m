clear
clc

filename = 'C:\Dropbox (MIT)\Strain-product collaborative filtering\20190814 Strain-product web crawling results - curated + sorted';

strains = xlsread(filename,'A:A');
products = xlsread(filename,'E:E');
titer = xlsread(filename,'D:D');
num_strains = max(strains);
num_products = max(products);

strain_ordering = unique(strains,'stable');

entry_pairs = [strains, products];
strain_group = cell(num_strains,1);
num_prod_bystrain = zeros(num_strains,1);
for i = 1:num_strains
    strain_group{i} = entry_pairs(entry_pairs(:,1)==i,2);
    num_prod_bystrain(i) = size(strain_group{i},1);
end
[~,index] = sort(num_prod_bystrain);
strain_group = strain_group(index);
prod_ordering = [];
entry_pairs_re = [];
for i = 1:num_strains
    prod_ordering = [prod_ordering;strain_group{i}];
    j = length(strain_group{i});
    entry_pairs_re = [entry_pairs_re;[i*ones(j,1),strain_group{i}]];
end
prod_ordering = unique(prod_ordering,'stable');
for i = 1:size(entry_pairs_re,1)
    entry_pairs_re(i,2) = num_products-find(entry_pairs_re(i,2)==prod_ordering)+1;
end
entry_pairs_re(:,1) = num_strains-entry_pairs_re(:,1)+1;

data = zeros(num_strains,num_products);
for i = 1:size(entry_pairs_re,1)
    data(entry_pairs_re(i,1),entry_pairs_re(i,2)) = 1;
end

figure
sparsity_heatmap = pcolor(data);
set(sparsity_heatmap,'EdgeColor','none'); 
set(gca,'XTick',[],'YTick',[],'PlotBoxAspectRatio',[326 139 1]);
xlabel('Products','FontSize',18,'FontWeight','b')
ylabel('Strains','FontSize',18,'FontWeight','b')
