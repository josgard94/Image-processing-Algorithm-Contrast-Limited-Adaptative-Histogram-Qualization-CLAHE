clearvars; close all; clc;

I1 = imread('../images/hotel.tif');
J1 = clahe(I1,[3 2],0.4);

I2 = imread('../images/bridge.tif');
J2 = clahe(I2,[2 2],0.3);

I3 = imread('../images/einstein.tif');
J3 = clahe(I3,[3 3],0.2);

I4 = imread('../images/seeds1.tif');
J4 = clahe(I4,[3 3],0.1);

figure;
subplot 241; imshow(I1);
subplot 242; imshow(I2);
subplot 243; imshow(I3);
subplot 244; imshow(I4);

subplot 245; imshow(J1);
subplot 246; imshow(J2);
subplot 247; imshow(J3);
subplot 248; imshow(J4);