#!/usr/bin/python3

import sys
import os
import time
from threading import Thread
from queue import Queue

sys.path.append("ARGON_OUT/modules")
from argonsysinfo import *
from argonregister import *

# Initialize I2C Bus
bus = argonregister_initializebusobj()

OLED_ENABLED=False

if os.path.exists("ARGON_OUT/modules/argoneonoled.py"):
	import datetime
	from argoneonoled import *
	OLED_ENABLED=True

OLED_CONFIGFILE = "/etc/argon-oled.conf"
UNIT_CONFIGFILE = "/etc/argon-units.conf"

# Load OLED Config file
def load_oledconfig(fname):
	output={}
	screenduration=-1
	screenlist=[]
	try:
		with open(fname, "r") as fp:
			for curline in fp:
				if not curline:
					continue
				tmpline = curline.strip()
				if not tmpline:
					continue
				if tmpline[0] == "#":
					continue
				tmppair = tmpline.split("=")
				if len(tmppair) != 2:
					continue
				if tmppair[0] == "switchduration":
					output['screenduration']=int(tmppair[1])
				elif tmppair[0] == "screensaver":
					output['screensaver']=int(tmppair[1])
				elif tmppair[0] == "screenlist":
					output['screenlist']=tmppair[1].replace("\"", "").split(" ")
				elif tmppair[0] == "enabled":
					output['enabled']=tmppair[1].replace("\"", "")
	except:
		return {}
	return output

# Load Unit Config file
def load_unitconfig(fname):
	output={"temperature": "C"}
	try:
		with open(fname, "r") as fp:
			for curline in fp:
				if not curline:
					continue
				tmpline = curline.strip()
				if not tmpline:
					continue
				if tmpline[0] == "#":
					continue
				tmppair = tmpline.split("=")
				if len(tmppair) != 2:
					continue
				if tmppair[0] == "temperature":
					output['temperature']=tmppair[1].replace("\"", "")
	except:
		return {}
	return output


