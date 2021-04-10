clear all
close all
clc

emg=load('C:\Users\Shreyas\Documents\SEM 3 DOCS\ECE1018 EPJ\Biceps1.txt');
%emg=load('C:\Users\Shreyas\Documents\SEM 3 DOCS\ECE1018 EPJ\examples-of-electromyograms-1.0.0\emg_healthy.txt');
%emg=load('C:\Users\Shreyas\Documents\SEM 3 DOCS\ECE1018 EPJ\Emghealthy.txt');
t=emg(:,1);

plot(t,emg(:,2));
title('EMG Signal');
xlabel('Time');
ylabel('Amplitude');

%Filter
[B,A]=butter(5,1.25*20/500,'high');
abs_emg=abs(emg(:,2)-mean(emg(:,2)));
filt_emg=filtfilt(B,A,abs_emg);
%filt_emg=filtfilt(B,A,filt_emg);
%filt_emg=filtfilt(B,A,filt_emg);

%Plot of PSD of original signal
fs=200;
[Pxx,w]=pwelch(filt_emg,[],50,256,fs);
%[Pxx,w]=pwelch(filt_emg);
figure
plot(w,Pxx);
title('Original signal-PSD');
xlabel('Frequency');
ylabel('Power');

%Using notch filter
a=1;
b=[0.3821 0.236 0.3821];
figure
freqz(b,a);
title('Notch filter');
 
%Filtering signal according to normalised parameters
y=filter(b,a,filt_emg);
y=filter(b,a,y);
y=filter(b,a,y);
figure
plot(y)
title('Filtered signal');
xlabel('Time');
ylabel('Amplitude');
 
%Plot of PSD of filtered signal
r=pwelch(y,[],50,256,fs);
%r=pwelch(y);
figure
plot(r)
title('Filtered signal-PSD');
xlabel('Frequency');
ylabel('Power');


%Rectification
rec_emg=abs(y);
figure
plot(t,rec_emg);
title('Rectified EMG Signal');
xlabel('Time');
ylabel('Amplitude');

%RMS Envelope
%[B,A]=butter(4,.125*4/500,'low');
[B,A]=butter(4,8/500,'low');
rms_emg=filtfilt(B,A,rec_emg);
figure
plot(t,rms_emg,'r','linewidth',2);
title('RMS Envelope of EMG Signal');
xlabel('Time');
ylabel('Amplitude');

%Fourier Transform
N=length(emg(:,2));
freqs=0:1000/N:500;
xfft=fft(emg(:,2)-mean(emg(:,2)));
figure
plot(freqs,abs(xfft(1:N/2+1)));
xlabel('nq frequency');ylabel('amplitude spectrum')

%MAV
filter = ones(20,1);
filter = filter/length(filter);
 
MAV1 = zeros(length(y),1);
var1 = zeros(length(y),1);
MAV1 = conv(abs(real(y)),filter,'same');

% Theorectical Response and Adjusting
dt_r = 0.04;
t_response = [0:dt_r:35]';
response = zeros(size(t_response));
START = 5/dt_r;
dt_r2 = 2/dt_r;
dt_r5 = 5/dt_r;
response(START+1:START+dt_r2,1) = 1;
response(2*START+1:2*START+dt_r2,1) = 1;
response(3*START+1:3*START+dt_r2,1) = 1;
response(4*START+1:4*START+dt_r2,1) = 1;
response(5*START+1:5*START+dt_r2,1) = 1;
response(6*START+1:6*START+dt_r2,1) = 1;

%Plot of the Response
plot(t_response(:,1),response,'g--','linewidth',3);hold on;
xlabel('Time/s'); ylabel('Signal Amplitude'); title('Biceps 1'); grid on;
plot(emg(:,1),MAV1,'linewidth',2); 
plot(emg(:,1),real(y),'r');hold off;
legend('True response','MAV','EMG signal','Contract(Min); Relax (Max)', 'location', 'Northeast');
