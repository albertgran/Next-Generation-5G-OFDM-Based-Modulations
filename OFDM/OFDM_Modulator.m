%OFDM Modulator

N = 1024;           % Number of FFT points
numGuards = 212;         % Guard bands on both sides
numOFDMSymbols = 10;        % Simulation length in symbols
L = N-2*numGuards;  % Number of subcarriers with data = QAM symbols per OFDM symbol
txSigAll = complex(zeros(N, numOFDMSymbols));
M = 4; 
k = log2(M);   % 2: 4QAM, 4: 16QAM, 6: 64QAM, 8: 256QAM

numBits = k*L;
inpData = zeros(numBits, numOFDMSymbols); 


% We configure the QAM symbol mapper
qamMapper = comm.RectangularQAMModulator(...
    'ModulationOrder', M, ...
    'BitInput', true, ...
    'NormalizationMethod', 'Average power');

% We configure the OFDM symbol modulator
modOFDM = comm.OFDMModulator('FFTLength',N,'NumGuardBandCarriers',[numGuards;numGuards],...
    'PilotInputPort',false, ...
    'NumSymbols',1, ...
    'CyclicPrefixLength',0, ...
    'InsertDCNull',false);
disp(modOFDM)

for symIdx = 1:numOFDMSymbols
    inpData(:, symIdx) = randi([0 1], numBits, 1);
    modData = qamMapper(inpData(:, symIdx));
    ifftOut = step(modOFDM,modData); %Modulates with OFDMModulator
    txSigAll(:,symIdx) = ifftOut;
end

%Now we have all the traditional OFDM signal generated. We need to generate
%the real time compatible according to Fatima Barrami et al.[1]
%txSigAll medeix K*N files i numOFDMSymbols columnes. Ara ho hem de passar a
%stream i real (anar llegint un de cada). Amb matriu perque aixi podrem
%veure com queden els espectres
ofdm_real = zeros(N,2*numOFDMSymbols);
for symIdx = 1:numOFDMSymbols
        ofdm_real(:,(symIdx*2)) = imag(txSigAll(:,symIdx));
        ofdm_real(:,(symIdx*2)-1) = real(txSigAll(:,symIdx));
end

%Paralel to serie and clocks
SignalTransmitted = reshape(ofdm_real, N*2*numOFDMSymbols, 1);  

    [f,c]=size(SignalTransmitted);
    
    %Guardamos la señal a transmitir junto con los clocks para los markers
    fich_name_I=['Signal_',num2str(M),'_QAM_ODFM_with_Clocks','.txt'];
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