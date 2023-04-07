function d = pointToCylinderDistance(point, center, params)
%initParams = [initNormal,initRadius];
d = 0;
for i = 1:size(point,1)
d = d + (norm(cross(point(i,:)-center, [params(1:2),1])/norm([params(1:2),1])) - params(3))^2;
end
