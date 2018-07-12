for desi in Parameters.GetAllDesignPoints():
	for message in GetMessages():
		if (DateTime.Compare(message.DateTimeStamp, startTime) == 1) and (message.DesignPoint == desi.Name):
			desi.Retained = False
			break

