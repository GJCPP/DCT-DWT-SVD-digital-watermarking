function [res, wm, nc] = test_crop(N, M, im, expwm, S1, S2, UW, VW, k1, k2, rows, cols)
    im = im2double(im2gray(im));
    im = im(rows, cols);
    imwrite(im, './test.jpg');
    im = imread('./test.jpg');
    im = im2double(im2gray(im));
    res = im;
    im = im2double(imresize(im2gray(im), [N N]));
    [wm, nc] = extract_watermark(N, M, im, expwm, S1, S2, UW, VW, k1, k2);
end
