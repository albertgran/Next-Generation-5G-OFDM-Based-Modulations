

%GFDM Modulator

load('Struct.mat')

N = p.K*p.M;
L = p.Kon*p.M;
numBlocks = 10;

AttMax = 29; %máx atenuacion considerada
Att = 1:4:AttMax; %vector de attenuaciones
NumeroCapturas = 10; %numero de capturas de la trama para hacer media 

% We load the results of our experiment as well as the input data to
% compute the BER
load('InputData.mat')
load('SignalTransmitted.mat')

matrixBER = zeros(length(Att),NumeroCapturas);
matrixNumErrors = zeros(1,length(Att));
nameMatrixBERatt='matrixBER';

for m=1:length(Att)
    SignalRecibidaName=['SignalRecibida_Att_',num2str(Att(m))];
    load(SignalRecibidaName)
    for n=1:NumeroCapturas
        SignalRecibida=matrixSignalRecibida(n,:); 
                
                    %Convert from real to complex 
                    GFDM_real = reshape(SignalRecibida, N,2*numBlocks);  
                    GFDM_Complex = complex(zeros(N, numBlocks));
                    for block = 1:numBlocks
                            GFDM_Complex(:,(block)) = GFDM_real(:,(2*block)-1)+1i*GFDM_real(:,(2*block));
                    end
                    shm = zeros(L, numBlocks);

                    for block = 1:numBlocks
                            %Receiver zero forcing
                            a = do_demodulate(p, GFDM_Complex(:,(block)), 'ZF');
                            b = do_unmap(p, a);
                            shm(:,(block)) = do_qamdemodulate(b, p.mu);
                    end
                    % Measure BER with appropriate delay
                    BER = comm.ErrorRate;
                    ber = BER(inpData(:), shm(:));

                    % Display Bit error
                    disp(['GFDM Reception BER = ' num2str(ber(1)) ])

                    matrixNumErrors(m,n)= ber(2);
                    matrixBER(m,n)=ber(1);
                    %[matrixNumErrors(m,n), matrixBER(m,n)]=biterr(not(finalData),inputData);
    end
end
save(nameMatrixBERatt,'matrixBER')
