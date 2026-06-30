function result = MGHornerEval(y0, numIterations)
    [lag,~] = size(y0);
    result = zeros(numIterations-lag,1);
    result = vertcat(y0,result);

    for k = lag+1:numIterations
        result(k) = 5.3569 * result(k-1) - 14.0952 * result(k-2) + 24.3744 * result(k-3) - 31.1053 * result(k-4) + 30.9521 * result(k-5)...
            - 24.4804 * result(k-6) + 15.1982 * result(k-7) - 7.0278 * result(k-8) + 2.1031 * result(k-9) + 0.013883...
            + result(k-10) * (0.066535 * result(k-9) - 0.35279 + result(k-10) * (0.095508 + result(k-10) * (-0.14165 - 0.0083594*result(k-8) + result(k-10) * 0.050857)));
    end

end
