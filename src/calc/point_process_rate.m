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


function newValue = point_process_rate(vals)


   	crit_1=mean(vals)+std(vals);
    crit_2=mean(vals)-std(vals);
    
        crit_1_idx=find(vals>(crit_1));
        crit_2_idx=find(vals<(crit_2));
        peaks_crit_1=length(crit_1_idx);
        peaks_crit_2=length(crit_2_idx);
        peaks_total=peaks_crit_1+peaks_crit_2;
        rate_crossings=peaks_total/length(vals);
       
      
        newValue=rate_crossings;
end