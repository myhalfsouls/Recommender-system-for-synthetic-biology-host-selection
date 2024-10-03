clear
clc

filename = 'C:\Dropbox (MIT)\MIT\Strain-product collaborative filtering\20190814 Strain-product web crawling results - curated + sorted';

strains = xlsread(filename,'A:A');
products = xlsread(filename,'E:E');
titer = xlsread(filename,'D:D');

data = [strains, products, titer];