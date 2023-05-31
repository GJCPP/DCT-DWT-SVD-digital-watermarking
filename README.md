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

## 实现思路
#### 20230531
首先不清楚的事不要做
1. 为什么俩方阵大小能对上？
2. 为什么要DCT？
3. PSO是什么玩意？

所以说不失一般性，先假定水印图片大小是原图的二分之一，这样正好方阵大小能对齐；DCT和PSO先跳过，$k$就当个小常数；先能输出图片再说。

