function [S1, S2, UW, VW, embimg] = embed_general_image(N, M, im, wm, k1, k2)
    sz = size(im);
    im = im2double(imresize(im, [N N]));
    wm = im2double(imresize(im2bw(wm), [M M]));
        % 强制把大小转换为方 + 转为double类型
    im = rgb2ycbcr(im);
    [S1, S2, UW, VW, embimg] = embed_watermark(N, M, im(:,:,1), wm, k1, k2);
        % 只将YUV的亮度分量传入embed_watermark进行嵌入
    im(:,:,1) = embimg;
    embimg = im;
    embimg = ycbcr2rgb(embimg);
    embimg = imresize(embimg, sz([1 2]));
        % 默认外部传入的还是rgb图像吧
end
