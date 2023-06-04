function [res, wm, nc] = test_resize(N, M, im, expwm, S1, S2, UW, VW, k1, k2, newsz)
    % 尝试攻击，将图像放缩到指定大小
    im = imresize(im, [newsz newsz]);
    imwrite(im, './test.jpg');
    im = imread('./test.jpg');
    res = im;
    [wm, nc] = extract_general_image(N, M, im, expwm, S1, S2, UW, VW, k1, k2);
end
