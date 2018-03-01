function [isParallel, hasParallel, N] = isParallel(varargin)
    % Determines version of Parallel Computing Toolbox 
    % Determines number of parallel workers, overwrites with user selection
    
    dcVer = ver('distcomp'); % determine version of 
    
    
    isParallel = 0;
    hasParallel = 0;
    N = 0;
    
    targetN = [];
    if ~isempty(varargin)
        targetN = varargin{1}; % user selected number of parallel workers
    end
    

    if isempty(dcVer) % doesn't have parallel toolbox 
  
    elseif verLessThan('matlab', '8.2') 
        % bad conditional str2double(dcVer.Version) < 6.3
        % call matlabpool function 
            hasParallel = 1;
            
         if N == 0 && ~isempty(targetN) && targetN > 0
           matlabpool(targetN) ;           
         elseif N ~= 0 && (~isempty(targetN) && targetN ~= N) 
           matlabpool close
           matlabpool(targetN);     
         end

    else
    % call parpool 
    hasParallel = 1;
    
            Pool = gcp('nocreate');
            if isempty(Pool)
                if ~isempty(targetN)
                    % test parpool does not 
                    % exceed number of local workers
                    Pool = parpool(targetN);
                    isParallel = 1;
                    N = Pool.NumWorkers;           
                end
            else
                isParallel = 1;
                N = Pool.NumWorkers;

                if isempty(targetN) 
                elseif targetN == 0
                    delete(Pool);
                elseif targetN ~= N
                    delete(Pool);
                    Pool = parpool(targetN);
                end
            end


    end
   
end