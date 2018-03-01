%%% idea and function from http://studyforrest.org/contest_findforrestnetworks.html
%%%Identifying task-related activity using periodic graph properties
%%% Sat 01 November 2014 Lars Marstaller, Jeiran Choupan, Arend Hintze

%%% Periodicity: band pass filtered the time series of graph measures(optional)
%%% and projected it into the frequency domain using a Fast Fourier transform. Next, we counted the
%%% number of peaks (defined as zero crossings of the first derivative) and calculated the maximum
%%% and the median of the power spectrum. From these we derive a final singular measure, which is
%%%higher the more 'peaky' the power spectrum and hence the more periodic the changes in network properties (measure = maximum/[median*peaks]).


function newValue = periodicity(vals)

%%% if signal processing toolbox is present you can use the uncommented
%%% computations

%    [b,a]=butter(5,[0.05,0.1]); %%% filter graph time series in range
%    vals=filtfilt(b,a,vals);    %%% zero phase digital filtering


   	valsFFT=fft(vals,2^nextpow2(length(vals)))/length(vals);
	NFFT=2^nextpow2(length(vals));
	valsPow=2*abs(valsFFT(1:NFFT/2+1));

        valsDer=diff(valsPow(1,1:length(valsPow)));
        zcd_idx=find(diff(valsDer>0)~=0)+1; %with signal processing toolbox:  zcd=dsp.ZeroCrossingDetector;
        peaks=length(zcd_idx); %with signal processing toolbox: peaks=double(step(zcd,valsDer'));
       
        me=median(valsPow(1,round(length(valsPow)/2):length(valsPow)));
        ma=max(valsPow(1,round(length(valsPow)/2):length(valsPow)));

        newValue=ma/(me*peaks);
end



% The MIT License (MIT)
% 
% Copyright (c) <year> <copyright holders>
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
