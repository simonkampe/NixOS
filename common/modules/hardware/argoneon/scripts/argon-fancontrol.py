#!/usr/bin/python3

import sys
import os
import time
import traceback
from threading import Thread
from queue import Queue

sys.path.append("ARGON_OUT/modules")
from argonsysinfo import *
from argonregister import *

# Initialize I2C Bus
bus = argonregister_initializebusobj()

# This function converts the corresponding fanspeed for the given temperature
# The configuration data is a list of strings in the form "<temperature>=<speed>"

def get_fanspeed(tempval, configlist):
	for curconfig in configlist:
		curpair = curconfig.split("=")
		tempcfg = float(curpair[0])
		fancfg = int(float(curpair[1]))
		if tempval >= tempcfg:
			if fancfg < 1:
				return 0
			elif fancfg < 25:
				return 25
			return fancfg
	return 0

# This function retrieves the fanspeed configuration list from a file, arranged by temperature
# It ignores lines beginning with "#" and checks if the line is a valid temperature-speed pair
# The temperature values are formatted to uniform length, so the lines can be sorted properly

def load_config(fname):
	newconfig = []
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
				tempval = 0
				fanval = 0
				try:
					tempval = float(tmppair[0])
					if tempval < 0 or tempval > 100:
						continue
				except:
					continue
				try:
					fanval = int(float(tmppair[1]))
					if fanval < 0 or fanval > 100:
						continue
				except:
					continue
				newconfig.append( "{:5.1f}={}".format(tempval,fanval))
		if len(newconfig) > 0:
			newconfig.sort(reverse=True)
	except:
		return []
	return newconfig

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

# This function is the thread that monitors temperature and sets the fan speed
# The value is fed to get_fanspeed to get the new fan speed
# To prevent unnecessary fluctuations, lowering fan speed is delayed by 30 seconds
#
# Location of config file varies based on OS
#
def temp_check():
	argonregsupport = argonregister_checksupport(bus)

	fanconfig = ["65=100", "60=55", "55=30"]
	fanhddconfig = ["50=100", "40=55", "30=30"]
	fanhddconfigfile = "/etc/argon-fan-hdd.conf"

	tmpconfig = load_config("/etc/argon-fan.conf")
	if len(tmpconfig) > 0:
		fanconfig = tmpconfig

	if os.path.isfile(fanhddconfigfile):
		tmpconfig = load_config(fanhddconfigfile)
		if len(tmpconfig) > 0:
			fanhddconfig = tmpconfig
	else:
		fanhddconfig = []

	prevspeed=0
	while True:
		# Speed based on CPU Temp
		val = argonsysinfo_getcputemp()
		newspeed = get_fanspeed(val, fanconfig)
		# Speed based on HDD Temp
		val = argonsysinfo_getmaxhddtemp()
		tmpspeed = get_fanspeed(val, fanhddconfig)

		# Use faster fan speed
		if tmpspeed > newspeed:
			newspeed = tmpspeed

		if newspeed < prevspeed:
			# Pause 30s before speed reduction to prevent fluctuations
			time.sleep(30)
		prevspeed = newspeed
		try:
			if newspeed > 0:
				# Spin up to prevent issues on older units
				argonregister_setfanspeed(bus, 100, argonregsupport)
				# Set fan speed has sleep
			argonregister_setfanspeed(bus, newspeed, argonregsupport)
			time.sleep(30)
		except IOError:
			print("Failed to set new fan speed")
			time.sleep(60)


if len(sys.argv) > 1:
	cmd = sys.argv[1].upper()
	if cmd == "SET":
		try:
			argonregsupport = argonregister_checksupport(bus)
			newspeed = int(sys.argv[2])
			if (newspeed > 30 & newspeed <= 100):
				print("Set speed to", newspeed)
				argonregister_setfanspeed(bus, newspeed, argonregsupport)
			else:
				print("Cannot set speed to", newspeed)
		except Exception as e:
			print("Failed to set fan speed")
			traceback.print_exc()
			sys.exit(1)

	elif cmd == "SERVICE":
		# Starts the temperature monitor thread
		try:
			ipcq = Queue()
			t1 = Thread(target = temp_check)
			t1.start()
			ipcq.join()
		except Exception:
			sys.exit(1)