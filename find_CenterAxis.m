function optParams = find_CenterAxis(pointset, initParams)
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    lb = [-Inf, -Inf,2];
    ub = [Inf, Inf,8];
    nonlcon = [];
    options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');
    center = sum(pointset)./size(pointset,1);
    
    fun = @(params) pointToCylinderDistance(pointset, center,params);
    optParams = fmincon(fun, initParams, A, b, Aeq, beq, lb, ub, nonlcon, options);
end