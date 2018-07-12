function lenY = get_y_length(obj)
%GET_Y_LENGTH Returns the length of the expected y output from obj.simulate()
%
%	Part of the WBpackage class.

lenY = obj.lenOutput * obj.nOperatingPoints;

end

