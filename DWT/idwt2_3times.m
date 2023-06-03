function im = idwt2_3times(HL1, LH1, HH1, HL2, LH2, HH2, LL3, HL3, LH3, HH3)
    LL2 = idwt2(LL3, HL3, LH3, HH3, 'Haar');
    LL1 = idwt2(LL2, HL2, LH2, HH2, 'Haar');
    im = idwt2(LL1, HL1, LH1, HH1, 'Haar');
    im = im2double(im);
    % imshow(im);
end