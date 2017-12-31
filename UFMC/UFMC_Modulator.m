
% UFMC Modulator
numFFT = 1024;        % number of FFT points
subbandSize = 30;    % must be > 1 
numSubbands = 20;    % numSubbands*subbandSize <= numFFT
subbandOffset = 212; % numFFT/2-subbandSize*numSubbands/2 for band center
numUFMCSymbols = 10;

% Dolph-Chebyshev window design parameters
filterLen = 43;      % similar to cyclic prefix length
slobeAtten = 40;     % sidelobe attenuation, dB
M = 4;               % MQAM: 4QAM, 16QAM, 64QAM, 256QAM
k = log2(M);   

% Design window with specified attenuation
prototypeFilter = chebwin(filterLen, slobeAtten);

% QAM Symbol mapper
qamMapper = comm.RectangularQAMModulator('ModulationOrder', ...
    2^k, 'BitInput', true, ...
    'NormalizationMethod', 'Average power');

% Transmit-end processing
%  Initialize arrays
inpData = zeros(k*subbandSize, numSubbands);
inputData= zeros(k*subbandSize*numSubbands,numUFMCSymbols);

UFMCcomplex = complex(zeros(numFFT+filterLen-1, numUFMCSymbols));

for symIdx = 1:numUFMCSymbols
    %  Loop over each subband
    txSig = complex(zeros(numFFT+filterLen-1, 1));
    for bandIdx = 1:numSubbands
        bitsIn = randi([0 1], k*subbandSize, 1);
        symbolsIn = qamMapper(bitsIn);
        inpData(:,bandIdx) = bitsIn; % log bits for comparison

        % Pack subband data into an OFDM symbol
        offset = subbandOffset+(bandIdx-1)*subbandSize; 
        symbolsInOFDM = [zeros(offset,1); symbolsIn; ...
                         zeros(numFFT-offset-subbandSize, 1)];
        ifftOut = ifft(ifftshift(symbolsInOFDM));

        % Filter for each subband is shifted in frequency
        bandFilter = prototypeFilter.*exp( 1i*2*pi*(0:filterLen-1)'/numFFT* ...
                     ((bandIdx-1/2)*subbandSize+0.5+subbandOffset+numFFT/2) );    
        filterOut = conv(bandFilter,ifftOut);

        % Sum the filtered subband responses to form the aggregate transmit
        % signal
        txSig = txSig + filterOut;     
    end
    UFMCcomplex(:,symIdx) = txSig;
    inputData(:,symIdx)= inpData(:);
end

%Now we just need to convert the result to real for IM/DD
UFMC_real = zeros(numFFT+filterLen-1, 2*numUFMCSymbols);
for symIdx = 1:numUFMCSymbols
        UFMC_real(:,(symIdx*2)) = imag(UFMCcomplex(:,symIdx));
        UFMC_real(:,(symIdx*2)-1) = real(UFMCcomplex(:,symIdx));
end

%Paralel to serie and clocks
SignalTransmitted = reshape(UFMC_real, 2*numUFMCSymbols*(numFFT+filterLen-1), 1);   

    [f,c]=size(SignalTransmitted);
    %Guardamos la señal a transmitir junto con los clocks para los markers
    fich_name_I=['Signal_',num2str(M),'_QAM_UFMC_with_Clocks','.txt'];
    fid_i=fopen(fich_name_I,'w');

    for i=1:f  
        fprintf(fid_i,'%.9e,',SignalTransmitted(i,1)); 
        if(mod(i,2)==0)
            fprintf(fid_i,'%i,',1); fprintf(fid_i,'%i',1);
        else
            fprintf(fid_i,'%i,',0); fprintf(fid_i,'%i',0);
        end
        fprintf(fid_i,'\r\n');
    end
    fclose(fid_i);
    
save('inputdata.mat','inputData')
save('SignalTransmitted.mat','SignalTransmitted')
