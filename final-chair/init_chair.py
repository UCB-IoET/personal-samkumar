#!/usr/bin/python
import subprocess

reset = None
while reset not in ('yes', 'no'):
    reset = raw_input('Reset the log? Enter "yes" or "no": ')
chair_id = raw_input('Enter a unique ID for this chair: ')
serial = None
while serial not in ('yes', 'no'):
    serial = raw_input('Change the serial number? Enter "yes" or "no": ')
if serial == "yes":
    new_serial = raw_input('Enter the new serial number: ')
    subprocess.call(["sload", "sattr", "0", "serial", "-x", new_serial])

with open("settings.lua", "w") as init:
    init.write("Settings = {}\n")
    init.write("function startup()\n")
    if reset == "yes":
        init.write("    storm.n.flash_reset_log(function () end)\n")
    init.write("    CHAIR_ID = {0}\n".format(chair_id))
    init.write("end\n")
    init.write("Settings.startup = startup\n")
    init.write("return Settings")

subprocess.call(["cd /home/oski/workspace/ && ./build.lua"], shell=True)
