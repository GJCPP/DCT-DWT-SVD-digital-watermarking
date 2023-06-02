function [modified_im] = igat(im, M)
    modified_im = im;
    for i = 1:M
        for j = 1:M
            x = mod(2*(i-1) - (j-1) + M, M) + 1;
            y = mod(-(i-1) + (j-1) + M, M) + 1;
            modified_im(x,y) = im(i,j);
        end
    end
end
