%% Prepare dataset for predictive models
function [Input, Output, Fails,Ratio,Pr_input]=Data_preparation(SW,WTW,Raw,Temp_scale,colno_attr,multistep,colno_step) 
Mg20=SW.(80)>20;
Mg30=SW.(80)>30;
Mg40=SW.(80)>40;
Mg50=SW.(80)>50;
SW=addvars(SW,Mg20,Mg30,Mg40,Mg50); U=unique(SW.(24));
%% find events per season, 6month and year
SWseason=SW(:,[240 39 24 7 237 243 244 245 246]); 
SWseason_sum=varfun(@sum,SWseason,'GroupingVariables',{'All_season','WTW','WOAName','Year','Season'});
% SWseason_sum.(9)=SWseason_sum.(5)>=1; SWseason_sum.(10)=SWseason_sum.(6)>=1;
% SWseason_sum.(11)=SWseason_sum.(7)>=1; SWseason_sum.(12)=SWseason_sum.(8)>=1;
% for iii=
SWyear=SW(:,[241 39 24 7 243 244 245 246]);
SWyear_sum=varfun(@sum,SWyear,'GroupingVariables',{'All_year','WTW','WOAName','Year'});
% SWyear_sum.(8)=SWyear_sum.(4)>=1; SWyear_sum.(9)=SWyear_sum.(5)>=1;
% SWyear_sum.(10)=SWyear_sum.(6)>=1; SWyear_sum.(11)=SWyear_sum.(7)>=1;
SWsemester=SW(:,[242 39 24 7 10 243 244 245 246]); 
SWsemester_sum=varfun(@sum,SWsemester,'GroupingVariables',{'All_period','WTW','WOAName','Year','Period'});
% SWsemester_sum.(9)=SWsemester_sum.(5)>=1; SWsemester_sum.(10)=SWsemester_sum.(6)>=1;
% SWsemester_sum.(11)=SWsemester_sum.(7)>=1; SWsemester_sum.(12)=SWsemester_sum.(8)>=1;
for iii=11:14
    SWseason_sum.(iii)=SWseason_sum.(iii-4)>=1;
    sumseason(iii-10)=sum(SWseason_sum.(iii));
    ratioseason(iii-10)=sumseason(iii-10)/length(SWseason_sum.(1));
    
    SWsemester_sum.(iii)=SWsemester_sum.(iii-4)>=1;
    sumsemester(iii-10)=sum(SWsemester_sum.(iii));
    ratiosemester(iii-10)=sumsemester(iii-10)/length(SWsemester_sum.(1));
    
    SWyear_sum.(iii-1)=SWyear_sum.(iii-5)>=1;
    sumyear(iii-10)=sum(SWyear_sum.(iii-1));
    ratioyear(iii-10)=sumyear(iii-10)/length(SWyear_sum.(1));
end
[~,~,Xs]=unique (SWseason_sum(:,3)); [~,~,Xp]=unique (SWsemester_sum(:,3)); [~,~,Xy]=unique (SWyear_sum(:,3));
Outs=accumarray(Xs,1:size(SWseason_sum,1),[],@(r){SWseason_sum(r,:)});
Outp=accumarray(Xp,1:size(SWsemester_sum,1),[],@(r){SWsemester_sum(r,:)});
Outy=accumarray(Xy,1:size(SWyear_sum,1),[],@(r){SWyear_sum(r,:)});
% clear T Mg20 Mg30 Mg40 Mg50 Xs Xp Xy SWseason SWsemester Swyear

%% Prepare the input AVE datasets
%% Tap parameters
SWparseason=SW(:,[240 39 24 7 237 52:92]); SWparyear=SW(:,[241 39 24 7 52:92]);
SWparsemester=SW(:,[242 39 24 7 10 52:92]);
SWparseason_AVE=varfun(@nanmean,SWparseason,'GroupingVariables',{'All_season','WTW','WOAName','Year','Season'});
SWparyear_AVE=varfun(@nanmean,SWparyear,'GroupingVariables',{'All_year','WTW','WOAName','Year'});
SWparsemester_AVE=varfun(@nanmean,SWparsemester,'GroupingVariables',{'All_period','WTW','WOAName','Year','Period'});
%% WTW parameters
WTWseason=WTW(:,[35 22 24 27 29]); WTWyear=WTW(:,[36 22 24 27 29]);
WTWsemester=WTW(:,[37 22 24 27 29]);
WTWseason_AVE=varfun(@nanmean,WTWseason,'GroupingVariables',{'All_season'});
WTWyear_AVE=varfun(@nanmean,WTWyear,'GroupingVariables',{'All_year'});
WTWsemester_AVE=varfun(@nanmean,WTWsemester,'GroupingVariables',{'All_period'});
%% Raw Water parameters
Rawseason=Raw(:,[656 365]); Rawyear=Raw(:,[657 365]);
Rawsemester=Raw(:,[658 365]);
Rawseason_AVE=varfun(@nanmean,Rawseason,'GroupingVariables',{'All_season'});
Rawyear_AVE=varfun(@nanmean,Rawyear,'GroupingVariables',{'All_year'});
Rawsemester_AVE=varfun(@nanmean,Rawsemester,'GroupingVariables',{'All_period'});
%%  join inputs 
%% Season
Inputseason=outerjoin(SWparseason_AVE,WTWseason_AVE, 'LeftKeys', 'All_season', 'RightKeys', 'All_season', 'MergeKeys', true);
Inputseason=outerjoin(Inputseason,Rawseason_AVE, 'LeftKeys', 'All_season', 'RightKeys', 'All_season', 'MergeKeys', true);
ss=~isnan(Inputseason.(4)); Inputseason=Inputseason(ss,:);
[~,~,Xs]=unique (Inputseason(:,3));
Ins=accumarray(Xs,1:size(Inputseason,1),[],@(r){Inputseason(r,:)});
%% Year
Inputyear=outerjoin(SWparyear_AVE,WTWyear_AVE, 'LeftKeys', 'All_year', 'RightKeys', 'All_year', 'MergeKeys', true);
Inputyear=outerjoin(Inputyear,Rawyear_AVE, 'LeftKeys', 'All_year', 'RightKeys', 'All_year', 'MergeKeys', true);
ss=~isnan(Inputyear.(4)); Inputyear=Inputyear(ss,:);
[~,~,Xy]=unique (Inputyear(:,3));
Iny=accumarray(Xy,1:size(Inputyear,1),[],@(r){Inputyear(r,:)});
%% Period
Inputperiod=outerjoin(SWparsemester_AVE,WTWsemester_AVE, 'LeftKeys', 'All_period', 'RightKeys', 'All_period', 'MergeKeys', true);
Inputperiod=outerjoin(Inputperiod,Rawsemester_AVE, 'LeftKeys', 'All_period', 'RightKeys', 'All_period', 'MergeKeys', true);
ss=~isnan(Inputperiod.(4)); Inputperiod=Inputperiod(ss,:);
[~,~,Xp]=unique (Inputperiod(:,3));
Inp=accumarray(Xp,1:size(Inputperiod,1),[],@(r){Inputperiod(r,:)});
% clear iii Rawseason Rawseason_AVE Rawsemester Rawsemester_AVE Rawyear Rawyear_AVE
% clear ss SWparseason SWparseason_AVE SWparsemester SWparsemester_AVE SWparyear SWparyear_AVE
% clear WTWseason WTWseason_AVE WTWsemester WTWsemester_AVE WTWyear_AVE WTWyear SW Raw WTW Xp Xs Xy

