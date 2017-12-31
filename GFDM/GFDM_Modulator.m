%GFDM Modulator

p = struct;

 p.K = 1024;             %   K:              Number of samples per sub-symbol
 p.Kon = 600;           %   Kon:            Number allocated subcarriers
 p.M = 15;                %   M:              Number of sub-symbols
 p.Ncp = 0;              %   Ncp:            Number of cyclic prefix samples
 p.Ncs = 0;              %   Ncs:            Number of cyclic suffix samples
 p.window = 'rc';        %   window:         window that multiplies the GFDM block with CP
 p.b = 0;                %   b:              window factor (rolloff of the window in samples)
 p.overlap_blocks = 0 ;  %   overlap_blocks: overlaped blocks (number of overlaped edge samples)
 p.matched_window = 0 ;  %   matched_window: matched windowing (root raised windowing in AWGN)
% % Always use a RRC filter with rolloff 0.5 (if not otherwise stated)
 p.pulse = 'rrc';        %   pulse:          Pulse shaping filter
 p.sigmaN = 0;           %   sigmaN:         noise variance information for MMSE receiver
 p.a = 0.5;              %   a:              rolloff of the pulse shaping filter
 p.L = 2;                %   L:              Number of overlapping subcarriers
 p.mu = 2;               %   mu:             Modulation order (number of bits in the QAM symbol)
 p.oQAM = 0;             %   oQAM:           offset QAM Modulation/Demodulation
 p.B = 1;                %   B:              number of concatenated GFDM blocks
%p=get_defaultGFDM('TTI');
%S'ha d'anar amb compte, sino depen de quina configuracio de p agafis et
%dona error el zero forcing

N = p.K*p.M;
L = p.Kon*p.M;
numBlocks = 10;
GFDM_Complex = complex(zeros(N,numBlocks));
inpData = zeros(L, numBlocks);
for block = 1:numBlocks
    % create symbols
    inpData(:,block) = get_random_symbols(p);

    % map them to qam and to the D matrix
    D = do_map(p, do_qammodulate(inpData(:,block), p.mu)); %Les dimensions de la matriu seran NK,CC
    GFDM_Complex(:,block) = do_modulate(p, D);
end


GFDM_real = zeros(N,2*numBlocks);
for block = 1:numBlocks
        GFDM_real(:,(block*2)) = imag(GFDM_Complex(:,block));
        GFDM_real(:,(block*2)-1) = real(GFDM_Complex(:,block));
end

%Paralel to serie and clocks
SignalTransmitted = reshape(GFDM_real, N*2*numBlocks, 1);  

    [f,c]=size(SignalTransmitted);
    
    %Guardamos la señal a transmitir junto con los clocks para los markers
    fich_name_I=['Signal_GFDM_with_Clocks','.txt'];
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
save('Struct.mat','p')
