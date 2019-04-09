image=imread('PB230058.jpg');
Red = image(:,:,1);
    Green = image(:,:,2);
    Blue = image(:,:,3);
    %Get histValues for each channel
    [yRed, x] = imhist(Red);
    [yGreen, x] = imhist(Green);
    [yBlue, x] = imhist(Blue);
    %Plot them together in one plot
    plot(x, yRed, 'Red', x, yGreen, 'Green', x, yBlue, 'Blue')
    xlim([0 255]); 
    grid on
    hold on;