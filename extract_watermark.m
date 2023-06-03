function [extwm, nc] = extract_watermark(N, M, im, expwm, S1, S2, UW, VW, k1, k2)
    % 对原图像DCT + 三次DWT分解 + SVD
    %dct = @(block_struct) dct2(block_struct.data);
    %idct = @(block_struct) idct2(block_struct.data);
    %im = blockproc(im, [8 8], dct); 
    [LL1, HL1, LH1, HH1, LL2, HL2, LH2, HH2, LL3, HL3, LH3, HH3] = dwt2_3times(im);
    [U1, S1_NEW, V1] = svd(LL3);
    [U2, S2_NEW, V2] = svd(HH3);
    
    S1 = (S1_NEW - S1) / k1;
    S2 = (S2_NEW - S2) / k2;
    LLW1 = UW * S1 * VW';
    LLW2 = UW * S2 * VW';

    extwm1 = idwt2_2times([], [], [], LLW1, [], [], []);
    extwm2 = idwt2_2times([], [], [], LLW2, [], [], []);
    extwm1 = im2bw(extwm1);
    extwm2 = im2bw(extwm2);
    %extwm1 = blockproc(extwm1, [8 8], idct); 
    %extwm2 = blockproc(extwm2, [8 8], idct); 
    %extwm1 = igat(extwm1, M);
    %extwm2 = igat(extwm2, M);
    if similarity(extwm1, expwm) < similarity(1-extwm1, expwm)
        extwm1 = 1-extwm1;
    end
    if similarity(extwm2, expwm) < similarity(1-extwm2, expwm)
        extwm2 = 1-extwm2;
    end
    if similarity(expwm, extwm1) < similarity(expwm, extwm2)
        extwm = extwm2;
    else
        extwm = extwm1;
    end
    nc = similarity(extwm, expwm); %返回提取出的图片与原水印的相似度

    %imshow([extwm1, extwm2]);
end
