function [E, grad] = energy_Eu_withDownUpdate(xf, Ku, x_fixed, idxFree, rowSizes, abc)
    nCtrl = length(x_fixed)/3;%控制点数量
    
    %--------------------------------------------------
    % 1. 组装完整控制点向量（只替换自由变量）
    %--------------------------------------------------
    x = x_fixed;
    x(idxFree) = xf;%用 xf 覆盖
    
    % 拆分 px, py, pz
    px = x(1:nCtrl);
    py = x(nCtrl+1:2*nCtrl);
    pz = x(2*nCtrl+1:end);
    
    ctrlPts = [px, py, pz];  % nCtrl x 3
    
    %--------------------------------------------------
    % 2. 用几何约束更新 down 控制点
    %--------------------------------------------------
    ctrlPts = updateDownCtrlPts(ctrlPts, rowSizes, abc);

    %--------------------------------------------------
    % 3. 计算能量（只用 Suu -> Ku）
    %--------------------------------------------------
    px = ctrlPts(:,1);
    py = ctrlPts(:,2);
    pz = ctrlPts(:,3);
    
    E = px.'*Ku*px + py.'*Ku*py + pz.'*Ku*pz;
    
    %--------------------------------------------------
    % 4. 计算梯度（先对“全控制点”）
    %--------------------------------------------------
    gx = zeros(3*nCtrl,1);
    gx(1:nCtrl)         = 2*Ku*px;
    gx(nCtrl+1:2*nCtrl) = 2*Ku*py;
    gx(2*nCtrl+1:end)   = 2*Ku*pz;
    
    %--------------------------------------------------
    % 5. 只返回自由变量的梯度
    %--------------------------------------------------
    grad = gx(idxFree);
end
