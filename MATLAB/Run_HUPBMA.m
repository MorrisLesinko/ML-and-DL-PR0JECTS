%% =============================================================== %
% Description
% This code runs the HUP-BMA (Integration of Hydrologic Uncertainty
% Processor (HUP)and Bayesian Model Averaging (BMA) approaches). HUP-BMA is
% a post-processing approach which quantifies the hydrologic uncertainty
% and provides probabilistic streamflow forecasts.
% =============================================================== %
% Written by Pedram Darbandsari, April 2020
% Water Resources and Hydrologic Modeling Lab
% FloodNet - an NSERC Canadian Strategic Network
% Department of Civil Engineering
% McMaster University
% E-mail: darbandp@mcmaster.ca
% =============================================================== %
% Reference(s) for this algorithm:
%   1. Darbandsari. P., and Coulibaly. P. (2021), HUP-BMA: An Integration 
%      of Hydrologic Uncertainty Processor and Bayesian Model Averaging
%      for Streamflow Forecasting, Water Resources Research, under review
% =============================================================== %
% References for methods used in this algorithm:
%   Hydrologic Uncertainty Processor (HUP):
%       1. Krzysztofowicz, R., Herr, H.D. (2001), Hydrologic uncertainty processor 
%          for probabilistic river stage forecasting: precipitation-dependent model. 
%          Journal of Hydrology, 249: 46-68.
%       2. Han, S., Coulibaly, P., Biondi, D. (2019), Assessing hydrologic uncertainty processor
%          performance for flood forecasting in a semiurban watershed. 
%          Journal of Hydrologic Engineering, 24(9): 05019025.
%   Bayesian Model Averaging (BMA) method and the modified expectation-maximization algorithm:
%       1. Raftery, A. E., Gneiting, T., Balabdaoui, F., and Polakowski, M.
%          (2005). Using Bayesian Model Averaging to Calibrate Forecast
%       Ensembles. Monthly Weather Review, 133(5), 1155–1174
%       2. Madadgar, S., and Moradkhani, H. (2014). Improved Bayesian multimodeling: 
%          Integration of 867 copulas and Bayesian model averaging. Water Resources Research, 
%          50(12), 9586–9603.
% =============================================================== %
% Input(s):
%   InputData.mat: the observed precipitation and streamflow data and 
%                  1- to n- days ahead ensemble of streamflow forecasts.
%        Includes:
%            obsp.Cal = observed precipitation in the calibration period (tc by 1 matrix)
%            obsp.Val = observed precipitation in the validation period (tv by 1 matrix)
%            hn.Cal = observed flow in calibration period (tc by n + 1 matrix)
%                     At each time step (each row): h0,h1,h2, ..., hn
%            hn.Val = observed flow in validation period (tv by n + 1 matrix)
%                     At each time step (each row): h0,h1,h2, ..., hn
%            esn.Cal.Mk = The kth member of the forecasted flow in the
%                         calibration period (tc by n matrix). 
%                         For each member at each time step: sk1,sk2,sk3,...,skn)
%            esn.Val.Mk = The kth member of the forecasted flow in the
%                         validation period (tv by n matrix).
%                         For each member at each time step: sk1,sk2,sk3,...,skn)
%        Note: In the above mentioned explanation:
%       	tc = number of dates in the calibration period.
%           tv = number of dates in the validation period.
%           n = The forecasting horizon.
%   InputPara.mat: The user-specified parameters.
%       Includes:
%            Th: The precipitation threshold for dividing rainy and non-rainy dates. 
%                Defualt value = 0. 
%                Note: Th = 0 is considered in Krzysztofowicz and Herr (2001).
%            NQT: 0: Parametric and 1: Empirical Normal Quantile Transform.
%                 Default value = 1. 
%                 Note: Empirical is recommended in Krzysztofowicz and Herr (2001). 
%            prc: Confidence interval for finding uncertainty bound. 
%                 Default value =  0.95.
%            CTh: A correlation threshold for unconditional prior and likelihood in HUP. 
%                 Default value = 0.5.
% =============================================================== %
% Main Functions:
%   HUP_EnCalibration.p: It estimates the HUP parameters based on different
%       forecast members.
%   BMA_Cal_ModifiedEM.p: It estimates the BMA weights using the modified
%       Expectation-Maximization algorithm based on HUP-derived posterior
%       distributions from different forecast members in the calibration
%       period.
%   HUPBMA_Forecast.p: It runs the calibrated HUP-BMA in the validation
%       period
% =============================================================== %
% Output(s):
%       HUPBMA_para.mat: HUP-BMA parameters including HUP parameters based
%                        on different members of forecasts  and BMA weights
%       HUPBMA_Results.mat: The HUP-BMA probabilistic forecasts in the
%       validation period.
% =============================================================== %
% DISCLAIMER:  
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation. You should have received a copy of the
%   GNU General Public License along with this program.
%   This program is not guaranteed to be free of error (although it is
%   believed to be free of error).  This software is provided 'AS IS',
%   without warranty of any kind, expressed or implied, including but not
%   limited to the warranties of merchantability, fitness for a particular
%   purpose and noninfringement. In no event shall the authors or copyright
%   holders be liable for any claim, damages or other liability, whether in
%   an action of contract, tort of otherwise, arising from, out or in
%   connection with the software or the use or other dealings in the software.

