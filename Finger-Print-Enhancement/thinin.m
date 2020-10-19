%% Thining
% Ridge thining is to eliminate the redundant pixels of ridges till the 
% ridges are just one pixel wide.  
K=bwmorph(~J,'thin','inf');
imshow(~K)
set(gcf,'position',[1 1 600 600]);