#
# This function is the thread that updates OLED
#
def display_loop(readq):
	weekdaynamelist = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
	monthlist = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
	oledscreenwidth = oled_getmaxX()

	fontwdSml = 6	# Maps to 6x8
	fontwdReg = 8	# Maps to 8x16
	stdleftoffset = 54

	temperature="C"
	tmpconfig=load_unitconfig(UNIT_CONFIGFILE)
	if "temperature" in tmpconfig:
		temperature = tmpconfig["temperature"]

	screensavermode = False
	screensaversec = 120
	screensaverctr = 0

	screenenabled = ["clock", "ip"]
	prevscreen = ""
	curscreen = ""
	screenid = 0
	screenjogtime = 0
	screenjogflag = 0	# start with screenid 0
	cpuusagelist = []
	curlist = []

	tmpconfig=load_oledconfig(OLED_CONFIGFILE)

	if "screensaver" in tmpconfig:
		screensaversec = tmpconfig["screensaver"]
	if "screenduration" in tmpconfig:
		screenjogtime = tmpconfig["screenduration"]
	if "screenlist" in tmpconfig:
		screenenabled = tmpconfig["screenlist"]

	if "enabled" in tmpconfig:
		if tmpconfig["enabled"] == "N":
			screenenabled = []

	while len(screenenabled) > 0:
		if len(curlist) == 0 and screenjogflag == 1:
			# Reset Screen Saver
			screensavermode = False
			screensaverctr = 0

			# Update screen info
			screenid = screenid + screenjogflag
			if screenid >= len(screenenabled):
				screenid = 0
		prevscreen = curscreen
		curscreen = screenenabled[screenid]

		if screenjogtime == 0:
			# Resets jogflag (if switched manually)
			screenjogflag = 0
		else:
			screenjogflag = 1

		needsUpdate = False
		if curscreen == "cpu":
			# CPU Usage
			if len(curlist) == 0:
				try:
					if len(cpuusagelist) == 0:
						cpuusagelist = argonsysinfo_listcpuusage()
					curlist = cpuusagelist
				except:
					curlist = []
			if len(curlist) > 0:
				oled_loadbg("bgcpu")

				# Display List
				yoffset = 0
				tmpmax = 4
				while tmpmax > 0 and len(curlist) > 0:
					curline = ""
					tmpitem = curlist.pop(0)
					curline = tmpitem["title"]+": "+str(tmpitem["value"])+"%"
					oled_writetext(curline, stdleftoffset, yoffset, fontwdSml)
					oled_drawfilledrectangle(stdleftoffset, yoffset+12, int((oledscreenwidth-stdleftoffset-4)*tmpitem["value"]/100), 2)
					tmpmax = tmpmax - 1
					yoffset = yoffset + 16

				needsUpdate = True
			else:
				# Next page due to error/no data
				screenjogflag = 1
		elif curscreen == "storage":
			# Storage Info
			if len(curlist) == 0:
				try:
					tmpobj = argonsysinfo_listhddusage()
					for curdev in tmpobj:
						curlist.append({"title": curdev, "value": argonsysinfo_kbstr(tmpobj[curdev]['total']), "usage": int(100*tmpobj[curdev]['used']/tmpobj[curdev]['total']) })
					#curlist = argonsysinfo_liststoragetotal()
				except:
					curlist = []
			if len(curlist) > 0:
				oled_loadbg("bgstorage")

				yoffset = 16
				tmpmax = 3
				while tmpmax > 0 and len(curlist) > 0:
					tmpitem = curlist.pop(0)
					# Right column first, safer to overwrite white space
					oled_writetextaligned(tmpitem["value"], 77, yoffset, oledscreenwidth-77, 2, fontwdSml)
					oled_writetextaligned(str(tmpitem["usage"])+"%", 50, yoffset, 74-50, 2, fontwdSml)
					tmpname = tmpitem["title"]
					if len(tmpname) > 8:
						tmpname = tmpname[0:8]
					oled_writetext(tmpname, 0, yoffset, fontwdSml)

					tmpmax = tmpmax - 1
					yoffset = yoffset + 16
				needsUpdate = True
			else:
				# Next page due to error/no data
				screenjogflag = 1

		elif curscreen == "raid":
			# Raid Info
			if len(curlist) == 0:
				try:
					tmpobj = argonsysinfo_listraid()
					curlist = tmpobj['raidlist']
				except:
					curlist = []
			if len(curlist) > 0:
				oled_loadbg("bgraid")
				tmpitem = curlist.pop(0)
				oled_writetextaligned(tmpitem["title"], 0, 0, stdleftoffset, 1, fontwdSml)
				oled_writetextaligned(tmpitem["value"], 0, 8, stdleftoffset, 1, fontwdSml)
				oled_writetextaligned(argonsysinfo_kbstr(tmpitem["info"]["size"]), 0, 56, stdleftoffset, 1, fontwdSml)

				if len(tmpitem['info']['state']) > 0:
					oled_writetext( tmpitem['info']['state'], stdleftoffset, 8, fontwdSml )

				if len(tmpitem['info']['rebuildstat']) > 0:
					oled_writetext("Rebuild:" + tmpitem['info']['rebuildstat'], stdleftoffset, 16, fontwdSml)

				# TODO: May need to use different method for each raid type (i.e. check raidlist['raidlist'][raidctr]['value'])
				#oled_writetext("Used:"+str(int(100*tmpitem["info"]["used"]/tmpitem["info"]["size"]))+"%", stdleftoffset, 24, fontwdSml)


				oled_writetext("Active:"+str(int(tmpitem["info"]["active"]))+"/"+str(int(tmpitem["info"]["devices"])), stdleftoffset, 32, fontwdSml)
				oled_writetext("Working:"+str(int(tmpitem["info"]["working"]))+"/"+str(int(tmpitem["info"]["devices"])), stdleftoffset, 40, fontwdSml)
				oled_writetext("Failed:"+str(int(tmpitem["info"]["failed"]))+"/"+str(int(tmpitem["info"]["devices"])), stdleftoffset, 48, fontwdSml)
				needsUpdate = True
			else:
				# Next page due to error/no data
				screenjogflag = 1

		elif curscreen == "ram":
			# RAM
			try:
				oled_loadbg("bgram")
				tmpraminfo = argonsysinfo_getram()
				oled_writetextaligned(tmpraminfo[0], stdleftoffset, 8, oledscreenwidth-stdleftoffset, 1, fontwdReg)
				oled_writetextaligned("of", stdleftoffset, 24, oledscreenwidth-stdleftoffset, 1, fontwdReg)
				oled_writetextaligned(tmpraminfo[1], stdleftoffset, 40, oledscreenwidth-stdleftoffset, 1, fontwdReg)
				needsUpdate = True
			except:
				needsUpdate = False
				# Next page due to error/no data
				screenjogflag = 1
		elif curscreen == "temp":
			# Temp
			try:
				oled_loadbg("bgtemp")
				hddtempctr = 0
				maxcval = 0
				mincval = 200


				# Get min/max of hdd temp
				hddtempobj = argonsysinfo_gethddtemp()
				for curdev in hddtempobj:
					if hddtempobj[curdev] < mincval:
						mincval = hddtempobj[curdev]
					if hddtempobj[curdev] > maxcval:
						maxcval = hddtempobj[curdev]
					hddtempctr = hddtempctr + 1

				cpucval = argonsysinfo_getcputemp()
				if hddtempctr > 0:
					alltempobj = {"cpu": cpucval,"hdd min": mincval, "hdd max": maxcval}
					# Update max C val to CPU Temp if necessary
					if maxcval < cpucval:
						maxcval = cpucval

					displayrowht = 8
					displayrow = 8
					for curdev in alltempobj:
						if temperature == "C":
							# Celsius
							tmpstr = str(alltempobj[curdev])
							if len(tmpstr) > 4:
								tmpstr = tmpstr[0:4]
						else:
							# Fahrenheit
							tmpstr = str(32+9*(alltempobj[curdev])/5)
							if len(tmpstr) > 5:
								tmpstr = tmpstr[0:5]
						if len(curdev) <= 3:
							oled_writetext(curdev.upper()+": "+ tmpstr+ chr(167) +temperature, stdleftoffset, displayrow, fontwdSml)

						else:
							oled_writetext(curdev.upper()+":", stdleftoffset, displayrow, fontwdSml)

							oled_writetext("     "+ tmpstr+ chr(167) +temperature, stdleftoffset, displayrow+displayrowht, fontwdSml)
						displayrow = displayrow + displayrowht*2
				else:
					maxcval = cpucval
					if temperature == "C":
						# Celsius
						tmpstr = str(cpucval)
						if len(tmpstr) > 4:
							tmpstr = tmpstr[0:4]
					else:
						# Fahrenheit
						tmpstr = str(32+9*(cpucval)/5)
						if len(tmpstr) > 5:
							tmpstr = tmpstr[0:5]

					oled_writetextaligned(tmpstr+ chr(167) +temperature, stdleftoffset, 24, oledscreenwidth-stdleftoffset, 1, fontwdReg)

				# Temperature Bar: 40C is min, 80C is max
				maxht = 21
				barht = int(maxht*(maxcval-40)/40)
				if barht > maxht:
					barht = maxht
				elif barht < 1:
					barht = 1
				oled_drawfilledrectangle(24, 20+(maxht-barht), 3, barht, 2)


				needsUpdate = True
			except:
				needsUpdate = False
				# Next page due to error/no data
				screenjogflag = 1
		elif curscreen == "ip":
			# IP Address
			try:
				oled_loadbg("bgip")
				oled_writetextaligned(argonsysinfo_getip(), 0, 8, oledscreenwidth, 1, fontwdReg)
				needsUpdate = True
			except:
				needsUpdate = False
				# Next page due to error/no data
				screenjogflag = 1
		else:
			try:
				oled_loadbg("bgtime")
				# Date and Time HH:MM
				curtime = datetime.datetime.now()

				# Month/Day
				outstr = str(curtime.day).strip()
				if len(outstr) < 2:
					outstr = " "+outstr
				outstr = monthlist[curtime.month-1]+outstr
				oled_writetextaligned(outstr, stdleftoffset, 8, oledscreenwidth-stdleftoffset, 1, fontwdReg)

				# Day of Week
				oled_writetextaligned(weekdaynamelist[curtime.weekday()], stdleftoffset, 24, oledscreenwidth-stdleftoffset, 1, fontwdReg)

				# Time
				outstr = str(curtime.minute).strip()
				if len(outstr) < 2:
					outstr = "0"+outstr
				outstr = str(curtime.hour)+":"+outstr
				if len(outstr) < 5:
					outstr = "0"+outstr
				oled_writetextaligned(outstr, stdleftoffset, 40, oledscreenwidth-stdleftoffset, 1, fontwdReg)

				needsUpdate = True
			except:
				needsUpdate = False
				# Next page due to error/no data
				screenjogflag = 1

		if needsUpdate == True:
			if screensavermode == False:
				# Update screen if not screen saver mode
				oled_power(True)
				oled_flushimage(prevscreen != curscreen)
				oled_reset()

			timeoutcounter = 0
			while timeoutcounter<screenjogtime or screenjogtime == 0:
				qdata = ""
				if readq.empty() == False:
					qdata = readq.get()

				if qdata == "OLEDSWITCH":
					# Trigger screen switch
					screenjogflag = 1
					# Reset Screen Saver
					screensavermode = False
					screensaverctr = 0

					break
				elif qdata == "OLEDSTOP":
					# End OLED Thread
					display_defaultimg()
					return
				else:
					screensaverctr = screensaverctr + 1
					if screensaversec <= screensaverctr and screensavermode == False:
						screensavermode = True
						oled_fill(0)
						oled_reset()
						oled_power(False)

					if timeoutcounter == 0:
						# Use 1 sec sleep get CPU usage
						cpuusagelist = argonsysinfo_listcpuusage(1)
					else:
						time.sleep(1)

					timeoutcounter = timeoutcounter + 1
					if timeoutcounter >= 60 and screensavermode == False:
						# Refresh data every minute, unless screensaver got triggered
						screenjogflag = 0
						break
	display_defaultimg()

def display_defaultimg():
	# Load default image
	#oled_power(True)
	#oled_loadbg("bgdefault")
	#oled_flushimage()
	oled_fill(0)
	oled_reset()


try:
    ipcq = Queue()
    if OLED_ENABLED == True:
        t1 = Thread(target = display_loop, args =(ipcq, ))
        t1.start()
    ipcq.join()
except Exception:
    sys.exit(1)
