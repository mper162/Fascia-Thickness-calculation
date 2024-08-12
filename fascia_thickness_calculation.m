% This script calculates fascia thickness in segmented thigh and calf areas. 
% It takes sample main files and segmentations as inputs, processing them to provide 
%thickness measurements and visualizations."

%Please note that input to the script is : calf_segmentation.nii.gz
%thigh/calf_segmentation_full files are  used to calculate volumes of fascia,  muscle and bone.
% thigh/calf main files are the main image files  while the remaining NIfTI files are manually segmented masks


% author -Randika Perera 

clc; clear all;

% Read the NIfTI files
img2 = niftiread('Thigh_fascia_Segmentation.nii.gz');
%img2 = niftiread('calf_segmentation.nii.gz');


% Display the NIfTI images
figure;
subplot(1, 2, 1);
imshow(img2(:,:,round(size(img2, 3)/2)), []);  % Display middle slice of Post image
title('Fascia Segmentation');


% first step to normalize to find the depth
Imax2 = max(img2,[],'all');
%Imin2 = min(img2,[],'all');

Imax = max(img2,[],'all');
Imin = min(img2,[],'all');

% Normalize 0-1
Iprime = (img2-Imin)./(Imax-Imin); 
dim = size(Iprime);


% fascia thickness calculation
for i = 1:95% for thigh
%for i = 1:80 % for calf
    horizontal = reshape(Iprime(:,:,i),[dim(1),dim(2)]); 
    bw = horizontal;

    % Find the thickness*******************************************
    K = bwdist(~bw);
    L1 = bwmorph(bw, 'skel', inf);
    radiiValues = K.*L1;    
    diameterValue = 2*(4/10) * radiiValues; % Spatial resolution = 0.4*0.4mm

    A = transpose(diameterValue);
    
    % Only getting non-zero elements to calculate mean 
    mask = A ~= 0;
    zz = A(mask);

    numZeros = 50000 - size(zz, 1); % Calculate the number of zeros to add
    zz(end+1:end+numZeros, 1) = 0; % Add the zeros
    
    bbb(:,i) = zz;
    mean_nonzero(i) = mean(nonzeros(bbb(:,i)),'all');
end 

% fascia mean thickness
mean_pre_kyla = nanmean(mean_nonzero);


% Display the histograms
figure;
hFig = gcf;
set(hFig, 'color', 'w');
histogram(mean_nonzero, 'FaceColor', 'r', 'BinWidth', 0.02);
hold on;
%histogram(mean_nonzero2, 'FaceColor', 'b', 'BinWidth', 0.02);

% Display percentage difference
disp(['Fascia Thickness: ', num2str(mean_pre_kyla) 'mm']);
