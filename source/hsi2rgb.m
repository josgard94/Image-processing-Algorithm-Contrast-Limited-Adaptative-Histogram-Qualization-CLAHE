function RGB = hsi2rgb(HSI)
HSI = double(HSI);
[M,N,~] = size(HSI);
% Canales de HSI
H = HSI(:,:,1); 
S = HSI(:,:,2); 
I = HSI(:,:,3);
% Sectores angulares del canal H
i1 = H<(2*pi/3);                % caso 1
i2 = H>=(2*pi/3) & H<(4*pi/3);  % caso 2
i3 = H>=(4*pi/3) & 2*pi;        % caso 3
H(i1) = H(i1);
H(i2) = H(i2) - (2*pi/3);
H(i3) = H(i3) - (4*pi/3);
% Canales intermedios
x = I.*(1-S);
y = I.*(1 + ((S.*cos(H))./cos(pi/3 - H)));
z = 3*I - (x + y);
% Conversion HSI->RGB
R = zeros(M,N);
G = zeros(M,N);
B = zeros(M,N);
% Caso 1:
B(i1) = x(i1);
R(i1) = y(i1);
G(i1) = z(i1);
% Caso 2:
B(i2) = z(i2);
R(i2) = x(i2);
G(i2) = y(i2);
% Caso 3:
B(i3) = y(i3);
R(i3) = z(i3);
G(i3) = x(i3);
% Salida
RGB = uint8(255*cat(3,R,G,B));