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

if len(sys.argv) > 1:
	cmd = sys.argv[1].upper()
	if cmd == "SHUTDOWN":
		# Signal poweroff
		argonregister_signalpoweroff(bus)

	elif cmd == "SERVICE":
		# Starts the power button monitor thread
		try:
			ipcq = Queue()
			t1 = Thread(target = argonpowerbutton_monitor, args =(ipcq, ))
			t1.start()
			ipcq.join()
		except Exception:
			sys.exit(1)