


function [a,b,c] = fit_polynomial(x,y)
% 将 xy 向量变为列向量
x = x(:);
y = y(:);

% 构造 X 矩阵，X 的每一列分别是 x^4，x^2 和 1
X = [x.^4, x.^2, ones(size(x))];

% 使用最小二乘法计算 a、b、c 的值
coefficients = X \ y;

% 将 coefficients 向量赋值给 a、b、c
a = coefficients(1);
b = coefficients(2);
c = coefficients(3);

end