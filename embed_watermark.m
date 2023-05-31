function [S1, S2, UW, VW, embimg] = embed_watermark(N, M, im, wm, k1, k2)

    % assume both image are gray
    im = imresize(im2gray(im), [N N]);
    wm = imresize(im2bw(wm), [M M]);
    % imshow(wm);

    % 对原图像三次DWT分解 + SVD
    [LL1, HL1, LH1, HH1, LL2, HL2, LH2, HH2, LL3, HL3, LH3, HH3] = dwt2_3times(im);
    [U1, S1, V1] = svd(LL3);
    [U2, S2, V2] = svd(HH3);
    % idwt2_3times(HL1, LH1, HH1, HL2, LH2, HH2, LL3, HL3, LH3, HH3); % 可以恢复出来看眼


    % 对水印图像两次DWT分解 + SVD
    [LLW1, HLW1, LHW1, HHW1, LLW2, HLW2, LHW2, HHW2] = dwt2_2times(wm);
    [UW, SW, VW] = svd(LLW2);

    
    % 执行嵌入
    S1_NEW = S1 + k1 * SW;
    S2_NEW = S2 + k2 * SW;
    LL3 = U1 * S1_NEW * V1';
    HH3 = U2 * S2_NEW * V2';

    embimg = idwt2_3times(HL1, LH1, HH1, HL2, LH2, HH2, LL3, HL3, LH3, HH3);
    % imshow(embimg);
end

