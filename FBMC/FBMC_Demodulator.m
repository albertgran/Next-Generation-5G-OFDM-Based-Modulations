%FBMC Demodulator

% The example implements a basic FBMC demodulator and measures the BER for
% the chosen configuration. The processing
% includes matched filtering followed by OQAM separation to form the
% received data symbols. These are demapped to bits and the resultant bit
% error rate is determined. 

N = 1024;           % Number of FFT points
numGuards = 212;         % Guard bands on both sides
K = 4;                   % Overlapping symbols, one of 2, 3, or 4
M = 4; 
k = log2(M);   % 2: 4QAM, 4: 16QAM, 6: 64QAM, 8: 256QAM
%length_PRBS = 2^16;
%numOFDMSymbols = length_PRBS/numBits; %But it needs to be integer
numOFDMSymbols = 10;

%   Initialize arrays
L = N-2*numGuards;  % Number of subcarriers with data = QAM symbols per OFDM symbol
KN = K*N;
KL = K*L;

% We load the results of our experiment as well as the input data to
% compute the BER
load('SignalTransmitted.mat')
load('InputData.mat')


AttMax = 29; %máx atenuacion considerada
Att = 1:4:AttMax; %vector de attenuaciones
NumeroCapturas = 10; %numero de capturas de la trama para hacer media 

matrixBER = zeros(length(Att),NumeroCapturas);
matrixNumErrors = zeros(1,length(Att));
nameMatrixBERatt='matrixBER';

% QAM demodulator
qamDemod = comm.RectangularQAMDemodulator(...
    'ModulationOrder', 2^k, ...
    'BitOutput', true, ...
    'NormalizationMethod', 'Average power');


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

for m=1:length(Att)
    SignalRecibidaName=['SignalRecibida_Att_',num2str(Att(m))];
    load(SignalRecibidaName)
    for n=1:NumeroCapturas
        SignalRecibida=matrixSignalRecibida(n,:); 
                    %Convert from real to complex 
                    fbmc_real = reshape(SignalRecibida, K*N,2*numOFDMSymbols);  
                    txSigAll = zeros(K*N, numOFDMSymbols);
                    for symIdx = 1:numOFDMSymbols
                            txSigAll(:,(symIdx)) = fbmc_real(:,(2*symIdx)-1)+1i*fbmc_real(:,(2*symIdx));
                    end

                    % Process symbol-wise
                    for symIdx = 1:numOFDMSymbols
                        rxSig = txSigAll(:, symIdx);

                        % Perform FFT
                        rxf = fft(fftshift(rxSig));

                        % Matched filtering with prototype filter
                        rxfmf = filter(Hk, 1, rxf);
                        % Remove K-1 delay elements
                        rxfmf = [rxfmf(K:end); zeros(K-1,1)];
                        % Remove guards
                        rxfmfg = rxfmf(numGuards*K+1:end-numGuards*K);

                        % OQAM post-processing
                        %  Downsample by 2K, extract real and imaginary parts
                        if rem(symIdx, 2)
                            % Imaginary part is K samples after real one
                            r1 = real(rxfmfg(1:2*K:end));
                            r2 = imag(rxfmfg(K+1:2*K:end));
                            rcomb = complex(r1, r2);
                        else
                            % Real part is K samples after imaginary one
                            r1 = imag(rxfmfg(1:2*K:end));
                            r2 = real(rxfmfg(K+1:2*K:end));
                            rcomb = complex(r2, r1);
                        end
                        %  Normalize by the upsampling factor
                        rcomb = (1/K)*rcomb;

                        % Demapper: Perform hard decision
                        rxBits(:, symIdx) = qamDemod(rcomb);    
                    end

                    % Measure BER with appropriate delay
                    BER = comm.ErrorRate;
                    BER.ReceiveDelay = k*KL;
                    ber = BER(inpData(:), rxBits(:));

                    % Display Bit error
                    disp(['FBMC Reception for K = ' num2str(K) ', BER = ' num2str(ber(1)) ])

                    matrixNumErrors(m,n)= ber(2);
                    matrixBER(m,n)=ber(1);
                    %[matrixNumErrors(m,n), matrixBER(m,n)]=biterr(not(finalData),inputData);
    end
end
save(nameMatrixBERatt,'matrixBER')


