A=zeros(1,length(SW.(1)))';
S=SW.(8);
for ii=1:length(SW.(1))
if S(ii)<=3
A(ii)=1;
elseif S(ii)>=10
A(ii)=4;
elseif S(ii)>3 && S(ii)<7
    A(ii)=2;
else
    A(ii)=3;
end
end
SW=addvars(SW,A);

% SW.(243)=zeros(1,length(SW.(8)))';
% B=Raw.(5);
% for i=1:length(Raw.(5))
%     if isequal(Raw.(5){i}, 'W')
%         B(i)={1};
%     elseif isequal(Raw.(5){i}, 'SP')
%         B(i)={2};
%     elseif isequal(Raw.(5){i}, 'SM')
%         B(i)={3};
%     else 
%         B(i)={4};
%     end
% end
% B=cell2mat(B); 
% Raw=addvars(Raw,B);

A=SW(:,[39 7 243]); 
% % SRs=table (RAW_MN_WTW.(1),RAW_MN_WTW.(2),RAW_MN_WTW.(3));
SR_Cell = table2cell(A);% convert table to strings;
SR_strings=cellfun(@num2str,SR_Cell,'un',0); % convert any numbers to strings;
SR_Rows=mat2cell(SR_strings,ones(size(SR_strings,1),1),size(SR_strings,2)); % make cells for each row;
A=cellfun(@strjoin,SR_Rows,'uni',0);% merge the columns;
SW=addvars(SW,A);
SW=movevars(SW,'A','before','All_season');

