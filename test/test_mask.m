function [res, wm, nc] = test_mask(N, M, im, expwm, S1, S2, UW, VW, k1, k2, rows, cols)
    % 尝试攻击，将图像指定行列抹成黑色
    im = im2double(im);
    im(rows, cols, :) = 0;
    imwrite(im, './test.jpg');
    im = imread('./test.jpg');
    res = im;
    [wm, nc] = extract_general_image(N, M, im, expwm, S1, S2, UW, VW, k1, k2);
end
