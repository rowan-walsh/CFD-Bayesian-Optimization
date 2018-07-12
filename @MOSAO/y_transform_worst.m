function [outY] = y_transform_worst(Y, valid)
%Y_TRANSFORM_WORST Changes invalid y to the worst (max) valid y value

worstY = max(Y(valid,:));

outY = Y;
outY(~valid,:) = repmat(worstY, sum(~valid), 1);

end
