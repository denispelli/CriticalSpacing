clear all
% Gonzalez et al. (2012) assume a bivariate normal distribution and
% compute the elliptical area that contained 0.682 of the probability (+/- 1 sd).
% BCEA = pi*2.291*sigmaX*sigmaY*sqrt(1-rho^2)
% We cannot recover the ellipse from BCEA, and I didn't check their paper
% for the value of rho, so i assume rho=0 and sigma=sigmaX=sigmaY. Then
% BCEA = pi*2.291*sigma^2;
% sigma=(BCEA/(pi*2.291))^0.5;
% pdf=exp(-(x.^2+y.^2)/(2*sigma^2))/(sigma^2*2*pi);
%
% For the control observers, viewing binocularly, log10(BCEA)=-0.88, so
% BCEA=10^-0.88=0.13 deg^2. Assuming the ellipse is circular, then sigma =
% 0.13.
%
% For viewing through an amblyopic eye, log10(BCEA)=-0.20, so BCEA=0.63
% deg^2, and we estimate sigma=0.30.
%
% Assuming a critical spacing of 0.05 at zero ecc and slope 0.3 then
% a sigma of 0.13 predicts a critical spacing of about 0.09 deg, more than
% we found. To bring the model's prediction down to 0.05 deg, we must
% assume a critical spacing of 0 deg at 0 eccentricity. This suggests that
% our foveal measure of crowding is proportional to sigma of fixation. In
% that case the repeated measure might be smaller and allow us to estimate
% the fixational stability.


R=0.3;
[x,y]=meshgrid(-4*R:0.01:4*R,-4*R:0.01:4*R);
eccentricity=sqrt(x.^2+y.^2);
spacing=0.3*(eccentricity+0.0);
sigma=1e-6:R/1000:R;
for i=1:length(sigma)
   pdf=exp(-(x.^2+y.^2)/(2*sigma(i)^2))/(sigma(i)^2*2*pi);
   meanSpacing(i)=sum(sum(spacing.*pdf))/sum(sum(pdf));
end
figure(1);
plot(sigma,meanSpacing);
xlabel('Sd of fixation (deg)');
ylabel('Average critical spacing (deg)');
% figure(2);
% BCEA = pi*2.291*sigma.^2;
% plot(BCEA,meanSpacing);
% xlabel('BCEA fixational area (deg^2)');
% ylabel('Average critical spacing (deg)');
