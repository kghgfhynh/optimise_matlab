clc,clear
close all
% 每行控制点数量
rowSizes = readmatrix('tsplinskinning\rowSizes.txt');  % rowSizes(i) = 第 i 排控制点数量
nRows = length(rowSizes);
nCtrl = sum(rowSizes);                  % 控制点总数

% 控制点
ctrlPts = readmatrix('tsplinskinning\initctrl.txt');   % nCtrl x 3
x_fixed = ctrlPts(:);                      % 3*nCtrl x 1

% 读取 abc 系数
abc = readmatrix('tsplinskinning\abcDown.txt');  % size = nMidRows x 3
a = abc(:,1);
b = abc(:,2);
c = abc(:,3);

% Ku 矩阵
fid = fopen('Ku.txt','r');
nKu = fscanf(fid,'%d',1);
Ku = fscanf(fid,'%f',[nKu nKu]);
Ku = Ku';
fclose(fid);
idxFree_scalar = [];   % 单维索引
currIdx = 1;           % 当前行第一个控制点的全局编号

for r = 1:nRows
    nThisRow = rowSizes(r);
    if r >= 2 && r < nRows-1
        if mod(r,3) == 0
            % 当前行是 Wij_up
            startIdx = currIdx;
            endIdx   = currIdx + nThisRow - 1;
            idxFree_scalar = [idxFree_scalar, startIdx:endIdx];
        end
    end
    currIdx = currIdx + nThisRow;
end

% 转为向量化索引（px, py, pz）
idxFree = [ ...
    idxFree_scalar;            % px
    idxFree_scalar + nCtrl;    % py
    idxFree_scalar + 2*nCtrl   % pz
];
idxFree = idxFree(:);
xf0 = x_fixed(idxFree);

options = optimoptions('fminunc',...
    'Algorithm','trust-region',...
    'SpecifyObjectiveGradient',true,...
    'Display','iter');

xf_opt = fminunc(@(xf) energy_Eu_withDownUpdate(xf, Ku, x_fixed, idxFree, rowSizes, abc), xf0, options);

% Assemble final control points
x_opt = x_fixed;
x_opt(idxFree) = xf_opt;

px_opt = x_opt(1:nCtrl);
py_opt = x_opt(nCtrl+1:2*nCtrl);
pz_opt = x_opt(2*nCtrl+1:3*nCtrl);

ctrlPts_opt = [px_opt, py_opt, pz_opt];  % nCtrl x 3
