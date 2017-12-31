%*************************************************************************
%------------------------- OOK RECEIVER ----------------------------------
%*************************************************************************

clear
clc

% Example configuration
length_PRBS = 2^16; %tamaño en bits del prbs

AttMax = 29; %máx atenuacion considerada
Att = 1:4:AttMax; %vector de attenuaciones
NumeroCapturas = 10; %numero de capturas de la trama para hacer media 

matrixBER = zeros(length(Att),NumeroCapturas);
matrixNumErrors = zeros(1,length(Att));
snr = zeros(length(Att),NumeroCapturas);
matrixEVM_RMS = zeros(length(Att),NumeroCapturas);
nameMatrixBERatt='matrixBER';
load('SignalTransmitted')
SignalTransmitted=double(SignalTransmitted.');

SignalAWG = zeros(1,length(SignalTransmitted));
for s=1:length(SignalTransmitted)
    if SignalTransmitted(s) == 1
        SignalAWG(s) = 0.25;
    else 
        SignalAWG(s) = -0.25;
    end
end
PotSignalAWG = (norm(SignalAWG)^2)/length(SignalAWG);

for m=1:length(Att)
    SignalRecibidaName=['SignalRecibida_Att_',num2str(Att(m))];
    load(SignalRecibidaName)
    for n=1:NumeroCapturas
        SignalRecibida=matrixSignalRecibida(n,:); 
        PotSignalRecibida = (norm(SignalRecibida)^2)/length(SignalRecibida);
        
        factor_pot = sqrt(PotSignalAWG/PotSignalRecibida);
        signalRx = SignalRecibida*factor_pot;

        % Modulacion PAM: Demodulamos los simbolos para tener su valor decimal
        r2= pamdemod(signalRx,2);
        
        %Pasamos los simbolos de decimal a binario: k bits por simbolo
        u2=de2bi(r2);
        finalData = reshape(u2,length_PRBS,1)';  
        
        %Calcular BER y otras medidas: Comparar finalData con inputData etc
        [matrixNumErrors(m,n), matrixBER(m,n)]=biterr(SignalTransmitted,finalData);
        
%        evm = lteEVM(SignalTransmitted,finalData);
%        [matrixEVM_RMS(m,n)] = (evm.RMS*100);
        
        %Calcular EbN0 para señal
        ruido = SignalAWG-signalRx;
        pot_ruido = (norm(ruido)^2)/length(ruido);
        [snr(m,n)]=10*log10(PotSignalAWG/pot_ruido);
    end
end

%Plot BER 
ber_avg = zeros(length(Att),1);
evm_avg = zeros(length(Att),1);
snr_avg = zeros(length(Att),1);
for i=1:length(Att)
    ber_avg(i)= mean(matrixBER(i,:));
    evm_avg(i)= mean(matrixEVM_RMS(i,:));
    snr_avg(i)= mean(snr(i,:));
end

figure(1)
semilogy(snr_avg, ber_avg,'b-');
title('2PAM Experimental BER'); 
legend('Experimental BER');
xlabel('SNR(dB)'); 
grid on;

figure(2)
semilogy(snr_avg,evm_avg,'r-');
title('2PAM Experimental EVM'); 
legend('Experimental EVM-RMS');
xlabel('SNR(dB)'); 
grid on;

save(nameMatrixBERatt,'matrixBER')