%% Creating inputs outputs sets
for i=1:size(U,1)
    Ins{i,1}=sortrows(Ins{i,1},'All_season','ascend'); Ins{i,1}.index=(1:height(Ins{i,1})).';
    Outs{i,1}=sortrows(Outs{i,1},'All_season','ascend'); Outs{i,1}.index=(1:height(Outs{i,1})).';
    Inp{i,1}=sortrows(Inp{i,1},'All_period','ascend'); Inp{i,1}.index=(1:height(Inp{i,1})).';
    Outp{i,1}=sortrows(Outp{i,1},'All_period','ascend'); Outp{i,1}.index=(1:height(Outp{i,1})).';
    Iny{i,1}=sortrows(Iny{i,1},'All_year','ascend'); Iny{i,1}.index=(1:height(Iny{i,1})).';
    Outy{i,1}=sortrows(Outy{i,1},'All_year','ascend'); Outy{i,1}.index=(1:height(Outy{i,1})).';
end

switch Temp_scale
    case 'Season'
        Input_a = Ins;
        Output = Outs;
        Fails=sumseason;
        Ratio=ratioseason;
    case 'Period'
        Input_a = Inp;
        Output = Outp;
        Fails=sumsemester;
        Ratio=ratiosemester;
    case 'Year'
        Input_a = Iny;
        Output = Outy;
        Fails=sumyear;
        Ratio=ratioyear;
        for v=1:size(Output,1)
        Input_a{v,1}.time=(1:height(Input_a{v,1})).';
        Input_a{v,1}= movevars(Input_a{v,1},'time','after','Year');
        Output{v,1}.time=(1:height(Output{v,1})).';
        Output{v,1}= movevars(Output{v,1},'time','after','Year');
        end
end
s=[{'All_one'}, {'WTW'}, {'WOAName'},{'Year'},{'Temp_scale'}, {'GroupCount_SWpar'}, {'Alkalinity'}, {'Aluminium'},...
    {'Calcium'}, {'Chloride'}, {'ColBacteria'}, {'E_Coli'}, {'HPC_22C'}, {'HPC_37C'},  {'Enterococci'},{'THM_Total'},...
    {'Cryptosporidium?'}, {'ClostridiumPerf?'}, {'Conductivity'}, {'Copper'},  {'DisAluminium'}, {'DisCopper'}, {'DisFe'},...
    {'DisLead'},  {'DisMngs'},  {'DisOrgCarbon'},  {'DisOxygen'}, {'DisZinc'}, {'FreeCl'},  {'pH'},  {'Fe'},  {'Lead'},...
    {'FC_ICCs'}, {'FC_TCCs'}, {'Mn'}, {'Nitrate'}, {'Nitrite'}, {'Phosphorus'}, {'Sulphate'},  {'Sulphide'}, {'Temperature'},...
    {'TotCl'}, {'TotDisSolids'}, {'TotHardness'}, {'TOC'}, {'TotOxidisedNitr?'}, {'Turb'}, {'GroupCount_WTWs?'}, {'Fe_WTW'},...
    {'Mn_WTW'}, {'Temperature_WTW'}, {'TotCl_WTW'}, {'GroupCount'},  {'Mn_Raw'}, {'index'}];
ss=s([1 2 3 4 5 colno_attr 55]);
tt=s([1 2 3 4 5 colno_step]);
for iv=1:size(Output,1)
    Input{iv,1}= Input_a{iv,1}(:,[1:5 colno_attr 55]);
    Input{iv,1}.Properties.VariableNames = ss;
    if multistep==1
    Pr_input{iv,1}=Input_a{iv,1}(:,[1:5 colno_step]);
    Pr_input{iv,1}.Properties.VariableNames = tt;
    else
        Pr_input=0;
    end
end

end