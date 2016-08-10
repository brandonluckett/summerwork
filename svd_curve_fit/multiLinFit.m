function [alpha,beta,rxy] = multiLinFit(X,Y)
%% Lin. fit every row of the matrixes X and Y

    mx = mean(X,1);
    my = mean(Y,1);
    mxy = mean(X.*Y,1);
    mxx = mean(X.*X,1);
    myy = mean(Y.*Y,1);
    rxy = (mxy - mx.*my) ./ sqrt((mxx - mx.*mx).*(myy - my.*my));
    beta = (mxy - mx.*my) ./ (mxx - mx.*mx );
    alpha = my - beta .* mx;
end
