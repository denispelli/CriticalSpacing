err=0:0.1:.7;
e=2.718;
pPrime=(-log(1-(1-1/e-.5*err)./(1-err))).^(1/2);
plot(err,pPrime)
xlabel('Probability of fixation error');
ylabel('Measured re true threshold spacing');