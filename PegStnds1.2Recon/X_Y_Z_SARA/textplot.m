close all;
hold on;
    for ii=1:9
        x(ii,1)=num(ii,1);
        y(ii,1)=num(ii,2);
        z(ii,1)=num(ii,3);
        s1(ii,1)=num(ii,4)./1000;    
        scatter3(x(ii,1)-.75,y(ii,1)+.25,z(ii,1),s1(ii,1));
    end
    xlim([-2,2]);
    ylim([-2,2]);
    zlim([-3.6,-2]);
    legend('Peg 2.1','Peg 2.2','Peg 2.3','Peg 2.4', 'Peg 2.5', 'Peg 2.6', 'Peg 2.7','Peg 2.8','Peg 2.9');
%text1='\leftarrow 2.1';
%text2='\leftarrow 2.2';
%text3='\leftarrow 2.3';
%text4='\leftarrow 2.4';
%text5='\leftarrow 2.5';
%text6='\leftarrow 2.6';
%text7='\leftarrow 2.7';
%text8='\leftarrow 2.8';
%text9='\leftarrow 2.9';
    %text(x(1,1),y(1,1),z(1,1),text1)
    %text(x(2,1),y(2,1),z(2,1),text2)
    %text(x(3,1),y(3,1),z(3,1),text3)
    %text(x(4,1),y(4,1),z(4,1),text4)
    %text(x(5,1),y(5,1),z(5,1),text5)
    %text(x(6,1),y(6,1),z(6,1),text6)
    %text(x(7,1),y(7,1),z(7,1),text7)
    %text(x(8,1),y(8,1),z(8,1),text8)
    %text(x(9,1),y(9,1),z(9,1),text9)
    