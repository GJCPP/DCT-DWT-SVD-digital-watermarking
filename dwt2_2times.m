function [LLW1, HLW1, LHW1, HHW1, LLW2, HLW2, LHW2, HHW2] = dwt2_2times(im)
    [LLW1,HLW1,LHW1,HHW1] = dwt2(im2double(im), 'Haar'); %可以用imshow看眼分别是什么玩意
    [LLW2,HLW2,LHW2,HHW2] = dwt2(LLW1, 'Haar');
    % imshow([[LLW2,HLW2;LHW2,HHW2], HLW1; LHW1, HHW1]);
end