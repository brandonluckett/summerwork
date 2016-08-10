% Calculate mean of each series
clear all;
close all;
filename = 'X-Y-Z-M.csv';
num=csvread(filename);
m=[];
s=[];
    j=1;
    for i=6:5:45
        m(j,:) = mean(num(i:4+i,:));
        s(j,:) = std(num(i:4+i,:));
        j = j + 1;
    end
    