function [U1, V1, U2, V2, UW, VW, embimg] = embed_watermark(im, wm, k1, k2)
    % assume im = 512 x 512
    % assume wm = 256 x 256
    % assume both image are gray
    N = 512;
    M = 256;
    im = imresize(im2gray(im), [N N]);
    wm = imresize(im2bw(wm), [M M]);
    % imshow(wm);

    % 对原图像三次DWT分解
    [LL1, HL1, LH1, HH1, LL2, HL2, LH2, HH2, LL3, HL3, LH3, HH3] = dwt2_3times(im);
    % idwt2_3times(HL1, LH1, HH1, HL2, LH2, HH2, LL3, HL3, LH3, HH3); % 可以恢复出来看眼
    
    [U1, S1, V1] = svd(LL3);
    [U2, S2, V2] = svd(HH3);
    % 对水印图像两次DWT分解
    [LLW1, HLW1, LHW1, HHW1, LLW2, HLW2, LHW2, HHW2] = dwt2_2times(wm);
    [UW, SW, VW] = svd(LLW2);

    S1 = S1 + k1 * SW;
    S2 = S2 + k2 * SW;
    LL3 = U1 * S1 * V1';
    HH3 = U2 * S2 * V2';

    embimg = idwt2_3times(HL1, LH1, HH1, HL2, LH2, HH2, LL3, HL3, LH3, HH3);
    imshow(embimg);
    % imwrite(im, 'embeded_lena.jpg')
end

function [LL1, HL1, LH1, HH1, LL2, HL2, LH2, HH2, LL3, HL3, LH3, HH3] = dwt2_3times(im)
    [LL1,HL1,LH1,HH1] = dwt2(im2double(im), 'Haar'); %可以用imshow看眼分别是什么玩意
    [LL2,HL2,LH2,HH2] = dwt2(LL1, 'Haar');
    [LL3,HL3,LH3,HH3] = dwt2(LL2, 'Haar');
    % imshow([[[LL3,HL3;LH3,HH3],HL2;LH2,HH2], HL1; LH1, HH1]);
end

function im = idwt2_3times(HL1, LH1, HH1, HL2, LH2, HH2, LL3, HL3, LH3, HH3)
    LL2 = idwt2(LL3, HL3, LH3, HH3, 'Haar');
    LL1 = idwt2(LL2, HL2, LH2, HH2, 'Haar');
    im = idwt2(LL1, HL1, LH1, HH1, 'Haar');
    % imshow(im);
end

function [LLW1, HLW1, LHW1, HHW1, LLW2, HLW2, LHW2, HHW2] = dwt2_2times(im)
    [LLW1,HLW1,LHW1,HHW1] = dwt2(im2double(im), 'Haar'); %可以用imshow看眼分别是什么玩意
    [LLW2,HLW2,LHW2,HHW2] = dwt2(LLW1, 'Haar');
    imshow([[LLW2,HLW2;LHW2,HHW2], HLW1; LHW1, HHW1]);
end