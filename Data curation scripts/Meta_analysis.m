%%
clear
clc

% filename = 'D:\Dropbox (MIT)\MIT\Strain-product collaborative filtering\20200411 Strain-product web crawling results combined - finalized';
% 
% data = xlsread(filename,'database','C:J');
% data = data(:,[1,5,8,4]);
% 
% [num,text,~] = xlsread(filename,'strain dict','A:B');
% strain_dict = [num2cell(num),text(2:end,2)];
% 
% [num,text,~] = xlsread(filename,'strain dict','E:F');
% strain_cons_dict = [num2cell(num),text(2:end,2)];
% 
% [num,text,~] = xlsread(filename,'prod dict','A:D');
% prod_dict = [num2cell(num(:,1)),text(2:end,2:3),num2cell(num(:,4))];

% data.mat contains database information for all strains and products.
% 1st column shows consolidated strain #s
% 2nd column shows product #s,
% 3rd column shows product class #s,
% 4th column shows titers in g/L

load data_full.mat 
load strain_cons_dict.mat
load prod_dict.mat

% Getting dimensions
num_strain_cons = size(strain_cons_dict,1);
num_prod = size(prod_dict,1);
num_data = size(data,1);

%% Descriptive statistics for individual strain-product pairs
stat_strain_prod = [];
for i = 1:num_strain_cons
    subdata_strain = data(data(:,1) == i,:);
    subprod_list = unique(subdata_strain(:,2));
    for j = 1:length(subprod_list)
        subdata_strain_prod = subdata_strain(subdata_strain(:,2) == subprod_list(j),:);
        sub_class = subdata_strain_prod(1,3);
        sub_min = min(subdata_strain_prod(:,4));
        sub_max = max(subdata_strain_prod(:,4));
        sub_avg = mean(subdata_strain_prod(:,4));
        sub_med = median(subdata_strain_prod(:,4));
        sub_std = std(subdata_strain_prod(:,4));
        sub_n = length(subdata_strain_prod(:,4));
        entry = [i, subprod_list(j), sub_class, sub_min, sub_max, sub_avg, sub_med, sub_std, sub_n];
        stat_strain_prod = [stat_strain_prod; entry];
    end
end

%% Titer ranges according to class
[~,index] = sort(data(:,3));
class_titer = data(index,[3,4]);
class_number = unique(class_titer(:,1));
class_range = [];
for i = 1:length(class_number)
    sub_class = class_titer(class_titer(:,1) == class_number(i),:);
    sub_min = min(sub_class(:,2));
    sub_max = max(sub_class(:,2));
    sub_avg = mean(sub_class(:,2));
    sub_med = median(sub_class(:,2));
    sub_std = std(sub_class(:,2));
    entry = [class_number(i), sub_min, sub_max, sub_avg, sub_med, sub_std];
    class_range = [class_range;entry];
end

%% Number of strains tested for each product

% note that the number of products for each strain was already determined
% in the dataprocessing stage
[~,index] = sort(data(:,2));
sortbyprod = data(index,:);
numstrains = zeros(num_prod,1);
for i = 1:num_prod
    subdata = sortbyprod(sortbyprod(:,2) == i,:);
    numstrains(i) = size(subdata,1);
end

%% Product diversity of each strain

prod_div = [linspace(1,num_strain_cons,num_strain_cons)',zeros(num_strain_cons,1)];
for i = 1:num_strain_cons
    subdata_strain = data(data(:,1) == i,:);
    prod_div(i,2) = length(unique(subdata_strain(:,2)));
end

%% Strain diversity of each product

strain_div = [linspace(1,num_prod,num_prod)',zeros(num_prod,1)];
for i = 1:num_prod
    subdata_prod = data(data(:,2) == i,:);
    strain_div(i,2) = length(unique(subdata_prod(:,1)));
end