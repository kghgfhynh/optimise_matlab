function ctrlPts = updateDownCtrlPts(ctrlPts, rowSizes, abc)
% ctrlPts : nCtrl x 3
% rowSizes: 每一行控制点数量
% abc     : [a b c]，每一组对应 (up, main, down)

    rowStart = cumsum([1; rowSizes(1:end-1)]);
    nMid = size(abc,1);

    for k = 1:nMid
        a = abc(k,1);
        b = abc(k,2);
        c = abc(k,3);

        idx_up   = rowStart(3*k-2) : rowStart(3*k-2)+rowSizes(3*k-2)-1;
        idx_main = rowStart(3*k-1) : rowStart(3*k-1)+rowSizes(3*k-1)-1;
        idx_down = rowStart(3*k)   : rowStart(3*k)  +rowSizes(3*k)-1;

        Wi_up   = ctrlPts(idx_up,:);
        Wi_main = ctrlPts(idx_main,:);

        % 核心约束更新（你的正确版本）
        ctrlPts(idx_down,:) = ((1-b)*Wi_main - a*Wi_up)/c;
    end
end
