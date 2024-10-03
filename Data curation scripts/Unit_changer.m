clear
clc

filename = 'C:\Dropbox (MIT)\MIT\Strain-product collaborative filtering\20200410 Strain-product web crawling results combined - curated';
[~,units,~] = xlsread(filename,'E:E');
units = units(2:end);
num_results = zeros(length(units),1);
unit_results = cell(length(units),1);

for i = 1:length(units)
    a = units{i};
    if sum(a == ',') ~= 0
        comma = a==',';
        a = a(~comma);
    end
    b = zeros(1,length(a)-2);
    for j = 1:length(a)-2
        b(j) = str2double(a(j));
    end
    c = ~isnan(b);
    d = find(c,1,'last');
    if isempty(str2num(a(1:d)))
        num_results(i) = NaN;
    else
        num_results(i) = str2num(a(1:d));
        unit_results{i} = a(d+1:end);
    end
end

multiplier = zeros(length(units),1);
for i = 1:length(multiplier)
    if ischar(unit_results{i})
        if strfind(unit_results{i},'mu') ~= 0
            multiplier(i) = 10^-6;
        elseif strfind(unit_results{i},'mg') ~= 0
            multiplier(i) = 10^-3;
        elseif strfind(unit_results{i},'g') ~= 0
            multiplier(i) = 1;
        end
    end
end

normalized = num_results .* multiplier;

