% UFMC Demodulator
numFFT = 1024;        % number of FFT points
subbandSize = 30;    % must be > 1 
numSubbands = 20;    % numSubbands*subbandSize <= numFFT
subbandOffset = 212; % numFFT/2-subbandSize*numSubbands/2 for band center
numUFMCSymbols = 10;
load('SignalTransmitted.mat')

% Dolph-Chebyshev window design parameters
filterLen = 43;      % similar to cyclic prefix length
slobeAtten = 40;     % sidelobe attenuation, dB
M = 4;               % MQAM: 4QAM, 16QAM, 64QAM, 256QAM
k = log2(M);   

% Design window with specified attenuation
prototypeFilter = chebwin(filterLen, slobeAtten);

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
                    %Serie to paralel and real to complex
                    UFMC_real = reshape(SignalRecibida, numFFT+filterLen-1, 2*numUFMCSymbols);
                    txSigAll = zeros(numFFT+filterLen-1,numUFMCSymbols);
                    for symIdx = 1:numUFMCSymbols
                            txSigAll(:,(symIdx)) = UFMC_real(:,(2*symIdx)-1)+1i*UFMC_real(:,(2*symIdx));
                    end
                    rxBits = zeros(k*subbandSize*numSubbands,numUFMCSymbols);


                    for symIdx=1:numUFMCSymbols
                        yRx = txSigAll(:,(symIdx));
                        % Pad receive vector to twice the FFT Length (note use of txSig as input)
                        %   No windowing or additional filtering adopted
                        yRxPadded = [yRx; zeros(2*numFFT-numel(yRx),1)];

                        % Perform FFT and downsample by 2
                        RxSymbols2x = fftshift(fft(yRxPadded));
                        RxSymbols = RxSymbols2x(1:2:end);

                        % Select data subcarriers
                        dataRxSymbols = RxSymbols(subbandOffset+(1:numSubbands*subbandSize));

                        % Plot received symbols constellation
                    %     constDiagRx = comm.ConstellationDiagram('ShowReferenceConstellation', ...
                    %         false, 'Position', figposition([20 15 25 30]), ...
                    %         'Title', 'UFMC Pre-Equalization Symbols', ...
                    %         'Name', 'UFMC Reception', ...
                    %         'XLimits', [-150 150], 'YLimits', [-150 150]);
                    %     constDiagRx(dataRxSymbols);

                        % Use zero-forcing equalizer after OFDM demodulation
                        rxf = [prototypeFilter.*exp(1i*2*pi*0.5*(0:filterLen-1)'/numFFT); ...
                               zeros(numFFT-filterLen,1)];
                        prototypeFilterFreq = fftshift(fft(rxf));
                        prototypeFilterInv = 1./prototypeFilterFreq(numFFT/2-subbandSize/2+(1:subbandSize));

                        % Equalize per subband - undo the filter distortion
                        dataRxSymbolsMat = reshape(dataRxSymbols,subbandSize,numSubbands);
                        EqualizedRxSymbolsMat = bsxfun(@times,dataRxSymbolsMat,prototypeFilterInv);
                        EqualizedRxSymbols = EqualizedRxSymbolsMat(:);

                    %     % Plot equalized symbols constellation
                    %     constDiagEq = comm.ConstellationDiagram('ShowReferenceConstellation', ...
                    %         false, 'Position', figposition([46 15 25 30]), ...
                    %         'Title', 'UFMC Equalized Symbols', ...
                    %         'Name', 'UFMC Equalization');
                    %     constDiagEq(EqualizedRxSymbols);

                        % Demapping and BER computation
                        qamDemod = comm.RectangularQAMDemodulator('ModulationOrder', ...
                            2^k, 'BitOutput', true, ...
                            'NormalizationMethod', 'Average power');
                        BER = comm.ErrorRate;

                        % Perform hard decision and measure errors
                        rxBits(:,(symIdx)) = qamDemod(EqualizedRxSymbols);
                    end

                    load('inputdata.mat')
                    ber = BER(inputData(:), rxBits(:));

                    disp(['UFMC Reception, BER = ' num2str(ber(1))]);

                    matrixNumErrors(m,n) = ber(2);
                    matrixBER(m,n) = ber(1);
                    %[matrixNumErrors(m,n), matrixBER(m,n)]=biterr(not(finalData),inputData);
    end
end
save(nameMatrixBERatt,'matrixBER')


