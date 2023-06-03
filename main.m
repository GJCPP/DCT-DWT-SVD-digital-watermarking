function main
    N = 512;
    M = 256; %S的大小为M/4
    k_len = fix(M/4);
    im = imread('./image/lena.jpg');
    wm = imread('./image/watermark.jpg');
    im = im2double(imresize(im2gray(im), [N N]));
    wm = im2double(imresize(im2bw(wm), [M M]));
    %k1 = 0.094216 * ones(1, k_len);
    %k2 = 6.0247e-06 * ones(1, k_len);
    history = load('./output/save_20230603_1009/para.mat');
    k1 = history.v(1:1:k_len);
    k2 = history.v(k_len+1:1:k_len*2);

    obj_func = @(x)target_func(x, N, M, k_len, im, wm);
    out_func = @(optimValues, state)outFcn(optimValues, state, N, M, im, wm);
    options = optimoptions('particleswarm', ...
        'MaxIterations', 100, ...
        'OutputFcn', out_func, ...
        'SwarmSize', 50, ...
        'InitialSwarmMatrix', [k1 k2], ...
        'MaxIterations', 100);%, ...
        %'SelfAdjustmentWeight', 2, ...
        %'SocialAdjustmentWeight', 2);
   % x = particleswarm(obj_func, 2, 1e-7*ones(1, 2), 1*ones(1, 2), options);
    x = particleswarm(obj_func, k_len*2, 1e-7*ones(1, 2*k_len), 1*ones(1, 2*k_len), options);

end

function [stop] = outFcn(optimValues, state, N, M, im, wm)
    stop = false;
    %k1 = optimValues.bestx(1);
    %k2 = optimValues.bestx(2);
    k1 = diag(optimValues.bestx(1:1:64));
    k2 = diag(optimValues.bestx(65:1:128));
    disp(['Iteration: ', num2str(optimValues.iteration)]);
    disp(['Best Value: ', num2str(optimValues.bestfval)]);
    v = optimValues.bestx;
    save('./output/para.mat', 'v');
    disp(['Best Para: ' num2str(optimValues.bestx)]);
    disp(['Mean Fval: ', num2str(optimValues.meanfval)]);
    [S1, S2, UW, VW, embimg] = embed_watermark(N, M, im, wm, k1, k2);
    imwrite(embimg, './output/current_emb.jpg');
    [res, ~] = show_all_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2);
    imwrite(res, './output/current_res.jpg');
end

function [val] = target_func(x, N, M, k_len, im, wm)
    k1 = diag(x(1:1:k_len));
    k2 = diag(x(k_len+1:1:2*k_len));
    %k1 = x(1);
    %k2 = x(2);

    [S1, S2, UW, VW, embimg] = embed_watermark(N, M, im, ...
                                            wm, k1, k2);
    imwrite(embimg, './image/embeded_lena.jpg');
    embimg = imread('./image/embeded_lena.jpg');
    embimg = im2double(imresize(im2gray(embimg), [N N]));
    
    sim = corr2(im, embimg);
    if sim < 0.999
        val = 100 - sim;
        return
    end
    sim = 0;
    sim = sim - run_all_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2);
    val = sim;
end

function [im, wm, sim] = run_test(N, M, embimg, expwm, S1, S2, UW, VW, k1, k2, test_func, p1, p2, p3)
    if isempty(p1)
        [im, wm, sim] = test_func(N, M, embimg, expwm, S1, S2, UW, VW, k1, k2);
    elseif isempty(p2)
        [im, wm, sim] = test_func(N, M, embimg, expwm, S1, S2, UW, VW, k1, k2, p1);
    elseif isempty(p3)
        [im, wm, sim] = test_func(N, M, embimg, expwm, S1, S2, UW, VW, k1, k2, p1, p2);
    else
        [im, wm, sim] = test_func(N, M, embimg, expwm, S1, S2, UW, VW, k1, k2, p1, p2, p3);
    end
    if fix((N-size(im, 1)) / 2) > 0
        im = padarray(im, [fix((N-size(im, 1)) / 2) fix((N-size(im, 1)) / 2)], 0, 'both');
    end
    im = imresize(im, [256 256]);
    wm = imresize(wm, [256 256]);
    %nc = log(nc);
    %imshow(im);
    %pause(1);
    % imshow(wm);
    % pause(1);
end

function [sim] = run_all_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2)
    [~, ~, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_resize, N/18, [], []);
    sim = resnc;
    for i = 10:10:90
        [~, ~, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_rotate, i, [], []);
        sim = sim + resnc;
    end
    for i = 1:1:2
        for j = 1:1:2
            [~, ~, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_crop, ...
                1+256*(i-1):1:256+256*(i-1), 1+256*(j-1):1:256+256*(j-1), []);
            sim = sim + 10*resnc;
        end
    end
    for i = 1:1:2
        for j = 1:1:2
            [~, ~, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_mask, ...
                1+256*(i-1):1:256+256*(i-1), 1+256*(j-1):1:256+256*(j-1), []);
            sim = sim + 4*resnc;
        end
    end
     [~, ~, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_circrop, []);
     sim = sim + 4 * resnc;
end

function [res, sim] = show_all_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2)
    sim = 0;
    [res1, res2, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_resize, N/18, [], []);
    res = [res1 res2];
    sim = sim + resnc;
    %imshow(res);
    for i = 10:10:90
        [res1, res2, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_rotate, i, [], []);
        res = [res; res1 res2];
        sim = sim + resnc;
    end
    for i = 1:1:2
        for j = 1:1:2
            [res1, res2, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_crop, ...
                1+256*(i-1):1:256+256*(i-1), 1+256*(j-1):1:256+256*(j-1), []);
            res = [res; res1 res2];
            sim = sim + resnc;
        end
    end
    for i = 1:1:2
        for j = 1:1:2
            [res1, res2, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_mask, ...
                1+256*(i-1):1:256+256*(i-1), 1+256*(j-1):1:256+256*(j-1), []);
            res = [res; res1 res2];
            sim = sim + resnc;
        end
    end
    [res1, res2, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_circrop, []);
    res = [res; res1 res2];
    sim = sim + resnc;
    %imwrite(res, 'res.jpg');
    %imshow(res);
end

