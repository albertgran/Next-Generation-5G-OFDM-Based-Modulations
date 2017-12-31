%OFDM Demodulator
clc
clear
close

N = 1024;           % Number of FFT points
numGuards = 212;         % Guard bands on both sides
M = 4; 
k = log2(M);   % 2: 4QAM, 4: 16QAM, 6: 64QAM, 8: 256QAM
%length_PRBS = 2^16;
%numOFDMSymbols = length_PRBS/numBits; %But it needs to be integer
numOFDMSymbols = 10;

AttMax = 29; %máx atenuacion considerada
Att = 1:4:AttMax; %vector de attenuaciones
NumeroCapturas = 10; %numero de capturas de la trama para hacer media 

% We load the results of our experiment as well as the input data to
% compute the BER
load('InputData.mat')

matrixBER = zeros(length(Att),NumeroCapturas);
matrixNumErrors = zeros(1,length(Att));
nameMatrixBERatt='matrixBER';

for m=1:length(Att)
    SignalRecibidaName=['SignalRecibida_Att_',num2str(Att(m))];
    load(SignalRecibidaName)
    for n=1:NumeroCapturas
        SignalRecibida=matrixSignalRecibida(n,:); 
                
                    %Convert from real to complex 
                    ofdm_real = reshape(SignalRecibida, N,2*numOFDMSymbols);  
                    txSigAll2 = zeros(N, numOFDMSymbols);
                    for symIdx = 1:numOFDMSymbols
                            txSigAll2(:,(symIdx)) = ofdm_real(:,(2*symIdx)-1)+1i*ofdm_real(:,(2*symIdx));
                    end

                    % QAM demodulator
                    qamDemod = comm.RectangularQAMDemodulator(...
                        'ModulationOrder', M, ...
                        'BitOutput', true, ...
                        'NormalizationMethod', 'Average power');
                    BER = comm.ErrorRate;

                    %OFDM demodulator
                    demodOFDM = comm.OFDMDemodulator('FFTLength',N,...
                                'NumGuardBandCarriers',[numGuards;numGuards],...
                                'RemoveDCCarrier', false,...
                                'PilotOutputPort', false,...
                                'CyclicPrefixLength',0,...
                                'NumSymbols', 1,...
                                'NumReceiveAntennas', 1);

                    % Process symbol-wise
                    for symIdx = 1:numOFDMSymbols
                        rxSig = txSigAll2(:, symIdx);

                        rxdem = step(demodOFDM,rxSig);

                        % Demapper: Perform hard decision
                        rxBits(:, symIdx) = qamDemod(rxdem);    
                    end

                    % Measure BER with appropriate delay
                    ber = BER(inpData(:), rxBits(:));

                    % Display Bit error
                    disp(['OFDM Reception BER = ' num2str(ber(1)) ])

                    matrixNumErrors(m,n)= ber(2);
                    matrixBER(m,n)=ber(1);
                    %[matrixNumErrors(m,n), matrixBER(m,n)]=biterr(not(finalData),inputData);
    end
end
save(nameMatrixBERatt,'matrixBER')

