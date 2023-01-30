% ------------------------------------------------------
% Title: Standard Incomplete-Market Model, Brute-Force Algorithm
% Subtitle: Value Function Iteration for a Two-Agent Setting
% Authors: Bruno Cavani and Guilherme Gallego
% Institution: Insper and Insper
% Emails: brunocavanimonteiro@gmail.com and guilhermegg1@al.insper.edu.br
% ------------------------------------------------------
% Note: This code solves by brute-force value function iteration
% a standard incomplete-market model in which two ex-post heterogeneous 
% agents smooth consumption through precautionary saving in a risk-free
% asset in the fashion of Huggett (1993). This is a preliminary
% routine where we focus on computing the policy functions for 2 agents.
% ------------------------------------------------------

% ------------------------------------------------------ 
% Part 1: Calibration
% ------------------------------------------------------ 

clear all
clc

beta  = 0.960;                    % discount factor
gamma = 2.00;                     % risk aversion

amin = 0;                         % lower-bound borrowing constraint
amax = 11;                        % upper-bound borrowing constraint
agrid = 1000;                     % number of gridpoints for assets
a = linspace(amin,amax,agrid);    % 1000-size grid for assets
e = [0.25 2];                     % 2-size grid for productivity
pi_e = [0.55 0.45; 0.15 0.85];    % 2x2 transition matrix for productivity

% ------------------------------------------------------ 
% Part 2: Guessing Initial Values
% ------------------------------------------------------ 

r = 0.010;                        % interest rate
w = 1.00;                         % wage rate

error_V = 100;                    % initial approximation error
iter_V = 0;                       % initial number of iterations
V(1:agrid,1:2) = 0;                 % guess for the value function
                                  % Obs.: col(V(.))=2, i.e. 2 agents

% ------------------------------------------------------ 
% Part 3: Brute-Force Algorithm
% ------------------------------------------------------ 

while (error_V>0.00001)		% general loop goes until error is low enough

iter_V = iter_V+1;		    % counting the number of iterations

for ia=1:agrid                  % loop in the current asset position (ia=1; first position of the assets' grid)
  for ie=1:2                    % loop in the current productivity position (ie=1; first position of productivity's grid)
    for ja=1:agrid              % next-period position of assets: given "e" and "a", we seek for "a'" that maximizes V(a,e), i.e. look within the grid points for the one that maximizes V

        c = (1+r)*a(ia) + w*e(ie) - a(ja);      % given {ia,ie,ja} fixed, compute consumption from the budget constraint

        if (c>0)                                % if consumption is positive, compute the utility level U[c(ie,ja),e(ie),a(ja)]

          util(ja) = (c^(1-gamma) )/(1-gamma) + beta*(pi_e(ie,1)*V(ja,1) + pi_e(ie,2)*V(ja,2));

        else									% if consumption is negative, attach a penalized utility level to guarantee a sub-optimal allocation

          util(ja) = -10000000;                                                

        end
    end                                         % when finished the loop for all ja, we have a vector of max-utilities for all ja-candidates and all states

    [Vmax ind]   = max(util);                   % store all the maximum utilities' values and its indexes in a matrix, [Vmax ind]
    ind_a(ia,ie) = ind;                         % save the position in the grid for assets in which the solution is attained, i.e. position of the optimal asset allocation
    Vnew(ia,ie)  = Vmax;                        % save the maximum utility for given state
    ga(ia,ie)    = a(ind);                      % policy function for asset, i.e. optimal asset allocation for given wealth-productivity pair of states
    gc(ia,ie)    = (1+r)*a(ia) + w*e(ie) - ga(ia,ie); 				% policy function for consumptiom, i.e. optimal consumption for given wealth-productivity pair of states

  end                                           % now changes ie and do all the same
end                                             % now changes ia and do all the same

% now we have best-responses for all possible states, and the respective maximum utility values

% Q: When do we finish the loop? A: When the distance against the previous utility level (the updated guess) is low enough, and then we converged!

error_V = max(max(abs(Vnew-V)));  				% update the distance of the value function from the previous guess; largest error/difference between Vnem and V
                                 				% Obs.: we use double max because we want the maximum error within all lines and columns

disp(['error_V' , num2str(error_V) , 'iter_V' , num2str(iter_V) ]) 		% display the error_V and iter_V

V = Vnew;                       				% update the guess for the value function

end                             				% re-do the loop until error is low enough

% ------------------------------------------------------ 
% Part 4: Plots of Policy Functions for each Level of Productivity
% ------------------------------------------------------ 

% 4.1. Policy Function for Consumption

ht = figure;
plot(a(1:agrid),gc(1:agrid,1), 'linestyle','-','color',[0,0,0]+0.1,'linewidth',6)
hold on
plot(a(1:agrid),gc(1:agrid,2), 'linestyle','-','color',[0,0,0]+0.7,'linewidth',6)
set (gca,'fontsize',12)
box off
title ('Policy Funtion for Consumption','fontsize',16)
xlabel('Assets','fontsize',16)
%ylabel('gc','fontsize',16)
leg=legend('Low Productivity', 'High Productivity');
set(leg,'location','best','fontsize',16)
legend boxoff
set (ht,'Units','Inches');
pos = get(ht,'Position');
set(ht,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(ht,'gc','-dpdf','-r0')

% 4.2. Policy Function for Assets

ht = figure;
plot(a(1:agrid),ga(1:agrid,1), 'linestyle','-','color',[0,0,0]+0.1,'linewidth',6)
hold on
plot(a(1:agrid),ga(1:agrid,2), 'linestyle','-','color',[0,0,0]+0.7,'linewidth',6)
set (gca,'fontsize',12)
box off
title ('Policy Funtion for Assets','fontsize',16)
xlabel('Assets','fontsize',16)
%ylabel('gc','fontsize',16)
leg=legend('Low Productivity', 'High Productivity');
set(leg,'location','best','fontsize',16)
legend boxoff
set (ht,'Units','Inches');
pos = get(ht,'Position');
set(ht,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(ht,'ga','-dpdf','-r0')
