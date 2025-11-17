% Secretary Bird Optimization Algorithm(SBOA)

clc;clear;close all;

func_num=1; % Functions 1 to 30 (fonksiyonlar 1'den 30'a kadar)
D=30; % Functional dimension  2/1030/50/100 (İşlevsel boyut)
Xmin=-100;
Xmax=100;
pop_size=30; % population quantity (nufüs mikatarı)
iter_max=500; % maximum iterations (maksimum yinelemeler)
fhd=str2func('cec17_func');

disp(['Function: F',num2str(func_num),' dimension: ',num2str(D),  ' maximum iterations: ', num2str(iter_max), ' population quantity: ', num2str(pop_size)]);
[BEF_SBOA,BEP_SBOA,BestCost_SBOA]=SBOA(pop_size,iter_max,Xmin,Xmax,D,fhd,func_num);

% Plot convergence curve
semilogy(BestCost_SBOA,'-b','LineWidth',2)

CurveTitle=['F',num2str(func_num)];
title(CurveTitle)
xlabel('Iteration#');
ylabel('Best Fitness Value');
legend('SBOA')
axis tight
grid on
box on

display(['The best optimal values of the objective funciton found by SBOA is : ', num2str(BEF_SBOA)]);


