function [modified_im] = gat(im, M)
    modified_im = im;
    for i = 1:M
        for j = 1:M
            x = mod((i-1) + (j-1), M) + 1;
            y = mod((i-1) + 2*(j-1), M) + 1;
            modified_im(x,y) = im(i,j);
        end
    end
end
