%% One Source Along A Line
clear all; close all;
%load('1.2.826.0.1.3680043.8.498.52227911456195992948037_filtered.mat');
%[beta res]=est_field(time,signal,BG_Series);
load('Line Source Data CSV.csv');
% Series 2: Source at -4
%for ii = 20
    %ser = ii;
    %initialFields = beta{ii}(1:25,:);
    % figure;
    % subplot(1,2,1);
    % plot(initialFields);
    % subplot(1,2,2);
    j = 1;
    m1 = [];
    s1 = [];
    for i=1:5:540
        m1(j,:) = mean(Line_Source_Data_CSV(i:4+i,:),1);
        s1(j,:) = std(Line_Source_Data_CSV(i:4+i,:),[],1);
        j = j + 1;
        % errorbar(1:7,m,s)
        % xlabel('Sensor')
        % ylabel('relative field strength');
    end
%end
% 
% %
% msaData = xlsread('Line Source Data');
% msaData_=msaData(~isnan(msaData(:,1)),:);