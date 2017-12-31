%FBMC Modulator

N = 1024;           % Number of FFT points
numGuards = 212;         % Guard bands on both sides
K = 4;                   % Overlapping symbols, one of 2, 3, or 4
M = 4; 
k = log2(M);   % 2: 4QAM, 4: 16QAM, 6: 64QAM, 8: 256QAM
%length_PRBS = 2^16;
%numOFDMSymbols = length_PRBS/numBits; %But it needs to be integer
numOFDMSymbols = 10;

% FBMC filters each subcarrier modulated signal to decrease out-of-band.
% The filters are characterized by the overlapping factor, _K_ which is the number of
% multicarrier symbols that overlap in the time domain. 
% The prototype filter order can be chosen as _2*K-1_ where _K_ = 2, 3, or 4 and is
% selected as per the PHYDYAS project.
%
% The current FBMC implementation uses frequency spreading. It uses an 
% N*K_ length IFFT with symbols overlapped with a delay of _N/2_, where
% _N_ is the number of subcarriers. This design choice makes it easy to
% analyze FBMC and compare with other modulation methods.

% Prototype filter
switch K
    case 2
        HkOneSided = sqrt(2)/2;
    case 3
        HkOneSided = [0.911438 0.411438];
    case 4
        HkOneSided = [0.971960 sqrt(2)/2 0.235147];
    otherwise
        return
end

% Build symmetric filter
Hk = [fliplr(HkOneSided) 1 HkOneSided];

% Transmit-end processing
%   Initialize arrays
L = N-2*numGuards;  % Number of subcarriers with data = QAM symbols per OFDM symbol
KN = K*N;
KL = K*L;
dataSubCar = zeros(L, 1);
dataSubCarUp = zeros(KL, 1);

numBits = k*L/2;    % The 2 is as we will use double space for OQAM

inpData = zeros(numBits, numOFDMSymbols); 
rxBits = zeros(numBits, numOFDMSymbols);
txSigAll = complex(zeros(KN, numOFDMSymbols));
symBuf = complex(zeros(2*KN, 1));

% We configure the QAM symbol mapper
qamMapper = comm.RectangularQAMModulator(...
    'ModulationOrder', M, ...
    'BitInput', true, ...
    'NormalizationMethod', 'Average power');

% For each column we generate the data (inputData) and perform the Filter Bank
for symIdx = 1:numOFDMSymbols
    % Generate data and map qam
    inpData(:, symIdx) = randi([0 1], numBits, 1);
    modData = qamMapper(inpData(:, symIdx));
    
    % OQAM Modulator: alternate real and imaginary parts
    if rem(symIdx,2)==1     % Odd symbols
        dataSubCar(1:2:L) = real(modData);
        dataSubCar(2:2:L) = 1i*imag(modData);
    else                    % Even symbols
        dataSubCar(1:2:L) = 1i*imag(modData);
        dataSubCar(2:2:L) = real(modData);
    end

    % Upsample by K, pad with guards, and filter with the prototype filter
    dataSubCarUp(1:K:end) = dataSubCar;
    dataBitsUpPad = [zeros(numGuards*K,1); dataSubCarUp; zeros(numGuards*K,1)];
    X1 = filter(Hk, 1, dataBitsUpPad);
    
    % Remove 1/2 filter length delay
    X = [X1(K:end); zeros(K-1,1)];

    % Compute IFFT of length KN for the transmitted symbol
    txSymb = fftshift(ifft(X));

    % Transmitted signal is a sum of the delayed real, imag symbols
    symBuf = [symBuf(N/2+1:end); complex(zeros(N/2,1))];
    symBuf(KN+(1:KN)) = symBuf(KN+(1:KN)) + txSymb;

    % Compute power spectral density (PSD) for the plots later on
    currSym = complex(symBuf(1:KN));
    
    % Store transmitted signals for all symbols
    txSigAll(:,symIdx) = currSym;
end

%Now we have all the traditional FBMC signal generated. We need to generate
%the real time compatible according to Fatima Barrami et al.[1]
%txSigAll medeix K*N files i numOFDMSymbols columnes. Ara ho hem de passar a
%stream i real (anar llegint un de cada). Amb matriu perque aixi podrem
%veure com queden els espectres
fbmc_real = zeros(K*N,2*numOFDMSymbols);
for symIdx = 1:numOFDMSymbols
        fbmc_real(:,(symIdx*2)) = imag(txSigAll(:,symIdx));
        fbmc_real(:,(symIdx*2)-1) = real(txSigAll(:,symIdx));
end

% Plot original power spectral density
sumFBMCSpec = zeros(KN*2, 1);
sumOFDMSpec = zeros(N*2, 1);
for symIdx = 1:numOFDMSymbols
    currentSymbol = fbmc_real(:,symIdx*2);
    [specFBMC, fFBMC] = periodogram(complex(currentSymbol), hann(KN, 'periodic'), KN*2, 1);
    sumFBMCSpec = sumFBMCSpec + specFBMC;
end
sumFBMCSpec = sumFBMCSpec/mean(sumFBMCSpec(1+K+2*numGuards*K:end-2*numGuards*K-K));
plot(fFBMC-0.5,10*log10(sumFBMCSpec));
grid on
axis([-0.5 0.5 -180 10]);
xlabel('Normalized frequency'); 
ylabel('PSD (dBW/Hz)')
title(['Real FBMC, K = ' num2str(K) ' overlapped symbols'])
set(gcf, 'Position', figposition([15 50 30 30]));

%Paralel to serie and clocks
SignalTransmitted = reshape(fbmc_real, K*N*2*numOFDMSymbols, 1);   
    [f,c]=size(SignalTransmitted);
    
    %Guardamos la señal a transmitir junto con los clocks para los markers
    fich_name_I=['Signal_',num2str(M),'_QAM_FBMC_with_Clocks','.txt'];
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
    
save('SignalTransmitted.mat','SignalTransmitted')
save('InputData.mat','inpData')