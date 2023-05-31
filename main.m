k1 = 0.01;
k2 = 0.01;
N = 512;
M = 256;

[S1, S2, UW, VW, embimg] = embed_watermark(N, M, imread('lena.jpg'), imread('watermark.jpg'), k1, k2);
imwrite(embimg, 'embeded_lena.jpg');
extract_watermark(N, M, imread("embeded_lena.jpg"), S1, S2, UW, VW, k1, k2);
