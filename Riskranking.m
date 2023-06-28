%% Risk ranking plots

%% Plot probabilities of exceedence vs most important parameter per ML method
load Mltestinput
S=readtable('50.2 CRF_Period 50.xlsx');
t=find(S.PredictedClass==1); t1=find(S.PredictedClass==0);
PIE=Predict_input(t,:);PIN=Predict_input(t1,:);
SN=S(S.PredictedClass==0,:);
SP=S(S.PredictedClass==1,:);
IP=10; %set the most important parameter
figure (1)
plot(PIN.(IP),SN.(5),'*b',PIE.(IP),SP.(5),'*r','MarkerSize',8)
ylabel('Propability');
xlabel('WOA 6month Mn raw water');
legend ('Non Exceedance WOAs','Exceedance WOAs');

%% Plot probabilities of exceedence vs WOA
figure (2)
S = sortrows(S,'EProbability','ascend');
% S.(3)=str2double(S.(3));
S1=S(S.(3)==1,:);
WOA=1:length(S1.(3));WOA=WOA';
plot(WOA,S1.(5),'b','MarkerSize',8,'LineWidth',5)
title('MM 50.2 prediction 2021');
ylabel('Propability');
xlabel('WOA');

