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


function diff_crit = point_process_interval(vals)
    crit_1=mean(vals)+std(vals);
    crit_2=mean(vals)-std(vals);

    crit_1_idx=find(vals>(crit_1));
    crit_2_idx=find(vals<(crit_2));
    diff_crit=mean(diff(sort([crit_1_idx crit_2_idx])));
    if isnan(diff_crit)
        diff_crit = 0;
    end
end