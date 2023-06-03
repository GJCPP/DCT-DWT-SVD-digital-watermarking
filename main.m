function main
    N = 512; %原图像大小
    M = 256; %水印图像大小
    k_len = fix(M/4); % k_1，k_2的长度为 M/4
    im = imread('./image/lena.jpg');
    wm = imread('./image/watermark.jpg');
    im = im2double(imresize(im2gray(im), [N N])); %转为灰度图 + 强制把大小转换为N*N + 转为double类型
    wm = im2double(imresize(im2bw(wm), [M M]));
    %k1 = 0.05 * ones(1, k_len); 初始的、效果算不错的参数
    %k2 = 0.001 * ones(1, k_len);
    history = load('./output/save_20230603_1009/para.mat'); % 读取先前的参数，并恢复到k_1, k_2
    k1 = history.v(1:1:k_len);
    k2 = history.v(k_len+1:1:k_len*2);

    obj_func = @(x)target_func(x, N, M, k_len, im, wm); % 目标函数
    out_func = @(optimValues, state)outFcn(optimValues, state, N, M, im, wm); % 打印PSO每轮迭代后的情况
    options = optimoptions('particleswarm', ...
        'MaxIterations', 100, ...          % 最多迭代100轮
        'OutputFcn', out_func, ...         % 每轮迭代后的输出函数，会保存当前最优解
        'SwarmSize', 50, ...               % 粒子数为50
        'InitialSwarmMatrix', [k1 k2]);    % 初始时将一个粒子放置在预设位置
    x = particleswarm(obj_func, ...
        k_len*2, ...                       % 变量为长度为 k_len*2 的向量
        1e-7*ones(1, 2*k_len), ...         % 变量每个位置的最小取值为1e-7
        1*ones(1, 2*k_len), ...            % 变量每个位置的最大取值为1
        options);
        % 执行优化
end

function [stop] = outFcn(optimValues, state, N, M, im, wm)
    % 打印一轮迭代后的信息

    stop = false; % 迭代默认不停止
    k1 = diag(optimValues.bestx(1:1:64));   % 64应该是k_len的值；懒，就直接写了
    k2 = diag(optimValues.bestx(65:1:128)); % 取出k_1和k_2的对角阵
    disp(['Iteration: ', num2str(optimValues.iteration)]);
        % 完成迭代轮数
    disp(['Best Value: ', num2str(optimValues.bestfval)]);
        % 目前最优目标函数值
    v = optimValues.bestx;
    save('./output/para.mat', 'v'); % 保存目前最优变量取值到指定文件
    disp(['Best Para: ' num2str(optimValues.bestx)]);
        % 目前最优的变量取值
    disp(['Mean Fval: ', num2str(optimValues.meanfval)]);
        % 粒子的平均目标函数值；这一值应当会逐渐下降
    [S1, S2, UW, VW, embimg] = embed_watermark(N, M, im, wm, k1, k2);
    imwrite(embimg, './output/current_emb.jpg');
        % 使用当前最优参数嵌入图像，并保存到指定文件（作为一个preview）
    [res, ~] = show_all_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2);
    imwrite(res, './output/current_res.jpg');
        % 使用当前最优参数进行各项测试，并保存结果到指定文件
end

function [val] = target_func(x, N, M, k_len, im, wm)
    % 该函数为PSO的目标函数，函数公式参见README.md
    k1 = diag(x(1:1:k_len));
    k2 = diag(x(k_len+1:1:2*k_len));
        % 将向量恢复为两个对角矩阵

    [S1, S2, UW, VW, embimg] = embed_watermark(N, M, im, ...
                                            wm, k1, k2);
    imwrite(embimg, './image/embeded_lena.jpg');
    embimg = imread('./image/embeded_lena.jpg');
    embimg = im2double(imresize(im2gray(embimg), [N N]));
        % 使用指定参数嵌入图像，并保存到指定文件后读回
        % 写入后读回是为了模拟保存为jpg带来的损失
        % 不知道有没有不真的写入文件的模拟方法，总之现在这个works
    
    sim = corr2(im, embimg);
    if sim < 0.999
        val = 100 - sim;
        % 要求嵌入水印后的图像与原图像的相关度大于0.999
        % 否则只以相关度作为优化目标
        return
    end
    sim = 0;
    sim = sim - run_all_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2);
    val = sim;
        % 当与原图像的相关度达标后，以各项测试的分数来作为目标函数进行优化
end

function [im, wm, sim] = run_test(N, M, embimg, expwm, S1, S2, UW, VW, k1, k2, test_func, p1, p2, p3)
    % 一个辅助函数，用来调用测试；
    % 主要是负责接受测试函数的返回值、善后等等
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
        % 测试函数未必返回适合显示的图像
        % 此处对图像进行256像素对齐；这一数值可以与main中的NM无关，因为只是记录结果的需要
end

function [sim] = run_all_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2)
    % 依次以各参数执行test文件夹下提供的所有测试
    [~, ~, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_resize, N/18, [], []);
    sim = resnc;
        % 执行resize测试，将含水印图像缩小到原来的1/18；resnc为测试得分，由相关系数（corr2）计算
    for i = 10:10:90
        [~, ~, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_rotate, i, [], []);
        sim = sim + resnc;
        % 执行rotate测试，将含水印图像旋转i个角度
    end
    for i = 1:1:2
        for j = 1:1:2
            [~, ~, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_crop, ...
                1+256*(i-1):1:256+256*(i-1), 1+256*(j-1):1:256+256*(j-1), []);
            sim = sim + 10*resnc;
            % 执行crop测试，将含水印图像剪切到原来的1/4大小
        end
    end
    for i = 1:1:2
        for j = 1:1:2
            [~, ~, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_mask, ...
                1+256*(i-1):1:256+256*(i-1), 1+256*(j-1):1:256+256*(j-1), []);
            sim = sim + 4*resnc;
            % 执行mask测试，将含水印图像的1/4用黑色取代
        end
    end
     [~, ~, resnc] = run_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2, @test_circrop, []);
     sim = sim + 4 * resnc;
    % 执行mask测试，将含水印图像的周围一圈用黑色取代
end

function [res, sim] = show_all_test(N, M, embimg, wm, S1, S2, UW, VW, k1, k2)
    % 展示测试结果
    % 与run_all_test唯一不同的是，会把结果以图像的方式返回
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
end

