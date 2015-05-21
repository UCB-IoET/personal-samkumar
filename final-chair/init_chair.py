#!/usr/bin/python
import subprocess

fs = None
while fs not in ("firestorm", "chair"):
    fs = raw_input('Program a firestorm or a chair? Enter "firestorm" or "chair": ')
    
if fs == "chair":
    reset = None
    while reset not in ('reset', 'flash'):
        reset = raw_input('Reset the log or flash the chair? Enter "reset" or "flash": ')
    serial = None
    while serial not in ('yes', 'no'):
        serial = raw_input('Change the serial number? Enter "yes" or "no": ')
    if serial == "yes":
        new_serial = raw_input('Enter the new serial number: ')
        subprocess.call(["sload", "sattr", "0", "serial", "-x", new_serial])
    
    
cd = "cd /home/oski/workspace/"

if fs == "firestorm":
    subprocess.call(["{0} && ./build_fs.lua".format(cd)], shell=True)
elif reset == "reset":
    subprocess.call(["{0} && ./build_reset_log.lua".format(cd)], shell=True)
else:
    subprocess.call(["{0} && ./build_chair.lua".format(cd)], shell=True)
