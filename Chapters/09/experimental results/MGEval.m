function y = MGEval(y0, numIterations)
    [lag,~] = size(y0);
    y = zeros(numIterations-lag,1);
    y = vertcat(y0,y);

    for k = lag+1:numIterations
        y(k)= 5.3569*y(k-1)- 14.0952*y(k-2)+ 24.3744*y(k-3)- 31.1053*y(k-4)+ 30.9521*y(k-5)-24.4804*y(k-6)+ 15.1982*y(k-7)- 7.0278*y(k-8)+ 2.1031*y(k-9)+ 0.013883 + 0.066535*y(k-9)*y(k-10)- 0.35279*y(k-10)+ 0.095508*y(k-10)^2- 0.14165*y(k-10)^3- 0.0083594*y(k-8)*y(k-10)^3+ 0.050857*y(k-10)^4;
    end

end