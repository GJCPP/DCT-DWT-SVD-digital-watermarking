function [extwm, nc] = extract_general_image(N, M, im, expwm, S1, S2, UW, VW, k1, k2)
    im = im2double(imresize(im, [N N])); %转为灰度图 + 强制把大小转换为N*N + 转为double类型
    expwm = im2double(imresize(im2bw(expwm), [M M]));
    im = rgb2ycbcr(im);
    [extwm, nc] = extract_watermark(N, M, im(:,:,1), expwm, S1, S2, UW, VW, k1, k2);
        % 只将YUV的亮度分量传入extract_watermark进行提取
end