%% ----------------------------------------------------------------
clear;
clc;
%% load input data
load('InputData'); 
load('InputPara');
n = size(hn.Cal,2) - 1; % Forecasting horizon

%% Some quick error checking
% Ensure the forecasts is available for all lead-times
for t1 = ["Cal","Val"]
    for t2 = 1:length(fieldnames(esn.(t1)))
        temp1 = esn.(t1).(['M',num2str(t2)]);
        if size(temp1,2) ~= n
            error('The lead-time of forecasts do not match with observation')
        end
    end
end
% Ensure the input parameters are in the range
if CTh > 1
    error('CTh must be between 0 and 1')
end
if prc > 1 || prc < 0
    error('prc must be between 0 and 1')
end
if ismember(NQTT,[0,1]) ~= 1
    error ('NQTT must be either 0 or 1')
end
if Th < 0                                                                                                                                                                         
    error('Th must be larger or equal to zero')
end 
CTh = 0;
%% Determine the leadtime where correlation is less than threshold
CorrCoeff = corrcoef(hn.Cal);
% ltn: the lead time  where correlation is less than the threshold
ltn = find(CorrCoeff(1,:) < CTh,1) - 1;
if isempty(ltn) == 1
    ltn = size(hn.Cal,2);
end

%% Estimate HUP parameters
[An0,An1,Bn0,Bn1,Dn0,Dn1,Tn0,Tn1,pd_hn0,pd_hn1,pd_sn0,pd_sn1] = HUP_Cal(hn.Cal,esn.Cal,obsp.Cal,Th,NQTT,ltn);

%% Estimate BMA parameters
[Weight] = BMA_Cal_ModifiedEM(hn.Cal,esn.Cal,obsp.Cal,An0,An1,Bn0,Bn1,Dn0,Dn1,Tn0,Tn1,pd_hn0,pd_hn1,pd_sn0,pd_sn1,Th);

%% Save Parameters
save('HUPBMA_Para','An0','An1','Bn0','Bn1','Dn0','Dn1','Tn0','Tn1','pd_hn0','pd_hn1','pd_sn0','pd_sn1','n','Weight');

%% Run HUPBMA in validation period
[HUPBMAR] = HUPBMA_Forecast(An0,An1,Bn0,Bn1,Dn0,Dn1,Tn0,Tn1,pd_hn0,pd_hn1,pd_sn0,pd_sn1,Weight,hn.Val,esn.Val,obsp.Val,prc,Th);

%% save the final forecast
save('HUPBMA_Results','HUPBMAR','hn');
