function [outY] = y_transform_mean(Y, valid)
%Y_TRANSFORM_MEAN Changes invalid y to the mean valid y value

meanY = mean(Y(valid,:));

outY = Y;
outY(~valid,:) = repmat(meanY, sum(~valid), 1);

end
