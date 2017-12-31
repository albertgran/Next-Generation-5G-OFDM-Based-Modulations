%*************************************************************************
%------------------------- OOK TRANSMITTER ------------------------------
%************************************************************************* 

clear;
close;

% Example configuration
length_PRBS = 2^16; 

    % Secuencia de datos a codificar: PRBS or randomSource
            %PRBS generation
                inputData = double(ltePRBS(length_PRBS,length_PRBS));    
            %Random sequence
                %inputData = randsrc(length_PRBS, 1, [1,0]);
    scatterplot(inputData);
    
%--Generación de .txt de componentes I & Q por separado--
SignalTransmitted=inputData;%señal electrica en banda base
save('SignalTransmitted','SignalTransmitted')

[f,c]=size(SignalTransmitted);

fich_name_I=['Signal_OOK_with_Clocks','.txt'];
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