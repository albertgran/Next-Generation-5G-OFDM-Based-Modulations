addpath(genpath('C:\Users\Albert\Desktop\MET-UPC\INTRODUCTION TO RESEARCH\AutoLab')) 
clear;
close;

Att=29;%poner aquí la atenuación que se está midiedo
NumeroCapturas=10;
load('SignalTransmitted')
matrixSignalRecibida=zeros(NumeroCapturas,length(SignalTransmitted));
matrixSignalRecibidaName=['SignalRecibida_Att_',num2str(Att)];
handler=DPO7254_inicializar();%solo para capturar CH-1

for i=1:NumeroCapturas
    YDATA = DPO7254_capturar_trama(handler);
    
    % Para capturar dos channels, datos y reloj, no queda sincronizado bien del todo, así que no usar
    % YDATA = DPO7254_capturar_trama2(DPO7254_handler,1)
    % fprintf(handler,'ACQUIRE:STOPAFTER SEQUENCE')
    % fprintf(handler,'ACQUIRE:STATE ON')
    % YMARKER = DPO7254_capturar_trama2(handler,4);

    %resampled=resample(YDATA,4,1);% Recibimos a 25GS/s. Para tener las mismas muestras que la señal transmitida por Matlab en el transmisor, subimos a 100GS/s y parseamos cada 25. Así tenemos 4GS/s que es equivalente a transmitir con 8GS/s una señal transmitida con resampling de 2. 
    resampled=resample(YDATA,2,1);%estamos en 2 gsamples en awg
    y_opt=zeros(1,25);
    for k=1:25
        y_opt(k)=sum(abs(resampled(k:25:end)).^2);
    end
    [nul,index]=max(y_opt);
    resampled=resampled(index:25:end);

    correlation=abs(xcorr(SignalTransmitted,resampled));
    plot(correlation)
    index_Max=find(correlation==max(correlation));
    initial_pos_patron=length(resampled)-index_Max+1;
    SignalRecibida=resampled(initial_pos_patron:initial_pos_patron+length(SignalTransmitted)-1).';
    
    matrixSignalRecibida(i,:)=SignalRecibida;
%     figure
%     plot(SignalRecibida(end-100:end));
%     figure
%     plot(SignalTransmitted(end-100:end));
   
end
 save(matrixSignalRecibidaName,'matrixSignalRecibida')
