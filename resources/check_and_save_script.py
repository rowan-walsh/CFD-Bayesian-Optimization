badMessageStr = 'Unable to open the specified geometry in DesignModeler, possibly due to the third party features.'
healthyFileBool = True
for message in GetMessages():
	if (DateTime.Compare(message.DateTimeStamp, startTime) == 1) and (message.Summary == badMessageStr):
		healthyFileBool = False
		break

if healthyFileBool:
	Save(Overwrite=True)
