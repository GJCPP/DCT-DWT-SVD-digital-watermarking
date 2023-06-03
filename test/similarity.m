function sim = similarity(im1, im2)
    % 用来比较两个图像的相似度
    sim = log(corr2(im1, im2)+1);
    %im1 = im2double(im1);
    %sim = normxcorr2(imnoise(im1, 'gaussian'), im2);
    %sim = max(sim(:));
end
