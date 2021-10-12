% CLAHE Contrast-limited adaptive histogram equalization
%   K. Zuiderveld, "Contrast limited adaptive histograph equalization," 
%   in: P.S. Heckbert (Ed.), Graphic Gems IV, Academic Press, 
%   San Diego, USA, 1994, pp. 474-485.

function [J,Mapa] = clahe(I0,tiles,clip)
L = 256;        % Numero maximo de intensidades
% Detecta si la imagen es a color
if size(I0,3) > 1
    HSI = rgb2hsi(I0);
    I = round((L-1)*HSI(:,:,3)); % Solo extrae el canal I
else
    I = I0;
end
% Genera indices de cada elemento de la reticula
[Y,X] = size(I);% Tamano de la imagen
nx = tiles(1);  % Numero de regiones contextuales horizontales
ny = tiles(2);  % Numero de regiones contextuales verticales
I = double(I);
% Genera la reticula de regiones contextuales
sx = 1:fix(X/nx):X; sx(nx+1) = X;
sy = 1:fix(Y/ny):Y; sy(ny+1) = Y;
% Calcula las funciones de transformacion de cada region contextual
Mapa = zeros(ny,nx,L); % Aqui se guardaran las funciones de mapeo
for i = 1:nx
   for j = 1:ny
       K = I(sy(j):sy(j+1)-1,sx(i):sx(i+1)-1);  % Corta region contextual
       Hg = accumarray(K(:)+1,ones(numel(K),1),[L 1],@sum,0);  % Histograma de la region
       Hc = cliphistogram(Hg,clip); % Corta el histograma al clip
       Mapa(j,i,:) = (L-1)*cumsum(Hc/sum(Hc)); % Funcion de mapeo (distribucion acumulada) 
   end
end
% Interpolacion bilineal de regiones contextuales
J = interp_bilinear(I,Mapa,nx,ny);
% Detecta si la imagen de entrada es a color
if size(I0,3) > 1
    HSI(:,:,3) = J/(L-1);
    J = hsi2rgb(HSI);
else
    J = uint8(J);
end
%------------------------------------------------------------------------
function pk = cliphistogram(pk,clip)
Nc = round(clip*max(pk));
id = pk>=Nc;
Nu = sum(pk(id))-Nc*sum(id);
pk(id) = Nc;
pk(~id) = pk(~id)+(Nu/sum(~id));
%------------------------------------------------------------------------
function J = interp_bilinear(I,Mapa,nx,ny)
[Y,X] = size(I);
sx = fix(X/nx);
sy = fix(Y/ny);
J = zeros(Y,X);
xI = 1;
for i = 1:nx+1 % Para cada region de contextual horizontal
    if i == 1
        % Region inicial
        subX = fix(sx/2); % Inicializa centro de la region contextual
        xU = 1;
        xB = 1;
    elseif i == nx+1
        % Region final
        subX = X-xI+1;
        xU = nx;
        xB = nx;
    else
        % Region intermedia
        subX = sx;
        xU = i - 1;
        xB = i;
    end
    yI = 1;
    for j = 1:ny+1 % Para cada region de contextual vertical
        if j == 1
            % Region inicial
            subY = fix(sy/2); % Inicializa centro de la region contextual
            yL = 1;
            yR = 1;
        elseif j == ny+1
            % Region final
            subY = Y-yI+1;
            yL = ny;
            yR = ny;
        else
            % Region intermedia
            subY = sy;
            yL = j - 1;
            yR = j;
        end
        TA = Mapa(yL,xU,:); % Arriba-izquierda
        TB = Mapa(yL,xB,:); % Arriba-derecha
        TC = Mapa(yR,xU,:); % Abajo-izquierda
        TD = Mapa(yR,xB,:); % Abajo-derecha
        % Corta subregion delimitada por los centros de las regiones
        % contextuales
        K = I(yI:yI+subY-1,xI:xI+subX-1);
        % Interpolacion con las funciones adyacentes
        K = interpolation(K,TA,TB,TC,TD,subX,subY); 
        % Coloca la region contextual en su lugar
        J(yI:yI+subY-1,xI:xI+subX-1) = K;
        yI = yI + subY; % Avanza hacia el siguiente centro vertical
    end
    xI = xI + subX; % Avanza hacia el siguiente centro horizontal
end
%-----------------------------------------------------------------------
function I = interpolation(I,TA,TB,TC,TD,X,Y)
% Coordenadas normalizadas
x = (0:X-1)/(X-1); 
y = (0:Y-1)/(Y-1);
% Mapeo de cada pixel usando la informacion de las regiones adyacentes
for i = 1:Y
    for j = 1:X
        r = I(i,j)+1;
        I(i,j) = ((1 - y(i))*(((1 - x(j))*TA(r) + x(j)*TB(r))) + y(i)*((1 - x(j))*TC(r) + x(j)*TD(r)));
    end
end