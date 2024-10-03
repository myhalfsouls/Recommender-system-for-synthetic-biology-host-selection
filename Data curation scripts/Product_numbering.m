clear
clc

% SORT DATA BY THE PROPER COLUMN BEFORE PROCEEDING

filename = 'D:\Dropbox (MIT)\MIT\Strain-product collaborative filtering\20200411 Strain-product web crawling results combined - finalized';
[~,products,~] = xlsread(filename,'Database','H:H');
products = lower(products(2:end));
products_unique = unique(products,'stable');
products_number = num2cell(linspace(1,length(products_unique),length(products_unique))');
products_dict = [products_unique,products_number];
number = cell(length(products),1);
for i = 1:length(products)
    for j = 1:length(products_dict)
        if strcmp(products{i},products_dict{j,1})
            number{i} = products_dict{j,2};
        end
    end
end
productnumbering = [number,products];

%% Inserting product type

type = cell(length(products),1);

[~,type_dict,~] = xlsread(filename,'prod dict','B:C');
type_dict = type_dict(2:end,:);

for i = 1:length(products)
    for j = 1:length(products_unique)
        if strcmp(products{i},type_dict{j,1})
            type{i} = type_dict{j,2};
        end
    end
end

%% Numbering product class
[~,class,~] = xlsread(filename,'prod dict','C:C');
class = lower(class(2:end));
class_unique = unique(class,'stable');
class_number = num2cell(linspace(1,length(class_unique),length(class_unique))');
class_dict = [class_unique,class_number];
classnumbering = zeros(length(class),1);
for i = 1:length(class)
    for j = 1:length(class_unique)
        if strcmp(class{i},class_dict{j,1})
            classnumbering(i) = class_dict{j,2};
        end
    end
end

% [~,classdata,~] = xlsread(filename,'Database','I:I');
% classdata = lower(classdata(2:end));
% classnumbering = zeros(length(products),1);
% for i = 1:length(products)
%     for j = 1:length(class_unique)
%         if strcmp(classdata{i},class_dict{j,1})
%             classnumbering(i) = class_dict{j,2};
%         end
%     end
% end

