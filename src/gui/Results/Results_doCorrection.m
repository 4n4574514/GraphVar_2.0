%  This file is part of GraphVar.
% 
%  Copyright (C) 2014
% 
%  GraphVar is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
% 
%  GraphVar is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
% 
%  You should have received a copy of the GNU General Public License
%  along with GraphVar.  If not, see <http://www.gnu.org/licenses/>.

function pCorr = Results_doCorrection(handles,hObject,pVals,maxPVal)
global result_path;
global result_folder;
CORRECTION_NONE = 1;
CORRECTION_BONFERRONI = 2;

% #4 is Permutation without correction 
CORRECTION_BONFERRONI_RAND = 5;
CORRECTION_FDR = 3;
CORRECTION_FDR_RAND = 6;

STAT = pVals;

correction = get(handles.correction_type,'value');   % correction drop down menu 

corrType(1) = get(handles.CorVar,'value');
corrType(2) = get(handles.CorGraph,'value');
corrType(3) = get(handles.CorThresh,'value');
corrType(4) = get(handles.CorBrain,'value');

%  Get filters (ie. user choices from list boxes) 
[thresh,fun,var,brain] = Results_Filters(hObject,handles);
if(corrType(1) == 1)
    var = 1:length(handles.vars);   % number of variables selected  
end
if(corrType(2) == 1)
    fun = 1:length(handles.functionList);   % number of functions selected 
end
if(corrType(3) == 1)
    thresh = 1:length(handles.thresholds);   % number of thresholds 
end
if(corrType(4) == 1)
    brain = 1:length(handles.BrainStrings);     % number of brain areas selected 
end

switch correction
    case CORRECTION_NONE
        pCorr = maxPVal;    % ie 0.05
     
        %% BONFERRONI 
    case   {CORRECTION_BONFERRONI, CORRECTION_BONFERRONI_RAND}   %Bonferroni correction logic for permutation or parametric 
        if(corrType(1) == 1 || corrType(1) == 3)               % if "ALL" or "SELECTED" 
            corFac = length(var);                                      % number of variables selected                                   
        elseif (corrType(1) == 2)
            corFac = 1;                                                    % none selected (so multiply only by 1) 
        end

        if(corrType(2) == 1 || corrType(2) == 3)
            corFac = corFac * length(fun);                          % 
        end
        
        if(corrType(3) == 1 || corrType(3) == 3)
            corFac = corFac * length(thresh);
        end
        
        %local
        if (handles.PlotType == 2 && (corrType(4) == 1 || corrType(4) == 3))
            corFac = corFac * length(brain);     % ie factor x local (ie 90) 
        end
        
        %corr_area
        if (handles.PlotType == 3 && (corrType(4) == 1 || corrType(4) == 3))  % corr matrix type 
            corFac = corFac * length(brain) * length(brain);         % factor x corr (ie 90x90)    
        end
  
% define different corrFac for Type 4 => weights plot in ML 
        % corrType(1) is empty (no correction for outcome variable) 
         if (handles.PlotType == 4)    
             corFac = 1  ;      
                 if ( corrType(2) == 1 || corrType(2) == 3)  % ie. length of STAT selected
                 corFac = corFac * length(STAT);
                 elseif (corrType(2) == 2)
                 corFac = 1  ;                                          % none selected (so multiply only by 1) 
                 end
                 if (corrType(3) == 1 || corrType(3) == 3) % threshold 
                      corFac = corFac * length(thresh);
                 end

                 % corrBrainAreas => not relevant since selection by
                 % feature, not brain string (!) feat. length incl. info
         end 
      
        [a,b] = size(pVals);
        pCorr = maxPVal/corFac;
       

        %% FALSE DISCOVERY RATE
    case {CORRECTION_FDR , CORRECTION_FDR_RAND}       % PARAMETRIC or PERMUTATION FALSE DISCOVERY RATE
        
        if handles.PlotType == 4 
            if corrType(2) == 1 || corrType(2) == 3
                  pCorr =  fdr(STAT,maxPVal);
            else 
                  pCorr =   maxPVal;
            end
        else 
        
            if(sum(corrType == [3 3 3 3])==4)||(corrType(1) == 3 && corrType(2) == 3 && corrType(3) == 3 && handles.PlotType == 1)
                % if all corrections selected, or if corrections for all (of

                pCorr =  fdr(pVals,maxPVal);
                disp('Standard Abweichung:')   % Standard Deviation 
                std(std(pVals)); 
                disp('Mittelwert:')                    % Mean 
                mean(mean(pVals)); 
            else
                for i_thr = 1: length(thresh)
                    for i_func = 1:length(fun)
                        for i_var = 1:length(var)
                            load([result_path filesep result_folder filesep handles.Files{thresh(i_thr),fun(i_func),var(i_var),1}]);
                            switch Result.type
                                case 'Group'
                                    isGroups = 1;
                                    testSelected = get(handles.GroupTestChooser,'Value');
                                    if length(Result.groups) > 2
                                        if(testSelected == 1)
                                            PVAL1    = squeeze(Result.anovaP);
                                        else
                                            PVAL1    = squeeze(Result.PVAL{testSelected-1});
                                        end
                                    else
                                        PVAL1    = squeeze(Result.PVAL);
                                    end
                                case {'Correlation' , 'Partial'}
                                    PVAL1   = squeeze(Result.PVAL);
                            end

                            if(length(PVAL1) == 1)
                                PVAL(i_thr,i_func,i_var,:) = PVAL1;
                            elseif(ndims(PVAL1) == 2)
                                PVAL(i_thr,i_func,i_var,:,:) = PVAL1;
                            else
                                PVAL(i_thr,i_func,i_var) = PVAL1;
                            end
                        end
                    end
                end
                if(ndims(PVAL) == 5) && corrType(4) == 3
                    pCorr =  fdr(PVAL(:,:,:,brain,brain),maxPVal); 
                elseif(ndims(PVAL) == 4) && corrType(4) == 3
                    pCorr =  fdr(PVAL(:,:,:,brain),maxPVal); 
                else
                    pCorr =  fdr(PVAL,maxPVal); 
                end

            end
        end  %end Weights plot exception 
    otherwise
        pCorr = maxPVal; 
end

set(handles.CorrectedAlpha,'String',num2str(pCorr));
