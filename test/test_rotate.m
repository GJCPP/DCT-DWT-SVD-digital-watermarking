function [res, wm, nc] = test_rotate(N, M, im, expwm, S1, S2, UW, VW, k1, k2, angle)
    im = im2double(imrotate(im2gray(im), angle));
    imwrite(im, './test.jpg');
    im = imread('./test.jpg');
    im = im2double(im2gray(im));
        % 将图片保存后再读取，因为保存为jpg会进行压缩，所以写后读回的东西可能不一样
    res = im;

    % 将图像摆正+中心取出
    im = im2double(im2gray(im));
    im = imrotate(im2gray(im), -angle);
    sz = size(im);
    if mod(angle, 90) ~= 0
        im = im(fix(sz(1)/2-N/2):1:fix(sz(1)/2+N/2), fix(sz(2)/2-N/2):1:fix(sz(2)/2+N/2));
    end
    im = imresize(im, [N N]);
    %t = size(im, 1);

    [wm, nc] = extract_watermark(N, M, im, expwm, S1, S2, UW, VW, k1, k2);
end
