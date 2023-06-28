%% Main predictive model
tic;
clc;
clear all;
load SW;
load WTW;
load Raw;
%% Select parameters (type of model,ML algorithm,type of prediction (coliforms or chlorine),...
%% ... use of balancing methods (yes /no)
Temp_scale='Period'; %% 'Season' / 'Year' / 'Period'
Thresh=4;       %% select threshold (0=All /1=20/ 2=30/ 3=40/ 4=50)
test_year=2021;    %% testing year
test_period=0;    %% (0 = test all year 1= W SP / 2=SMA) 
Step=1;          %% No of timestep difference between input and output 
colno_attr = [29 32 35 45 47 51 52 54];   %select parameters for the procedure
multistep=1; %% 0= one step input data used / 1= 2 step input data (WTW and RAW input 2 steps before output)
colno_step = [35 54]; %%select parameters
Scolno=length(colno_attr); %number of parameters
Scolno_step=length(colno_step); %number of previous steps parameters
ml_ens_dec_tree='RF'; % Select ML Ensemble Decision tree....
%... ('All' for all ML/ 'RF' for Random Forest / 'Boost' for boosting/'SVM' for SVM) 
Boost_Method='AdaBoostM1'; % if ml tree='Boost' select boost method here...
%....( AdaBoostM1 / RusBoost/LogitBoost/GentleBoost)
balancing = 'Y'; %('Y' for balacning / 'N' for no balancing)
bl_method ='UNDER'; % ('SMOTE' for SMOTE / 'ADASYN' for ADASYN / 'UNDER' for undersampling)     
%% Feature parameters' selection
% 7= {'Alkalinity'},8={'Aluminium'},9={'Calcium'},11={'ColBacteria'},12={'E_Coli'},13={'HPC_22C'},14={'HPC_37C'},
% 15={'Enterococci'} 16={'THM_Total'} 29= {'FreeCl'},30=  {'pH'}, 31= {'Fe'}, 32={'Lead'},33= {'FC_ICCs'},34= {'FC_TCCs'}, 
% 35={'Mn'}, 41={'Temperature'},42={'TotCl'},45={'TOC'},47={'Turb'},49={'Fe_WTW'},50={'Mn_WTW'},
% 51={'Temperature_WTW'}, 52={'TotCl_WTW'},54={'Mn_Raw'}, 55={'index'}];
%% Balancing parameters to check
Mn=1; %% et parameter
%% Data preparation
[Input, Output, Fails,Ratio,Pr_input]=Data_preparation(SW,WTW,Raw,Temp_scale,colno_attr,multistep,colno_step);
clear WTW Raw SW colno_attr colno_step 
%% Creating Input - Output file (check parameters inside)
[MLinout,MLtrain,MLtest]=mlinput(Input,Output,Pr_input,Thresh,Step,Temp_scale,test_year,test_period,multistep,Scolno_step);
clear Input Output Pr_input Step test_year test_period multistep
switch balancing
    case 'Y'
[Training_input,Training_output,Predict_input,Testing_output]=bal_methods(MLtrain,...
          MLtest,Scolno,bl_method,Mn,Scolno_step);
       case 'N'
       Training_input=MLtrain(:,6:(6+Scolno+Scolno_step-1));
       Training_output=MLtrain(:,(6+Scolno+Scolno_step+2):end);
       Predict_input=MLtest(:,6:(6+Scolno+Scolno_step-1));
       Testing_output=MLtest(:,(6+Scolno+Scolno_step+2):end);
end
clear balancing bl_method Mn Scolno Scolno_step
%% Training ML method
[Val_output,Val_scores,Predict_output,P_scores]=Mlmethod(ml_ens_dec_tree,Boost_Method,Training_input,Training_output,Predict_input);
if height(Val_scores)==height(MLtrain)
Val_scores=addvars(Val_scores,MLtrain.WOAName,MLtrain.WTW,'before','Var1');
end
P_scores=addvars(P_scores,MLtest.WOAName,MLtest.WTW,MLtest.Temp_scale,'before','Var1');
P_scores=addvars(P_scores,Testing_output.Label,Predict_output.Var1);
filename=[Boost_Method '_' Temp_scale '.xlsx'];
writetable(P_scores,filename);
%% Metrics
[P_TPR,P_TNR,P_MCC,P_Prec,P_F1score,V_TPR,V_TNR,V_MCC,V_Prec,V_F1score]=Metrics(Predict_output,Testing_output,...
          Val_output,Training_output);
% fprintf('Prediction True Positive Rate = %g\n\n',P_TPR)
% fprintf('Prediction True Negative Rate = %g\n\n',P_TNR)
% fprintf('Prediction Mattews correlation coefficient = %g\n\n',P_MCC) 
% fprintf('Prediction Precision = %g\n\n',P_Prec)
% fprintf('Prediction F1 Score = %g\n\n',P_F1score)
%   
% 
% fprintf('Validation True Positive Rate = %g\n\n',V_TPR)
% fprintf('Validation True Negative Rate = %g\n\n',V_TNR)
% fprintf('Validation Mattews correlation coefficient = %g\n\n',V_MCC)
% fprintf('Validation Precision = %g\n\n',V_Prec)
% fprintf('Validation F1 Score = %g\n\n',V_F1score)

if Thresh==0
    Metric_prall20=[P_TPR(1) P_TNR(1) P_MCC(1) P_Prec(1) P_F1score(1)]
    Metric_prall30=[P_TPR(2) P_TNR(2) P_MCC(2) P_Prec(2) P_F1score(2)];
    Metric_prall40=[P_TPR(3) P_TNR(3) P_MCC(3) P_Prec(3) P_F1score(3)];
    Metric_prall50=[P_TPR(4) P_TNR(4) P_MCC(4) P_Prec(4) P_F1score(4)]
    
    Metric_valall20=[V_TPR(1) V_TNR(1) V_MCC(1) V_Prec(1) V_F1score(1)]
    Metric_valall30=[V_TPR(2) V_TNR(2) V_MCC(2) V_Prec(2) V_F1score(2)];
    Metric_valall40=[V_TPR(3) V_TNR(3) V_MCC(3) V_Prec(3) V_F1score(3)];
    Metric_valall50=[V_TPR(4) V_TNR(4) V_MCC(4) V_Prec(4) V_F1score(4)]

% fprintf('Prediction Metrics for 20 threshold = %g\n\n',Metric_prall20)
% fprintf('Prediction Metrics for 30 threshold = %g\n\n',Metric_prall30)
% fprintf('Prediction Metrics for 40 threshold = %g\n\n',Metric_prall40) 
% fprintf('Prediction Metrics for 50 threshold = %g\n\n',Metric_prall50)

% fprintf('Validation Metrics for 20 threshold =  %g\n\n',Metric_valall20)
% fprintf('Validation Metrics for 30 threshold =  %g\n\n',Metric_valall30)
% fprintf('Validation Metrics for 40 threshold =  %g\n\n',Metric_valall40) 
% fprintf('Validation Metrics for 50 threshold =  %g\n\n',Metric_valall50)
else
        Metric_prall=[P_TPR P_TNR P_MCC P_Prec P_F1score]
end    
toc;