function [S1, S2, UW, VW, embimg] = embed_watermark(N, M, im, wm, k1, k2)
    % 对原图像DCT + 三次DWT分解 + SVD
    %dct = @(block_struct) dct2(block_struct.data);
    %idct = @(block_struct) idct2(block_struct.data);
    %im = blockproc(im, [8 8], dct); 
        % 将图像分为若干8x8的块进行离散余弦变换DCT
        % 8x8是一个比较常用的数值，比如JPG的压缩使用的就是8x8
    [LL1, HL1, LH1, HH1, LL2, HL2, LH2, HH2, LL3, HL3, LH3, HH3] = dwt2_3times(im);
        % 做三次离散小波变换DWT，具体这12个矩阵是什么可以参考论文里的流程图
    [U1, S1, V1] = svd(LL3);
    [U2, S2, V2] = svd(HH3);
    % idwt2_3times(HL1, LH1, HH1, HL2, LH2, HH2, LL3, HL3, LH3, HH3); % 可以恢复出来看眼


    % 对水印图像DCT + 两次DWT分解 + SVD
    %wm = gat(wm, M);

    %wm = igat(wm, 7, 13, M);
    %wm = blockproc(wm, [8 8], dct);
    %wm = blockproc(wm, [8 8], idct);
    [LLW1, HLW1, LHW1, HHW1, LLW2, HLW2, LHW2, HHW2] = dwt2_2times(wm);
    [UW, SW, VW] = svd(LLW2);

    
    % 执行嵌入
    S1_NEW = S1 + k1 * SW;
    S2_NEW = S2 + k2 * SW;
    LL3 = U1 * S1_NEW * V1';
    HH3 = U2 * S2_NEW * V2';

    embimg = idwt2_3times(HL1, LH1, HH1, HL2, LH2, HH2, LL3, HL3, LH3, HH3);
    %embimg = blockproc(embimg, [8 8], idct); 
    %imshow(embimg);
end

