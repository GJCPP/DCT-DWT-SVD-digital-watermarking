# DCT-DWT-SVD-digital-watermarking

这份代码是对这一篇论文的复现：“Dual DCT-DWT-SVD digital watermarking algorithm based on particle swarm optimization”

论文地址：[here](https://cafetarjome.com/wp-content/uploads/1004/translation/c69f963fa0192e7e.pdf)

## 嵌入算法流程
![](./pic/steps.png)

首先假定一下输入的是 $2^n$ 的方图，方便处理
然后是 Watermark 图片的处理，先使用 GAT 方法进行打乱；具体 GAT 是什么见后
然后对其做 DCT + 两层DWT （为什么要做 DCT 暂不清楚）
然后对 DWT 的低频分量，也就是最左上角那块的方阵做 SVD 分解，保存左右两侧的$U$和$V$（可以想象为某种密钥），把方阵 $S$ 作为嵌入量

另一侧，输入图片也是 DCT + 三层DWT，并把左上角两个方阵的$S_1, S_2$取出来，跟水印那边的$S$组合 $$ S_1^\prime = S_1 + k_i\cdot S$$$$ S_2^\prime = S_2 + k_i\cdot S$$
$k_i$是神秘参数，由PSO生成；咱们先不管了，当个常数。然后把新的这个矩阵嵌回去，进行IDWT和IDCT生成一个打上了水印图片。

## 提取算法流程
![](./pic/extract_steps.png)

首先提取算法是需要嵌入算法的$U, V, S_1, S_2$四个矩阵的；不需要原图像。
考虑嵌入时所作的，是 $$ S_1^\prime = S_1 + k_1\cdot S $$
所以提取的时候所作的将是 $$ S = \frac{1}{k_1} (S_1^\prime - S_1) $$
因为在低频和高频信号上都做了嵌入，因此可以提取出俩$S$；可能增加robustness吧。
**注意：** 这样计算得到的$S$并不是原来的$S$；因为$U_1S_1^\prime V_1$的SVD得到的中间项并非原来的$S_1^\prime$。它们会相差不多吗？我不确定；先做了再说咯。
算出了$S$后，再使用喜闻乐见的IDWT直接把这一低频信号转换回去。根据DWT的原理来说，低频信号保留了图像的基本结构，因此只要不是极其精致的水印，损失应该不大。（当然，也可以保留水印图像的中、高频信号，尝试更完整地恢复）

## 实现思路
#### 20230531
首先不清楚的事不要做
1. 为什么俩方阵大小能对上？
2. 为什么要DCT？
3. PSO是什么玩意？

所以说不失一般性，先假定水印图片大小是原图的二分之一，这样正好方阵大小能对齐；DCT和PSO先跳过，$k$就当个小常数；先能输出图片再说。

#### 20230531
提取也做好了，matlab在这些计算方面实在太好用了。
今天先丢这了.jpg
