%% phase audio steaganography
clc
clear all;
close all;
% Load the audio file
[audio, fs] = audioread('cover.wav');

% Load the image to hide
[filename, pathname] = uigetfile('*.*', 'Select a Secret image');
image = imread(fullfile(pathname, filename));
image_gray = rgb2gray(image);
image_resized = imresize(image_gray, [1, numel(audio)]);

% Convert the image to binary
binary_image = reshape(dec2bin(image_resized), 1, []);

% Extract the phase information from the audio
nfft = 1024; % Set the FFT size
overlap_ratio = 0.75; % Set the overlap ratio
[~, phase, ~] = spectrogram(audio, hamming(nfft), round(overlap_ratio * nfft), nfft, fs);

% Embed the image data into the phase information
num_bits = length(binary_image);
bit_index = 1;

for i = 1:size(phase, 1)
    for j = 1:size(phase, 2)
        if bit_index <= num_bits
            % Embed one bit of the image into the phase
            phase(i, j) = embed_bit(phase(i, j), binary_image(bit_index));
            bit_index = bit_index + 1;
        else
            break;
        end
    end
    if bit_index > num_bits
        break;
    end
end

% Reconstruct the stego audio
stego_audio_spec = exp(1i * phase); % Reconstruct the modified spectrogram
stego_audio = ifft(stego_audio_spec, nfft, 'symmetric'); % Perform inverse FFT to reconstruct audio signal

% Save the stego audio
audiowrite('stego_audio_phase_steganography.wav', stego_audio, fs);
% Load the cover audio file
[cover_audio, fs_cover] = audioread('cover.wav');

% Load the stego audio file
[stego_audio, fs_stego] = audioread('stego_audio_phase_steganography.wav');

% Time vectors
t_cover = (0:length(cover_audio)-1) / fs_cover;
t_stego = (0:length(stego_audio)-1) / fs_stego;

% Plot cover audio waveform
figure;
subplot(2,1,1);
plot(t_cover, cover_audio);
title('Cover Audio');
xlabel('Time (s)');
ylabel('Amplitude');

% Plot stego audio waveform
subplot(2,1,2);
plot(t_stego, stego_audio);
title('Stego Audio');
xlabel('Time (s)');
ylabel('Amplitude');


%% for spectogram comparision
% Load the original audio file
[original_audio, fs_original] = audioread('cover.wav');

% Load the stego audio file
[stego_audio, fs_stego] = audioread('stego_audio_phase_steganography.wav');

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
title('Spectrogram of Stego phase Audio');
xlabel('Time (s)');
ylabel('Frequency (Hz)');


% Load the cover audio file
[cover_audio, fs_cover] = audioread('cover.wav');

% Load the stego audio file
[stego_audio, fs_stego] = audioread('stego_audio_phase_steganography.wav');

% Trim or pad the audio signals to make them equal in length
min_length = min(length(cover_audio), length(stego_audio));
cover_audio = cover_audio(1:min_length);
stego_audio = stego_audio(1:min_length);

% Calculate Signal-to-Noise Ratio (SNR)
original_audio_power = sum(cover_audio.^2);
noise_power = sum((stego_audio - cover_audio).^2);
SNR = 10 * log10(original_audio_power / noise_power);
fprintf('Signal-to-Noise Ratio (SNR): %.2f dB\n', SNR);

% Calculate Mean Squared Error (MSE)
MSE = mean((stego_audio - cover_audio).^2);
fprintf('Mean Squared Error (MSE): %.4f\n', MSE);

% Function to embed a single bit into the phase
function modified_phase = embed_bit(phase_value, bit)
    % Modify the phase value based on the bit to embed
    % Example: Adjust the phase value based on the bit (e.g., add or subtract a small amount)
    if bit == '0'
        modified_phase = phase_value - 0.1;
    else
        modified_phase = phase_value + 0.1;
    end
end
