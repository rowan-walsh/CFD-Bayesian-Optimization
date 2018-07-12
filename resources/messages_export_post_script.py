f = open(GetProjectDirectory() + '\\messageArchive.txt', 'a')
for message in GetMessages():
	if DateTime.Compare(message.DateTimeStamp, startTime) == 1:
		f.write('----- {0}, {1} (DP {2})\n'.format(message.DateTimeStamp, message.MessageType, message.DesignPoint))
		f.write(message.Summary + '\n')
f.write('\n')
f.close()

