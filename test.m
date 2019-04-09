% read the image into MATLAB and convert it to grayscale
I = imread('test.jpg');
Igray = rgb2gray(I);
figure, imshow(I);
% We can see that the image is noisy. We will clean it up with a few
% morphological operations
Ibw = im2bw(Igray,graythresh(Igray)); 
se = strel('line',3,90);
cleanI = imdilate(~Ibw,se);
figure, imshow(cleanI);
% Perform a Hough Transform on the image 
% The Hough Transform identifies lines in an image 
[H,theta,rho] = hough(cleanI);
peaks  = houghpeaks(H,10);
lines = houghlines(Ibw,theta,rho,peaks);
figure, imshow(cleanI)
% Highlight (by changing color) the lines found by MATLAB
hold on
for k = 1:numel(lines)
    x1 = lines(k).point1(1);
    y1 = lines(k).point1(2);
    x2 = lines(k).point2(1);
    y2 = lines(k).point2(2);
    plot([x1 x2],[y1 y2],'Color','g','LineWidth', 2)
end
hold off
% Identify the angles of the lines. 
% The following command shows the angle of the 2nd line found by the Hough
% Transform
lines(1).theta
lines(2).theta