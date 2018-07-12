function [outY] = y_transform_remove(Y, valid)
%Y_TRANSFORM_REMOVE Changes invalid y to NaN, disqualifying them for the model

outY = Y;
outY(~valid,:) = NaN;

end
