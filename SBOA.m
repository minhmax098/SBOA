% Secretary Bird Optimization Algorithm(SBOA)                                                                      

% You can simply define your cost function in a seperate file and load its handle to fobj 
% The initial parameters that you need are:
%__________________________________________
% fobj = @YourCostFunction
% dim = number of your variables
% T = maximum number of iterations
% N = number of search agents
% lb=[lb1,lb2,...,lbn] where lbn is the lower bound of variable n
% ub=[ub1,ub2,...,ubn] where ubn is the upper bound of variable n
% If all the variables have equal lower bound you can just
% define lb and ub as two single numbers

function[Best_score,Best_pos,SBOA_curve]=SBOA(N,T,lb,ub,dim,fitness,func_num)

lb=ones(1,dim).*(lb);                              
ub=ones(1,dim).*(ub);                             

%% INITIALIZATION
for i=1:dim
    X(:,i) = lb(i)+rand(N,1).*(ub(i) - lb(i));                          
end

for i =1:N
    M=X(i,:);
    fit(i)=fitness(M',func_num);
end
%% main loop
for t=1:T
    CF=(1-t/T)^(2*t/T);
    %% update the global best (fbest)
    [best , location]=min(fit);
    if t==1
        Bast_P=X(location,:);                                           % Optimal location
        fbest=best;                                           % The optimization objective function
    elseif best<fbest
        fbest=best;
        Bast_P=X(location,:);
    end
    
    %% The secretary bird's predation strategy
    for i=1:N
        if t<T/3  % Secretary bird search prey stage
           Rn=size(X,1);
           X_random_1=randi([1,Rn]);
           X_random_2=randi([1,Rn]);
           R1=rand(1,dim);
           X1=X(i,:)+(X(X_random_1,:)-X(X_random_2,:)).*R1; 
           X1= max(X1,lb);
           X1 = min(X1,ub);
        elseif t>T/3 && t<2*T/3  % Secretary bird approaching prey stage
               RB=randn(1,dim);
               X1=Bast_P+exp((t/T)^4)*(RB-0.5).*(Bast_P-X(i,:));
               X1= max(X1,lb);
               X1 = min(X1,ub);
        else       % Secretary bird attacks prey stage
            RL=0.5*Levy(dim);
            X1=Bast_P+CF*X(i,:).*RL;
            X1= max(X1,lb);
            X1 = min(X1,ub);
        end

        f_newP1 = fitness(X1',func_num);
        if f_newP1 <= fit (i)
            X(i,:) = X1;
            fit (i)=f_newP1;
        end
    end
     
%% Secretary Bird's escape strategy
    r=rand;
    k=randperm(N,1);
    Xrandom=X(k,:);
    for i=1:N
        if r<0.5
            %% C1: Secretary birds use their environment to hide from predators
            RB=rand(1,dim);
            X2= Bast_P+(1-t/T)*(1-t/T)*(2*RB-1).*X(i,:);% Eq.(5) S1
            X2= max(X2,lb);X2 = min(X2,ub);
      
        else
            %% C2:  Secretary birds fly or run away from the predator
            K=round(1+rand(1,1));
            R2=rand(1,dim);
            X2=X(i,:)+ R2.*(Xrandom-K.* X(i,:)); %  Eq(5) S2
            X2= max(X2,lb);X2 = min(X2,ub);
             
        end
        
        f_newP2 = fitness(X2',func_num); %Eq (6)
        if f_newP2 <= fit (i)
            X(i,:) = X2;
            fit (i)=f_newP2;
        end

    end %

    best_so_far(t)=fbest;
    average(t) = mean (fit);
    
end 
Best_score=fbest;
Best_pos=Bast_P;
SBOA_curve=best_so_far;
end

%% Levy flight function
function o=Levy(d)
beta=1.5;
sigma=(gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
u=randn(1,d)*sigma;v=randn(1,d);step=u./abs(v).^(1/beta);
o=step;
end

