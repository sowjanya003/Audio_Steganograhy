%% Echo Hiding Audio Steganography
clc
clear all;
close all;
% Load the audio file
[audio, fs] = audioread('cover.wav');

% % Load the image to hide
% image = imread('2.jpg');
[filename, Pathname] = uigetfile('*.*','Select a Secret image');
image = imread(fullfile(Pathname, filename));
figure(1),imshow(image),title('Secret image')
% Convert the image to grayscale
image_gray = rgb2gray(image);

% Resize the image to match the length of the audio
num_samples_audio = length(audio);
num_pixels_image = numel(image_gray);
image_resized = imresize(image_gray, [1, num_samples_audio]);

% Normalize the image data to the range [0, 1]
image_resized = double(image_resized) / 255;

% Generate key for embedding (here we use a simple sequence, you can use a more complex one)
key = randi([1, 10], 1, num_samples_audio);

% Embed the image into the audio by adding echoes
alpha = 1; % Embedding strength
audio_stego = audio;
for i = 1:num_samples_audio
    delay = key(i); % Delay for the echo
    if (i + delay) <= num_samples_audio
        % Check if clipping will occur, and scale down if necessary
        if abs(audio_stego(i + delay) + alpha * image_resized(i)) > 1
            alpha_scaled = (1 - abs(audio_stego(i + delay))) / abs(image_resized(i));
            audio_stego(i + delay) = audio_stego(i + delay) + alpha_scaled * alpha * image_resized(i);
        else
            audio_stego(i + delay) = audio_stego(i + delay) + alpha * image_resized(i);
        end
    end
end

% Save the stego audio
audiowrite('stego_audio_echo_hiding.wav', audio_stego, fs);

% Performance Metrics

% Calculate Signal-to-Noise Ratio (SNR)
original_power = sum(audio.^2);
noise_power = sum((audio_stego - audio).^2);
SNR = 10 * log10(original_power / noise_power);
fprintf('Signal-to-Noise Ratio (SNR): %.2f dB\n', SNR);

% Calculate Mean Squared Error (MSE)
MSE = mean((audio_stego - audio).^2);
fprintf('Mean Squared Error (MSE): %.4f\n', MSE);

% Calculate Capacity (bits per sample)
capacity = (num_samples_audio - sum(key < 0)) * log2(10); % Assuming key values range from 1 to 10
fprintf('Capacity (bits per sample): %.2f\n', capacity);

% Assess Robustness (e.g., by subjecting stego audio to compression, filtering, noise addition, etc.)
% For simplicity, let's assess the effect of compression
compressed_audio_stego = audioread('stego_audio_echo_hiding.wav'); % Read the stego audio again after compression
compression_MSE = mean((compressed_audio_stego - audio_stego).^2);
fprintf('MSE after compression: %.4f\n', compression_MSE);

% Assess Security (e.g., analyze statistical properties of stego audio)
% For simplicity, let's
% Check if stego audio has any statistical anomalies
mean_stego = mean(audio_stego);
std_stego = std(audio_stego);
anomalies = sum((audio_stego - mean_stego) > 3 * std_stego); % Count number of samples deviating by more than 3 standard deviations
fprintf('Number of anomalies in stego audio: %d\n', anomalies);

%% for spectogram comparision
% Load the original audio file
[original_audio, fs_original] = audioread('cover.wav');

% Load the stego audio file
[stego_audio, fs_stego] = audioread('stego_audio_echo_hiding.wav');

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