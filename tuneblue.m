im2=imread(fullfile(pwd, 'images','x','R_S.png'));
im2 = im2double(im2);
im3=im2;
for i=1:1800
        for j=1:3200
            for k=1:3
                if(im2(i,j,1)<0.8)
                    im2(i,j,1)=0;
                    im2(i,j,2)=0;
                    im2(i,j,3)=0;
                    im3(i,j,1)=im2(i,j,1);
                    im3(i,j,2)=im2(i,j,2);
                    im3(i,j,3)=im2(i,j,3);
                
                end
            end
        end
end
figure, imshow(im3);
imwrite(im3,fullfile(pwd, 'images','x','R_S_fin.png'));