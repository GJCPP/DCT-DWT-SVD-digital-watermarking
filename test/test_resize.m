function [res, wm, nc] = test_resize(N, M, im, expwm, S1, S2, UW, VW, k1, k2, newsz)
    % 尝试攻击，将图像放缩到指定大小
    im = im2double(imresize(im2gray(im), [newsz newsz]));
    imwrite(im, './test.jpg');
    im = imread('./test.jpg');
    im = im2double(im2gray(im));
    res = im;
    im = im2double(imresize(im2gray(im), [N N]));
    [wm, nc] = extract_watermark(N, M, im, expwm, S1, S2, UW, VW, k1, k2);
end
