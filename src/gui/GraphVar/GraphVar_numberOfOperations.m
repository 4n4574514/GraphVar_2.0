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

function nOp = GraphVar_numberOfOperations(vpFiles,dialogData)
if dialogData.testAgainstRandGroup
    nRand = dialogData.nRandGroup;
    nShuffel = dialogData.nRandGroup;
elseif dialogData.RandomDataRepitions > 0
    nRand = dialogData.RandomDataRepitions;
    nShuffel = dialogData.RandomDataRepitions;
else
    nRand =dialogData.nRandom;
    nShuffel = dialogData.nShuffel;
    if ~dialogData.testAgainstShuffel
        nShuffel = 0;
    end
end


nDyn = 1;
MName = dialogData.MatrixName;

if iscell(MName)
    MName = MName{:};
end

% check if dynamic measures selected
if ~isempty(dialogData.DynamicGraphVar) || ~isempty(dialogData.DynamicGraphVar2)
   if  ~strcmp(dialogData.DynamicGraphVar, 'Select Dynamic') || ~strcmp(dialogData.DynamicGraphVar2, 'Select Dynamic')
       is_dyn = [];
   end    
end

Matrix = load(dialogData.subjects{1}, MName);

if isfield(Matrix, 'is_dyn') && Matrix.is_dyn
    nDyn = numel(Matrix.(MName));
end

fullFunctionList = getFunctions(0);
nSub = length(vpFiles);
nOp = nSub*dialogData.nShuffel*nDyn;                         % SHUFFELD
types = (~isempty(dialogData.functionList{1})) + (~isempty(dialogData.functionList{2}));
nOp = nOp + types * nSub * length(dialogData.thresholds)*nDyn;  % THRESHOLDING
nOp = nOp + types * nSub*dialogData.nRandom * length(dialogData.thresholds)*nDyn;  % Randomizing
nOp = nOp + (length(dialogData.functionList{1}) + length(dialogData.functionList{2})) * nSub*(dialogData.nRandom+1) * length(dialogData.thresholds)*nDyn;  % GraphFunc


% [~,loc] = ismember(dialogData.functionList{1},fullFunctionList{1}(:,2));
% fTypes = fullFunctionList{1}(loc,3);
% [~,loc] = ismember(dialogData.functionList{2},fullFunctionList{2}(:,2));
% fTypes = {fTypes{:} fullFunctionList{2}{loc,3}};
% nCorr = 0;
% corrFact = length(dialogData.VarList) * length(dialogData.thresholds) * (nRand+1);
% for i = 1:length(fTypes)
%     if(fTypes{i} == 1)
%         nCorr = nCorr + corrFact;
%     else
%         nCorr =  nCorr + matrixSize^(fTypes{i}-1) * corrFact;
%     end
% end
% 
% 
% if~isempty(dialogData.functionList{3})
%     if isempty(dialogData.ConnectivityThr)
%         dialogData.ConnectivityThr = 1;
%     end
%     nCorr =  nCorr + ((matrixSize^2-matrixSize)/2) * length(dialogData.VarList) * (nShuffel+1) * length(dialogData.ConnectivityThr);
% end
% 
% nOp = nOp + nCorr;