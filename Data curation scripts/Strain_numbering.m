clear
clc

% SORT DATA BY THE PROPER COLUMN BEFORE PROCEEDING

filename = 'C:\Dropbox (MIT)\MIT\Strain-product collaborative filtering\20200410 Strain-product web crawling results combined - curated';
[~,strains,~] = xlsread(filename,'Database','D:D');
strains = lower(strains(2:end));
strains_unique = unique(strains,'stable');
strains_number = num2cell(linspace(1,length(strains_unique),length(strains_unique))');
strains_dict = [strains_unique,strains_number];
number = cell(length(strains),1);
for i = 1:length(strains)
    for j = 1:length(strains_dict)
        if strcmp(strains{i},strains_dict{j,1})
            number{i} = strains_dict{j,2};
        end
    end
end
strainnumbering = [number,strains];

%% Finding number of products per strain

m = 1;
n = 1;
numprodperstrain = cell(length(strains_unique),1);
for i = 1:length(strains)-1
    if strainnumbering{i+1,1} == strainnumbering{i,1}
        m = m+1;
    else
        numprodperstrain{n} = m;
        m = 1;
        n = n+1;
    end
    if i == length(strains)-1
        numprodperstrain{n} = m;
    end
end
strains_dict = [strains_dict,numprodperstrain];

%% Consolidating strains

cutoff = 5; %number of products of a strain strictly smaller than cutoff will be consolidated into its genus

strains_unique_cons = strains_dict(:,1);
strains_cons = cell(length(strains),1);

for i = 1:length(strains_unique)
    if strains_dict{i,3} < cutoff
        entry = strains_dict{i,1};
        genus = [entry(1:find(entry == ' ')),'sp'];
        strains_unique_cons{i,1} = genus;
    end
end
strains_dict = [strains_dict,strains_unique_cons];

for i = 1:length(strains)
    for j = 1:length(strains_dict)
        if strcmp(strains{i},strains_dict{j,1})
            strains_cons{i} = strains_dict{j,4};
        end
    end
end
