% Calculate mean of each series
clear all;
close all;
filename = 'Peg Standards Fig 1.csv';
num=csvread(filename);
m=[];
s=[];
    j=1;
    for i=1:5:175
        m(j,:) = mean(num(i:4+i,:));
        s(j,:) = std(num(i:4+i,:));
        j = j + 1;
    end
    