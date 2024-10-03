clear
clc

filename = 'C:\Dropbox (MIT)\MIT\Strain-product collaborative filtering\20190814 Strain-product web crawling results - curated + sorted';

strains = xlsread(filename,'A:A');
products = xlsread(filename,'E:E');
titer = xlsread(filename,'D:D');
num_strains = max(strains);
num_products = max(products);

entry_pairs = [strains, products];
data_raw = zeros(num_strains,num_products);
data_raw_titer = zeros(num_strains,num_products);
for i = 1:size(entry_pairs,1)
    data_raw(entry_pairs(i,1),entry_pairs(i,2)) = 1;
    data_raw_titer(entry_pairs(i,1),entry_pairs(i,2)) = titer(i);
end

prod_by_strain = sum(data_raw');
strain_ranking = sortrows([prod_by_strain',linspace(1,num_strains,num_strains)'],'descend');
strain_by_prod = sum(data_raw);
prod_ranking = sortrows([strain_by_prod',linspace(1,num_products,num_products)'],'descend');
data_sorted_rows = zeros(num_strains,num_products);
data_sorted_rows_titer = zeros(num_strains,num_products);
for i = 1:num_strains
    data_sorted_rows_titer(i,:) = data_raw_titer(strain_ranking(i,2),:);
end
data_sorted = zeros(num_strains,num_products);
data_sorted_titer = zeros(num_strains,num_products);
for j = 1:num_products
    data_sorted_titer(:,j) = data_sorted_rows_titer(:,prod_ranking(j,2));
end

figure
titer_heatmap = pcolor(data_raw_titer); 
colormap parula
set(titer_heatmap,'EdgeColor','none'); 
set(gca,'XTick',[],'YTick',[],'colorscale','log','PlotBoxAspectRatio',[size(data_sorted_titer,2) size(data_sorted_titer,1) 1]);
xlabel('Products','FontSize',18,'FontWeight','b')
ylabel('Strains','FontSize',18,'FontWeight','b')
cbar = colorbar;
cbar.FontSize = 18;
cbar.FontWeight = 'b';