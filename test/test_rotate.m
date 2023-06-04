function [res, wm, nc] = test_rotate(N, M, im, expwm, S1, S2, UW, VW, k1, k2, angle)
    % 尝试攻击，将图像旋转指定角度
    im = im2double(imrotate(im, angle));
    imwrite(im, './test.jpg');
    im = imread('./test.jpg');
        % 将图片保存后再读取，因为保存为jpg会进行压缩，所以写后读回的东西可能不一样
    res = im;


    % 将图像摆正 + 取出中心部分 + 拉伸为原始大小
    % 如果想在实际场景中提取水印，可能有更好的做法、自动提取出与原图像最接近的图像，再提取水印吧
    im = imrotate(im, -angle);
    sz = size(im);
    if mod(angle, 90) ~= 0
        im = im(fix(sz(1)/2-N/2):1:fix(sz(1)/2+N/2), fix(sz(2)/2-N/2):1:fix(sz(2)/2+N/2), :);
    end
    im = imresize(im, [N N]);
    

    % 提取水印
    [wm, nc] = extract_general_image(N, M, im, expwm, S1, S2, UW, VW, k1, k2);
end
