function HSI = rgb2hsi(RGB)
I0 = double(RGB);
% RGB normalizado
RGB = bsxfun(@rdivide,I0,sum(I0,3));
% Canales de color
R = RGB(:,:,1); 
G = RGB(:,:,2); 
B = RGB(:,:,3);
% Conversion RGB->HSI
H  = acos((0.5*((R-G)+(R-B)))./(sqrt((R-G).^2 + (R-B).*(G-B))+eps));
H(B>G) = 2*pi-H(B>G);
S  = 1 - 3.*min(RGB,[],3);
I  = sum(I0,3)/(3*255);
HSI = cat(3,H,S,I);