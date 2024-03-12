clc
close all 
clear all

% Define the table of precomputed sinusoid samples 
tableSize =1024;           % Size of the lookup table
theta = linspace(0, 2*pi, tableSize+1);  % Phase values for one cycle

%Sinusoidal values for one cycle
table_samples = sin(theta);    

% % Triangular wave values for one cycle
% table_samples=zeros(tableSize+1,1);
% table_samples(1:tableSize/2)=-1+2*theta(1:tableSize/2)/pi;
% table_samples(tableSize/2+1:end)=3-2*theta(tableSize/2+1:end)/pi;

% % Square wave values for one cycle
% table_samples=zeros(tableSize+1,1);
% table_samples(1:floor(tableSize/2))=-1;
% table_samples(ceil(tableSize/2))=0;
% table_samples(ceil(tableSize/2)+1:end)=1;


figure(2)
plot(table_samples,'r')
grid on


Fs=44100;
target_frequency=261.37;
period = Fs/target_frequency;

% interp_theta2 = linspace(0, 2*pi, period);    %wrong
interp_theta2 = 0:2*pi/period:2*pi;             %should use this

step = interp_theta2(2)-interp_theta2(1);

shift=0;
T0=length(interp_theta2);
duration=20;
nPeriods=floor(duration*Fs/T0);
% t = 0:1/Fs:10; 
output2=zeros(duration*Fs,1);
% shift=table_samples(end)-interp_theta2(end);
count=0;

skippedSamples = floor((T0-period)*nPeriods);
additionalCycles = floor(skippedSamples/T0);
finalSamples = skippedSamples - (additionalCycles*T0);
finalCycles = 0;
 
% Concatenation of full periods
% for i=1:nPeriods+additionalCycles
i=1;
while i*T0-count<duration*Fs+T0
    output1(1+(i-1)*T0-count:i*T0-count) = interp1(theta,table_samples,interp_theta2-shift,"linear");
    output2(1+(i-1)*T0-count:i*T0-count) = interp1(theta,table_samples,interp_theta2-shift,"spline");
    if interp_theta2(end)-shift<2*pi
        gap=2*pi-interp_theta2(end)+shift;  
    else
        gap= 2*pi-interp_theta2(end)+shift+step;
        count=count+1;
        if i>nPeriods
            finalSamples=finalSamples+1;
            if finalSamples>T0
%                 finalCycles=finalCycles+1;
                finalSamples=finalSamples-T0;
            end
        end
    end
        shift=gap-step;
        i=i+1;
        disp(duration*Fs+count);
end


% Concatenation of the last incomplete period
fullPeriods=(i-1)*T0-count+1;
output1(fullPeriods:fullPeriods+finalSamples-1) = interp1(theta,table_samples,interp_theta2(1:finalSamples)-shift,"linear");
output2(fullPeriods:fullPeriods+finalSamples-1) = interp1(theta,table_samples,interp_theta2(1:finalSamples)-shift,"spline");

% figure(2)
% plot(theta,table_samples,'ro')
% grid on
% hold on
% plot(interp_theta2,output1,'g-')

x=linspace(101,70*101,70);

figure(3)
plot(output2,'b')
grid on
% hold on
% stem(x,output2(x),'r')
% xlim([Fs*2-401, Fs*2])

f=0:1/duration:Fs/2;
fft_1 = fft(output2);
P2 = abs(fft_1/duration/Fs);
P1 = P2(1:Fs*duration/2+1);
P1(2:end-1) = 2*P1(2:end-1);


figure(4)
plot(f,db(P1))
xlabel('Frequency [Hz]');
xlim([0,Fs/2])

soundsc(output2,Fs)