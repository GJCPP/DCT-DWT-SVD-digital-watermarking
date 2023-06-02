function [LL1, HL1, LH1, HH1, LL2, HL2, LH2, HH2, LL3, HL3, LH3, HH3] = dwt2_3times(im)
    [LL1,HL1,LH1,HH1] = dwt2(im, 'Haar'); %可以用imshow看眼分别是什么玩意
    [LL2,HL2,LH2,HH2] = dwt2(LL1, 'Haar');
    [LL3,HL3,LH3,HH3] = dwt2(LL2, 'Haar');
    % imshow([[[LL3,HL3;LH3,HH3],HL2;LH2,HH2], HL1; LH1, HH1]);
end