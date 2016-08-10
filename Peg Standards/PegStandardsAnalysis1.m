%% One Source Along A Line
clear all; close all;
load('2394712_1.2.826.0.1.3680043.8.498.522279114561181547330639_filtered.mat');
[beta res]=est_field(time,signal,BG_Series);
%% Series 2: Source at -4
    m = [];
    s = [];
for ii = 13:17
    ser = ii;
    % initialFields = beta{ii}(1:25,:);
    % figure;
    % subplot(1,2,1);
    % plot(initialFields);
    % subplot(1,2,2);
    j = 1;
    for i=1:25:125
        m(j,:,ii-12) = mean(beta{ser}(i:24+i,:),1);
        s(j,:,ii-12) = std(beta{ser}(i:24+i,:),[],1);
        j = j + 1;
        % errorbar(1:7,m,s)
        % xlabel('Sensor')
        % ylabel('relative field strength');
    end
end
% 
% %
% msaData = xlsread('Line Source Data');
% msaData_=msaData(~isnan(msaData(:,1)),:);