function im = idwt2_2times(HL1, LH1, HH1, LL2, HL2, LH2, HH2)
    LL1 = idwt2(LL2, HL2, LH2, HH2, 'Haar');
    im = idwt2(LL1, HL1, LH1, HH1, 'Haar');
    % imshow(im);
end