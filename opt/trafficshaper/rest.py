#!/usr/bin/env python
import web
import subprocess
import time

urls = (
    '/set_shaping', 'set_shaping',
    '/', 'default'
)

#Shaping script
script_path = "sudo ./configure_traffic_control.sh"

app = web.application(urls, globals())

class set_shaping:        
    def GET(self):
        params = web.input()
	#script_call = [script_path]
	script_call = script_path
	if hasattr(params, 'bwdown'):
	#	script_call.append('-d ' + params.d)
		script_call += " -d "+params.bwdown
	if hasattr(params, 'bwup'):
		script_call += " -u "+params.bwup
	#	script_call.append('-u ' + params.u)
	if hasattr(params, 'latencydown'):
		script_call += " -o "+params.latencydown
	#	script_call.append('-o ' + params.o)
	if hasattr(params, 'latencyup'):
		script_call += " -i "+params.latencyup
	#	script_call.append('-i ' + params.i)
	if hasattr(params, 'plrdown'):
		script_call += " -k "+params.plrdown
	#	script_call.append('-k ' + params.k)
	if hasattr(params, 'plrup'):
		script_call += " -j "+params.plrup
	#	script_call.append('-j ' + params.j)
        if hasattr(params, 'h'):
		script_call += " -h "+params.h
        #        script_call.append('-h')
	subprocess.call(script_call, subprocess.STDOUT, shell=True)
	return "Script called..."

class default:
    def GET(self):
        return "EXAMPLE: /set_shaping -bwdown (downspeed in kbit) -bwup (upspeed in kbit) -latencydown (down delay in ms) -latencyup (up delay in ms) -plrdown (down packetloss in percent) -plrup (up packetloss in percent)"
if __name__ == "__main__":
	# Set default values
	script_call = script_path
	script_call += " -d 3600 -u 1500 -o 40 -i 40 -k 0 -j 0"
	subprocess.call(script_call, subprocess.STDOUT, shell=True)
	app.run()