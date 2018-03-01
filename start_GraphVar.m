%  This file is part of GraphVar.
% 
%  Copyright (C) 2017
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

global root_path;
global source_path
global workspace_path;

global data_path;

global brain_path;
global Brain_Atlas;
global ROI_path;

fileName = mfilename;
root_path = mfilename('fullpath');
root_path =  root_path(1:end-length(fileName));
cd(root_path);
source_path = [root_path 'src' filesep];
addpath(source_path);
addpath(root_path);

addpath(genpath(source_path))
workspace_path = [root_path 'workspaces'];

fprintf('Welcome to GraphVar\n')
fprintf('Release= 2.00 \n')
fprintf('GraphVar 1.00 was developed by Johann Kruschwitz*, David List*, L. Waller, and Mikael Rubinov; *equal contribution\n')
fprintf('GraphVar 2.00 was developed by Anastasia Brovkin*, L. Waller*, L. Dorfschmidt*, D. Bdzok* and Johann Kruschwitz*; *equal contribution\n')
fprintf('Division of Mind and Brain Research, Department for Psychiatry, Charité Berlin, Germany\n')
fprintf('Department for General Psychology, Technische Universität Dresden TUD, Germany\n')
fprintf('Brain Mapping Unit, Department of Psychiatry, University of Cambridge, Cambridge, United Kingdom\n')
fprintf('Funding for this project was provided by the German Research Foundation (DFG) grant SFB940/2 2016\n')
fprintf('Mail to Authors:  johann.kruschwitz@charite.de; anastasia.brovkin@charite.de; lea.waller@charite.de;\n')
fprintf('-----------------------------------------------------------\n')
fprintf('Citing Information:\n')
fprintf('If you think GraphVar is useful for your work, citing it in your paper would be greatly appreciated.\n')
fprintf('Please always cite also the first GraphVar publication. i.e., Kruschwitz et al (2015) and Brovkin et al (2018).\n')
fprintf('Reference: Kruschwitz JD, List D, Waller L, Rubinov M, Walter H, GraphVar: A user-friendly toolbox for comprehensive graph analyses of functional brain connectivity, Journal of Neuroscience Methods (2015), http://dx.doi.org/10.1016/j.jneumeth.2015.02.021\n')
fprintf('Reference: Brovkin A, Waller L, Dorfschmidt L, Bzdok D, Walter H, Kruschwitz J, GraphVar 2.0: A user-friendly toolbox for machine learning on functional brain connectivity measures, Journal: n.n. \n')


Welcome();
