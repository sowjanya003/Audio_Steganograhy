% Adaptive Audio Steganography 
clc
clear all;
close all;
[audio, fs] = audioread('cover.wav');
% Load the image to hide
[filename, Pathname] = uigetfile('*.*','Select a Secret image');
image = imread(fullfile(Pathname, filename));
figure(1),imshow(image),title('Secret image')
image_gray = rgb2gray(image);
image_binary = imbinarize(image_gray);
% Normalize image data
image_binary = double(image_binary);
% Define embedding strength
alpha = 0.1;
% Define window size for feature extraction
window_size = 1024;
% Initialize stego audio
audio_stego = audio;
% Iterate over audio signal in windows
for i = 1:window_size:length(audio)
    % Extract feature (example: mean amplitude in window)
    window = audio(i:min(i+window_size-1, length(audio)));
    feature = mean(abs(window));
    % Adjust embedding strength based on feature
    adjusted_alpha = alpha * feature;
    % Embed bits of image into current window
    for j = 1:length(window)
        if j <= length(image_binary)
            % Embed image bit using adjusted alpha
            audio_stego(i+j-1) = audio_stego(i+j-1) + adjusted_alpha * image_binary(j);
        else
            break; % Stop if end of image bits reached
        end
    end
end
% Save stego audio
audiowrite('stego_audio_adaptive1.wav', audio_stego, fs);
% Load the stego audio file
[audio_stego, ~] = audioread('stego_audio_adaptive1.wav');

% Calculate Signal-to-Noise Ratio (SNR)
original_audio_power = sum(audio.^2);
noise_power = sum((audio_stego - audio).^2);
SNR = 10 * log10(original_audio_power / noise_power);
fprintf('Signal-to-Noise Ratio (SNR): %.2f dB\n', SNR);

% Calculate Mean Squared Error (MSE)
MSE = mean((audio_stego - audio).^2);
fprintf('Mean Squared Error (MSE): %.4f\n', MSE);





%% for spectogram comparision
% Load the original audio file
[original_audio, fs_original] = audioread('cover.wav');

% Load the stego audio file
[stego_audio, fs_stego] = audioread('stego_audio_adaptive1.wav');

% Create spectrograms for original audio and stego audio
figure(2);

% Spectrogram of original audio
subplot(2,1,1);
window_size_original = 1024;
overlap_ratio_original = 0.75;
nfft_original = 1024;
spectrogram(original_audio, window_size_original, round(overlap_ratio_original * window_size_original), nfft_original, fs_original, 'yaxis');
title('Spectrogram of Original Audio');
xlabel('Time (s)');
ylabel('Frequency (Hz)');

% Spectrogram of stego audio
subplot(2,1,2);
window_size_stego = 1024;
overlap_ratio_stego = 0.75;
nfft_stego = 1024;
spectrogram(stego_audio, window_size_stego, round(overlap_ratio_stego * window_size_stego), nfft_stego, fs_stego, 'yaxis');
title('Spectrogram of Stego Audio');
xlabel('Time (s)');
ylabel('Frequency (Hz)');