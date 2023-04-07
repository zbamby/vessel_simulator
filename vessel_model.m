pc = pcread('artery_bifur_surf.pcd');
 pcshow(pc)
[B,I] = sort(pc.Location(:,3)); % 将点云按照z向位置由近到远排序
pc_update_by_z = pc.Location(I,:);
% pcshow(pc_update_by_z)

n_slice_thick = 100; % 假设每个轮廓切片有100个点
n_slice_gap = 0; % 假设两个轮廓切片间漏掉了100个点

% %----环形缓冲器----
% % 初始化ring buffer
% % matlab里暂时模拟不出来，c++里写线程来实现数据的存取，记得加上锁
% ring_buffersize = 10;
% head = 1;
% tail = 1;
% ring_buffer_pointset = zeros(ring_buffersize*n_slice_thick,3);


%---优化器设置----
% 定义约束条件
A = [];
b = [];
Aeq = [];
beq = [];
lb = [-Inf, -Inf,2];
ub = [Inf, Inf,8];
nonlcon = [];
options = optimoptions('fmincon', 'Display', 'none', 'Algorithm', 'sqp');

% 随机初始化圆柱面参数
initRadius = 2;
% initHeight = 2;
initNormal = [0.1, 0.1];

%----采样大循环----
n_sample = 10; % 采样次数
j = 1; % 记录当前采样次数
k = 0; % 记录当前计算次数
pointset = zeros(n_sample*n_slice_thick,3);
for i = 1:(n_slice_thick + n_slice_gap):size(I) % size(I)用来模拟停止信号
    j_start = (j-1) * n_slice_thick+1;
    pointset(j_start:j_start+n_slice_thick-1,:) = pc_update_by_z(i:i+n_slice_thick-1,:);
    j = j + 1;

    if j > n_sample
        center = sum(pointset)./size(pointset,1);

        % 设置优化参数初始值
        initParams = [initNormal,initRadius];
        

        % 定义优化函数，即拟合误差的平方和
        fun = @(params) pointToCylinderDistance(pointset, center,params);
        % 使用fmincon函数执行优化
        optParams = fmincon(fun, initParams, A, b, Aeq, beq, lb, ub, nonlcon, options);
        
        % 从拟合参数中提取中心轴线、半径和
        centerAxis = [optParams(1:2),1];
        radius = optParams(3);
        
        % 可视化结果
        pcshow(pointset);
        hold on;
        
        % 画出向量
        quiver3(center(1), center(2), center(3), centerAxis(1), centerAxis(2), centerAxis(3), 'LineWidth', 2, 'MaxHeadSize', 0.5)
        axis equal
        plot3(center(1),center(2),center(3),'o','Color','b','MarkerSize',5,'MarkerFaceColor','#D9FFFF')
        drawnow;
        
        k = k+1;
        initRadius = radius;
        initNormal = centerAxis(1:2);
        j = 1;
        pointset = zeros(n_sample*n_slice_thick,3);
    end
end




















