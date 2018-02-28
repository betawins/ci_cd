#!/usr/bin/env python

########################################################################################################################
import os
import subprocess
import sys
import json
import time

########################################################################################################################
v_target = "none"
v_operation = "none"
v_gateware_source = "none"

########################################################################################################################
def func_probe():
    # Check gateware
    cmd_list = []
    try:
        with open('../devices.json') as json_file:
            data = json.load(json_file)
            for p in data:
                for q in p['receivers']:
                    if (v_target == str(q['type'])) or (v_target == "all"):
                        cmd = "timeout 5 ssh %s@%s%s eb-info %s" % (p['login'], p['name'], p['extension'], q['slot'])
                        cmd_list.append(cmd)
                        cmd = "timeout 5 ssh %s@%s%s saft-ctl %s -i" % (p['login'], p['name'], p['extension'], q['dev_name'])
                        cmd_list.append(cmd)
                        cmd = "timeout 5 ssh %s@%s%s saft-ctl %s -s" % (p['login'], p['name'], p['extension'], q['dev_name'])
                        cmd_list.append(cmd)
    except (ValueError, KeyError, TypeError):
        print "JSON format error"
    for i in range(len(cmd_list)):
        subprocess.call(cmd_list[i].split())
        print "----------------------------------------------------------------------------------------------------"

########################################################################################################################
def func_start():
    # Start saftd
    cmd_list = []
    try:
        with open('../devices.json') as json_file:
            data = json.load(json_file)
            for p in data:
                receivers = []
                for q in p['receivers']:
                    if (v_target == str(q['type'])) or (v_target == "all"):
                        relation = "%s:%s" % ((q['dev_name']), (q['slot']))
                        receivers.append(relation)
                        receivers_string = ' '.join(str(x) for x in receivers)
                        if p['csco_ramdisk'] == "no":
                            cmd = "timeout 5 ssh %s@%s%s `saftd %s`" % (p['login'], p['name'], p['extension'], receivers_string)
                        else:
                            cmd = "timeout 5 ssh %s@%s%s `/usr/sbin/saftd %s`" % (p['login'], p['name'], p['extension'], receivers_string)
                        cmd_list.append(cmd)
    except (ValueError, KeyError, TypeError):
        print "JSON format error"
    for i in range(len(cmd_list)):
        cmd_to_perform = cmd_list[i].split()
        cmd_to_perform_info = cmd_to_perform[3]
        print "Starting saftd at %s..." % (cmd_to_perform_info)
        subprocess.call(cmd_to_perform)
        time.sleep(1)
        print "----------------------------------------------------------------------------------------------------"

########################################################################################################################
def func_stop():
    # Stop saftd
    cmd_list = []
    try:
        with open('../devices.json') as json_file:
            data = json.load(json_file)
            for p in data:
                if (v_target == str(q['type'])) or (v_target == "all"):
                    cmd = "timeout 5 ssh %s@%s%s killall saftd" % (p['login'], p['name'], p['extension'])
                    cmd_list.append(cmd)
    except (ValueError, KeyError, TypeError):
        print "JSON format error"
    for i in range(len(cmd_list)):
        cmd_to_perform = cmd_list[i].split()
        cmd_to_perform_info = cmd_to_perform[3]
        print "Stopping saftd at %s..." % (cmd_to_perform_info)
        subprocess.call(cmd_to_perform)
        time.sleep(1)
        print "----------------------------------------------------------------------------------------------------"

########################################################################################################################
def func_restart():
    # Restart saftd
    func_stop()
    print "Going to sleep for 10 seconds..."
    time.sleep(10+1)
    func_start()

########################################################################################################################
def func_reset():
    # Reset devices and hosts
    cmd_list = []
    try:
        with open('../devices.json') as json_file:
            data = json.load(json_file)
            for p in data:
                if (v_target == str(q['type'])) or (v_target == "all"):
                    if (v_target == str(q['type'])) or (v_target == "all"):
                        for q in p['receivers']:
                            cmd = "timeout 5 ssh %s@%s%s eb-reset %s" % (p['login'], p['name'], p['extension'], q['slot'])
                            cmd_list.append(cmd)
                        if p['reset2host'] == "no":
                            cmd = "timeout 5 ssh %s@%s%s reboot" % (p['login'], p['name'], p['extension'])
                            cmd_list.append(cmd)
    except (ValueError, KeyError, TypeError):
        print "JSON format error"
    for i in range(len(cmd_list)):
        cmd_to_perform = cmd_list[i].split()
        cmd_to_perform_info = cmd_to_perform[3]
        print "Resetting device(s) and host at %s..." % (cmd_to_perform_info)
        subprocess.call(cmd_to_perform)
        time.sleep(1)
        print "----------------------------------------------------------------------------------------------------"

########################################################################################################################
def func_flash():
    # Flash devices
    cmd_list = []
    try:
        with open('../devices.json') as json_file:
            data = json.load(json_file)
            for p in data:
                for q in p['receivers']:
                    if (v_target == str(q['type'])) or (v_target == "all"):
                        cmd = "timeout 5 ssh %s@%s%s rm %s.rpd" % (p['login'], p['name'], p['extension'], q['type'])
                        cmd_list.append(cmd)
                        if str(q['type']) == "ftm":
                            cmd = "timeout 10 ssh %s@%s%s wget %s/ftm/%s.rpd" % (p['login'], p['name'], p['extension'], v_gateware_source, q['type'])
                        else:
                            cmd = "timeout 10 ssh %s@%s%s wget %s/gateware/%s.rpd" % (p['login'], p['name'], p['extension'], v_gateware_source, q['type'])
                        cmd_list.append(cmd)
                        cmd = "timeout 60 ssh %s@%s%s eb-flash %s %s.rpd" % (p['login'], p['name'], p['extension'], q['slot'], q['type'])
                        cmd_list.append(cmd)
    except (ValueError, KeyError, TypeError):
        print "JSON format error"
    for i in range(len(cmd_list)):
        cmd_to_perform = cmd_list[i].split()
        cmd_to_perform_info = cmd_to_perform[3]
        print "Flashing device(s) at %s..." % (cmd_to_perform_info)
        subprocess.call(cmd_list[i].split())
        time.sleep(1)
        print "----------------------------------------------------------------------------------------------------"

########################################################################################################################
def main():
    # Get arguments
    cmdtotal = len(sys.argv)
    cmdargs = str(sys.argv)
    global v_target
    global v_operation
    global v_gateware_source

    # Plausibility check
    try:
        if cmdtotal == 3:
            v_operation = str(sys.argv[1])
            v_target = str(sys.argv[2])
        elif cmdtotal == 4:
            v_operation = str(sys.argv[1])
            v_target = str(sys.argv[2])
            v_gateware_source = str(sys.argv[3])
        else:
            print "Error: Please provide operation name [start target/stop target/restart target/probe target/reset target/{flash target [source URL]}"
            print "Targets: all scu2 scu3 pexarria5 exploder5 microtca pmc vetar2a vetar2a-ee-butis ftm"
            print "Flash example: flash all http://tsl002.acc.gsi.de/releases/doomsday"
            exit(1)
    except:
        print "Error: Could not parse given arguments!"
        exit(1)

    # Perform operation
    if v_operation == "start":
        func_start()
    elif v_operation == "stop":
        func_stop()
    elif v_operation == "restart":
        func_restart()
    elif v_operation == "probe":
        func_probe()
    elif v_operation == "reset":
        func_reset()
    elif v_operation == "flash":
        func_flash()
    else:
        exit(1)

    # Done
    exit(0)

# Main
if __name__ == "__main__":
    main()