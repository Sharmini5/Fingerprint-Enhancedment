%% Binarize
% We binarize the image. After the operation, ridges in the fingerprint are
% highlighted with black color while furrow are white.
J=I(:,:,1)>160;
imshow(J)
set(gcf,'position',[1 1 600 600]);
