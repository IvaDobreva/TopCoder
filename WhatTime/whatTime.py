class Time:
    def whatTime(self, seconds):
        #Find hours
        HOUR = 3600
        MINUTE = 60

        hours = seconds/HOUR
        minutes = (seconds%HOUR)/MINUTE
        sec = seconds%MINUTE

        return(str(hours)+":"+str(minutes)+":"+str(sec))

n = Time()
n.whatTime(86399)
