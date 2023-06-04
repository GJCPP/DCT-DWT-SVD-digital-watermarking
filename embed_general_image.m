function [S1, S2, UW, VW, embimg] = embed_general_image(N, M, im, wm, k1, k2)
    sz = size(im);
    im = im2double(imresize(im, [N N])); % 强制把大小转换为N*N + 转为double类型
    wm = im2double(imresize(im2bw(wm), [M M]));
    im = rgb2ycbcr(im);
    [S1, S2, UW, VW, embimg] = embed_watermark(N, M, im(:,:,1), wm, k1, k2);
    im(:,:,1) = embimg;
    embimg = im;
    embimg = ycbcr2rgb(embimg);
    embimg = imresize(embimg, sz([1 2]));
        % 默认外部传入的还是rgb图像吧
end
