k=1;
for n=1:100
  n;
tic
for k=1:1e8
    k=3*6;
end
m(n)=toc;
end
med=mean(m);
mult=64^1.585;
co2= 5.87; % divide per 60
bco2=co2*med/mult %(gCO2e) % mgram CO2emission per  bit