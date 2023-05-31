function [extwm1, extwm2] = extract_watermark(N, M, im, S1, S2, UW, VW, k1, k2)
    im = imresize(im2gray(im), [N N]);
    
    % 对原图像三次DWT分解 + SVD
    [LL1, HL1, LH1, HH1, LL2, HL2, LH2, HH2, LL3, HL3, LH3, HH3] = dwt2_3times(im);
    [U1, S1_NEW, V1] = svd(LL3);
    [U2, S2_NEW, V2] = svd(HH3);
    
    S1 = (S1_NEW - S1) / k1;
    S2 = (S2_NEW - S2) / k2;
    LLW1 = UW * S1 * VW';
    LLW2 = UW * S2 * VW';

    extwm1 = idwt2_2times([], [], [], LLW1, [], [], []);
    extwm2 = idwt2_2times([], [], [], LLW2, [], [], []);

    imshow([extwm1, extwm2]);
end
