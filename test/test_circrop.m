function [res, wm, nc] = test_circrop(N, M, im, expwm, S1, S2, UW, VW, k1, k2)
    % 尝试攻击，将图像一周抹成黑色
    im = im2double(im2gray(im));
    sz = size(im);
    ci = [fix(sz(1)/2), fix(sz(2)/2), fix(sz(1)/2)];     % center and radius of circle ([c_row, c_col, r])
    [xx,yy] = ndgrid((1:sz(1))-ci(1),(1:sz(2))-ci(2));
    mask = double((xx.^2 + yy.^2)<ci(3)^2);
    im = im .* im2double(mask);
    %imshow(im);

    imwrite(im, './test.jpg');
    im = imread('./test.jpg');
    im = im2double(im2gray(im));
    res = im;
    im = im2double(imresize(im2gray(im), [N N]));
    [wm, nc] = extract_watermark(N, M, im, expwm, S1, S2, UW, VW, k1, k2);
end
