function [res, wm, nc] = test_crop(N, M, im, expwm, S1, S2, UW, VW, k1, k2, rows, cols)
    % 尝试攻击，将图像截取出指定行列
    im = im2double(im);
    im = im(rows, cols, :);
    imwrite(im, './test.jpg');
    im = imread('./test.jpg');
    res = im;
    [wm, nc] = extract_general_image(N, M, im, expwm, S1, S2, UW, VW, k1, k2);
end
