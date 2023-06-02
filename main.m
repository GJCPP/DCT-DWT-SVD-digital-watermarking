function main
    N = 512;
    M = 256;
    k1 = diag(0.05*ones(1,M/4));
    k2 = diag(0.025*ones(1,M/4));
    

    im = imread('./image/lena.jpg');
    wm = imread('./image/watermark.jpg');
    im = im2double(imresize(im2gray(im), [N N]));
    wm = im2double(imresize(im2bw(wm), [M M]));
    
    [S1, S2, UW, VW, embimg] = embed_watermark(N, M, im, ...
                                            wm, k1, k2);
    imwrite(embimg, './image/embeded_lena.jpg');
    embimg = imread('./image/embeded_lena.jpg');
    embimg = im2double(imresize(im2gray(embimg), [N N]));
    extwm = extract_watermark(N, M, embimg, wm, S1, S2, UW, VW, k1, k2);

    run_all_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2);

end

function [val] = target_func(x)
    N = 512;
    M = 256;
    k1 = x([1 M/4]);
    k2 = x([M/4+1 M/2]);

    im = imread('./image/lena.jpg');
    wm = imread('./image/watermark.jpg');
    im = im2double(imresize(im2gray(im), [N N]));
    wm = im2double(imresize(im2bw(wm), [M M]));
    
    [S1, S2, UW, VW, embimg] = embed_watermark(N, M, im, ...
                                            wm, k1, k2);
    imwrite(embimg, './image/embeded_lena.jpg');
    embimg = imread('./image/embeded_lena.jpg');
    embimg = im2double(imresize(im2gray(embimg), [N N]));

    [~, nc] = run_all_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2);
    val = nc;
end

function [im, wm, nc] = run_test(N, M, embimg, expwm, S1, S2, UW, VW, k1, k2, test_func, p1, p2, p3)
    if isempty(p1)
        [im, wm, nc] = test_func(N, M, embimg, expwm, S1, S2, UW, VW, k1, k2);
    elseif isempty(p2)
        [im, wm, nc] = test_func(N, M, embimg, expwm, S1, S2, UW, VW, k1, k2, p1);
    elseif isempty(p3)
        [im, wm, nc] = test_func(N, M, embimg, expwm, S1, S2, UW, VW, k1, k2, p1, p2);
    else
        [im, wm, nc] = test_func(N, M, embimg, expwm, S1, S2, UW, VW, k1, k2, p1, p2, p3);
    end
    if fix((N-size(im, 1)) / 2) > 0
        im = padarray(im, [fix((N-size(im, 1)) / 2) fix((N-size(im, 1)) / 2)], 0, 'both');
    end
    im = imresize(im, [256 256]);
    %imshow(im);
    %pause(1);
    wm = imresize(wm, [256 256]);
    % imshow(wm);
    % pause(1);
end

function [res, nc] = run_all_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2)
    nc = 0;
    [res1, res2, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_resize, N/18, [], []);
    res = [res1 res2];
    nc = nc + resnc;
    imshow(res);
    for i = 10:10:90
        [res1, res2, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_rotate, i, [], []);
        res = [res; res1 res2];
        nc = nc + resnc;
    end
    for i = 1:1:2
        for j = 1:1:2
            [res1, res2, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_crop, ...
                1+256*(i-1):1:256+256*(i-1), 1+256*(j-1):1:256+256*(j-1), []);
            res = [res; res1 res2];
            nc = nc + resnc;
        end
    end
    for i = 1:1:2
        for j = 1:1:2
            [res1, res2, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_mask, ...
                1+256*(i-1):1:256+256*(i-1), 1+256*(j-1):1:256+256*(j-1), []);
            res = [res; res1 res2];
            nc = nc + resnc;
        end
    end
    imwrite(res, 'res.jpg');
    imshow(res);
end

