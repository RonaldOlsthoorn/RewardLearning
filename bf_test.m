close all; clear; clc;

t=0:0.01:10;
alpha_s = 0.5;
s = exp(-alpha_s*t);

c_t = 1:9;
c_s = exp(-alpha_s*c_t);

D     = (diff(c_s)).^2;
D     = 1./[D D(end)];

psi_t = zeros(length(t), length(c_t));
psi_s = zeros(length(t), length(c_t));

phi_t = zeros(length(t), length(c_t));
phi_s = zeros(length(t), length(c_t));


for j = 1:length(c_t)
    
    psi_t(:,j) = exp(-(c_t(j)*ones(1,length(t))-t).^2)';
    psi_s(:,j) = exp(-D(j)*(c_s(j)*ones(1,length(t))-s).^2)';
    
end


for j = 1:length(c_t)
    
    phi_t(:,j) = psi_t(:,j)./(sum(psi_t,2));
    phi_s(:,j) = psi_s(:,j)./(sum(psi_s,2));
    
end


figure;
subplot(2,2,1);
plot(t, psi_t);
xlabel('t');
ylabel('psi_t');

subplot(2,2,2);
plot(t, psi_s);
xlabel('t');
ylabel('psi_s');

subplot(2,2,3);
plot(t, phi_t);
xlabel('t');
ylabel('phi_t');

subplot(2,2,4);
plot(t, phi_s);
xlabel('t');
ylabel('phi_s');