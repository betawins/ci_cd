#!/bin/bash

# Get all ttf devices
source ../probe_0001/devices.sh

# Settings
duration=0
end_test=0
trap=0
test_failed=0
success_count=0
fail_count=0
iter_count=0
schedule_given=0
duts=0
gateway_fail_count=0
gateway_success_count=0
gateway_capture_done=0

# Data master settings
schedule="schedule.xml"
schedule_ts="schedule_ts.xml"
dm_schedule_keyword="___STARTTIME___"
dm_start_offset=0x00000000200000000
dm_start_time=0x0

# Stop/start logging ($1 = 0/1 (stop/start_and_configure), $2 = 0/1 (configure saftlib/configure LEDs)
function control_logging()
{
  if [ $1 -eq 0 ]; then
    # Stop logging
    # Pexarias
    pex_id=0
    for i in ${ttf_pexaria_names[@]}; do
      echo "Stopping logging... ($i@${ttf_pexaria_hosts[$pex_id]})"
      ssh $ttf_pexaria_user@${ttf_pexaria_hosts[$pex_id]}.$tff_postfix "killall saft-ctl" > /dev/null 2>&1
      pex_id=$((pex_id+1))
    done
    # SCUs
    scu_id=0
    for i in ${ttf_scu_names[@]}; do
      echo "Stopping logging... ($i@${ttf_scu_hosts[$scu_id]})"
      ssh $ttf_scu_user@${ttf_scu_hosts[$scu_id]}.$tff_postfix "killall saft-ctl" > /dev/null 2>&1
      scu_id=$((scu_id+1))
    done
    # Vetars
    vetar_id=0
    for i in ${ttf_vetar_names[@]}; do
      echo "Stopping logging... ($i@${ttf_vetar_hosts[$vetar_id]})"
      ssh $ttf_vetar_user@${ttf_vetar_hosts[$vetar_id]}.$tff_postfix "killall saft-ctl" > /dev/null 2>&1
      vetar_id=$((vetar_id+1))
    done
  else
    # Start logging, remove old log files and filter PPS events
    # Pexarias
    pex_id=0
    for i in ${ttf_pexaria_names[@]}; do
      if [ $2 -eq 0 ]; then
        echo "Starting logging... ($i@${ttf_pexaria_hosts[$pex_id]})"
        rm log/snooped_events_$i.txt
        ssh $ttf_pexaria_user@${ttf_pexaria_hosts[$pex_id]}.$tff_postfix "saft-ctl $i snoop 0x0 0x0 0 -x | grep -v \"EvtID: 0xffff000000000000\"" > log/snooped_events_$i.txt &
      else
        echo "Configuring LEDs... ($i@${ttf_pexaria_hosts[$pex_id]})"
        #ssh $ttf_pexaria_user@${ttf_pexaria_hosts[$pex_id]}.$tff_postfix "saft-io-ctl $i -n LED1_ADD_R -x;\
        #                                                                  saft-io-ctl $i -n LED2_ADD_B -x;\
        #                                                                  saft-io-ctl $i -n LED3_ADD_G -x;\
        #                                                                  saft-io-ctl $i -n LED4_ADD_W -x;\
        #                                                                  saft-io-ctl $i -n LED1_BASE_R -x;\
        #                                                                  saft-io-ctl $i -n LED2_BASE_B -x;\
        #                                                                  saft-io-ctl $i -n LED3_BASE_G -x;\
        #                                                                  saft-io-ctl $i -n LED4_BASE_W -x;"
        #ssh $ttf_pexaria_user@${ttf_pexaria_hosts[$pex_id]}.$tff_postfix "saft-io-ctl $i -n LED1_ADD_R -c 0x0 0x0 0 0xf 1 -u;\
        #                                                                  saft-io-ctl $i -n LED1_ADD_R -c 0x0 0x0 31250000 0xf 0 -u;\
        #                                                                  saft-io-ctl $i -n LED2_ADD_B -c 0x0 0x0 0 0xf 1 -u;\
        #                                                                  saft-io-ctl $i -n LED2_ADD_B -c 0x0 0x0 62500000 0xf 0 -u;\
        #                                                                  saft-io-ctl $i -n LED3_ADD_G -c 0x0 0x0 0 0xf 1 -u;\
        #                                                                  saft-io-ctl $i -n LED3_ADD_G -c 0x0 0x0 125000000 0xf 0 -u;\
        #                                                                  saft-io-ctl $i -n LED4_ADD_W -c 0x0 0x0 0 0xf 1 -u;\
        #                                                                  saft-io-ctl $i -n LED4_ADD_W -c 0x0 0x0 250000000 0xf 0 -u;\
        #                                                                  saft-io-ctl $i -n LED1_BASE_R -c 0x0 0x0 0 0xf 1 -u;\
        #                                                                  saft-io-ctl $i -n LED1_BASE_R -c 0x0 0x0 31250000 0xf 0 -u;\
        #                                                                  saft-io-ctl $i -n LED2_BASE_B -c 0x0 0x0 0 0xf 1 -u;\
        #                                                                  saft-io-ctl $i -n LED2_BASE_B -c 0x0 0x0 62500000 0xf 0 -u;\
        #                                                                  saft-io-ctl $i -n LED3_BASE_G -c 0x0 0x0 0 0xf 1 -u;\
        #                                                                  saft-io-ctl $i -n LED3_BASE_G -c 0x0 0x0 125000000 0xf 0 -u;\
        #                                                                  saft-io-ctl $i -n LED4_BASE_W -c 0x0 0x0 0 0xf 1 -u;\
        #                                                                  saft-io-ctl $i -n LED4_BASE_W -c 0x0 0x0 250000000 0xf 0 -u;"
      fi
      pex_id=$((pex_id+1))
    done
    # SCUs
    scu_id=0
    for i in ${ttf_scu_names[@]}; do
      if [ $2 -eq 0 ]; then
        echo "Starting logging... ($i@${ttf_scu_hosts[$scu_id]})"
        rm log/snooped_events_$i.txt
        ssh $ttf_scu_user@${ttf_scu_hosts[$scu_id]}.$tff_postfix "saft-ctl baseboard snoop 0x0 0x0 0 -x | grep -v \"EvtID: 0xffff000000000000\"" > log/snooped_events_$i.txt &
      else
        echo "Configuring LEDs... ($i@${ttf_scu_hosts[$scu_id]})"
      fi
      scu_id=$((scu_id+1))
    done
    # Vetars
    vetar_id=0
    for i in ${ttf_vetar_names[@]}; do
      if [ $2 -eq 0 ]; then
        echo "Starting logging... ($i@${ttf_vetar_hosts[$vetar_id]})"
        rm log/snooped_events_$i.txt
        ssh $ttf_vetar_user@${ttf_vetar_hosts[$vetar_id]}.$tff_postfix "saft-ctl baseboard snoop 0x0 0x0 0 -x | grep -v \"EvtID: 0xffff000000000000\"" > log/snooped_events_$i.txt &
      else
        echo "Configuring LEDs... ($i@${ttf_vetar_hosts[$vetar_id]})"
        #ssh $ttf_vetar_user@${ttf_vetar_hosts[$vetar_id]}.$tff_postfix "saft-io-ctl baseboard -n LED9 -x;\
        #                                                                saft-io-ctl baseboard -n LED10 -x;\
        #                                                                saft-io-ctl baseboard -n LED11 -x;\
        #                                                                saft-io-ctl baseboard -n LED12 -x;\
        #                                                                saft-io-ctl baseboard -n LED_DACK -x;"
        #ssh $ttf_vetar_user@${ttf_vetar_hosts[$vetar_id]}.$tff_postfix "saft-io-ctl baseboard -n LED9 -c 0x0 0x0 0 0xf 1 -u;\
        #                                                                saft-io-ctl baseboard -n LED9 -c 0x0 0x0 31250000 0xf 0 -u;\
        #                                                                saft-io-ctl baseboard -n LED10 -c 0x0 0x0 0 0xf 1 -u;\
        #                                                                saft-io-ctl baseboard -n LED10 -c 0x0 0x0 62500000 0xf 0 -u;\
        #                                                                saft-io-ctl baseboard -n LED11 -c 0x0 0x0 0 0xf 1 -u;\
        #                                                                saft-io-ctl baseboard -n LED11 -c 0x0 0x0 125000000 0xf 0 -u;\
        #                                                                saft-io-ctl baseboard -n LED12 -c 0x0 0x0 0 0xf 1 -u;\
        #                                                                saft-io-ctl baseboard -n LED12 -c 0x0 0x0 250000000 0xf 0 -u;\
        #                                                                saft-io-ctl baseboard -n LED_DACK -c 0x0 0x0 0 0xf 1 -u;\
        #                                                                saft-io-ctl baseboard -n LED_DACK -c 0x0 0x0 31250000 0xf 0 -u;"
      fi
      vetar_id=$((vetar_id+1))
    done
  fi
}

# Compare log files
function compare_log_files()
{
  # Check all devices
  devices=( ${ttf_pexaria_names[@]} ${ttf_scu_names[@]} ${ttf_vetar_names[@]} )
  duts=${#devices[@]}
  # Sort event lists
  for i in ${devices[@]}; do
    # Get time stamp, event id and parameter
    cat log/snooped_events_$i.txt | awk '{print $2 " " $4 " " $6}' | cut -c 1-56 > log/temp_$i.txt
    # Sort file by time stamp
    sort -k1 -n log/temp_$i.txt > log/s_cmp_$i.txt
    rm log/temp_$i.txt
  done
  
  # Compare log files
  for i in ${devices[@]}; do
    cmp log/s_cmp_$i.txt log/e_cmp.txt
    if [ $? -ne 0 ]; then
      echo "Device $i missed or got different events!"
      fail_count=$((fail_count+1))
      test_failed=1
    else
      echo "Device $i got all expected events!"
      success_count=$((success_count+1))
    fi
  done
}

# Trap CTRL+C
function ctrl_c()
{
  echo "\n*** Trapped CTRL-C***\n"
  end_test=1
  trap=1
  echo "Stopping data master..."
  ftm-ctl $ttf_data_master -c $ttf_data_master_traffic_core_id idle
  ftm-ctl $ttf_data_master -c $ttf_data_master_traffic_core_id stop
  echo "Stopping devices..."
  control_logging 0
  killall tcpdump # !!!
  exit 1
}

# Start data master and set start time in schedule
function start_data_master()
{
  # Copy old schedule
  cp "log/$schedule" "log/$schedule_ts"
  
  # Get time from ECA
  dm_time=`ftm-ctl $ttf_data_master -t | grep "ECA TIME" | cut -c 32-49`
  dm_time="$(($dm_time+0))" # To dec
  dm_start_time="$(($dm_time+$dm_start_offset))" # Add offset
  echo $dm_start_time > log/start_time.txt
  
  # Print debug infos
  printf "Current time at Data Master: 0x%x (%d)\n" $dm_time $dm_time
  printf "Start time at Data Master:   0x%x (%d)\n" $dm_start_time $dm_start_time
  
  # Get right start time in the schedule
  sed -i "s/$dm_schedule_keyword/$dm_start_time/g" "log/$schedule_ts"
  
  # Finally set up the Data Master
  ftm-ctl $ttf_data_master -c $ttf_data_master_traffic_core_id preptime 500000
  echo "DM Set Preptime 500000..."
  ftm-ctl $ttf_data_master -c $ttf_data_master_traffic_core_id put log/$schedule_ts
  echo "DM Put..."
  ftm-ctl $ttf_data_master -c $ttf_data_master_traffic_core_id swap
  echo "DM Swap..."
  ftm-ctl $ttf_data_master -c $ttf_data_master_traffic_core_id run
  echo "DM Run..."
}

# Wait until schedule should have finished
function poll_dm_time()
{
  # Get time from ECA
  dm_time_now=`ftm-ctl $ttf_data_master -t | grep "ECA TIME" | cut -c 32-49`
  dm_time_now="$(($dm_time_now+0))" # To dec
  dm_duration_ns="$((${duration%.*}*1000000000))"
  dm_end_time="$(($dm_start_time+$dm_duration_ns))"
  time_left="$(($dm_end_time-$dm_time_now))"
  
  # Wait for end of schedule
  while [ $time_left -ge 0 ]; do
    sleep 0.5
    printf "\rTest will finish in: %dns..." "$time_left"
    dm_time_now=`ftm-ctl $ttf_data_master -t | grep "ECA TIME" | cut -c 32-49`
    dm_time_now="$(($dm_time_now+0))" # To dec
    time_left="$(($dm_end_time-$dm_time_now))"
  done
  printf "\rTest will finish in: %dns...                                   " "0"
  printf "\n\n\n"
}

# Display help (and possible arguments)
function help()
{
  echo ""
  echo "Usage:"
  echo "$0 <loops> <mode> (will use a random schedule)"
  echo "or"
  echo "$0 <loops> <mode> <schedule> (will use the given random)"
  echo ""
  echo "Arguments:"
  echo "  loops:"
  echo "         0 -> Schedule will run forever"
  echo "         n -> Run schedule n times"
  echo "  mode:"
  echo "         0 -> Ignore error(s) and keep running"
  echo "         1 -> Stop run error"
}

# Start testing
echo "======================================================================"
echo "Test started..."
# Catch CTRL+C
trap ctrl_c INT
# Check arguments
if test "$#" -eq 2; then
  test_loops=$1
  test_mode=$2
elif test "$#" -eq 3; then
  test_loops=$1
  test_mode=$2
  test_case=$3
  schedule_given=1
else
  help
  exit 1
fi

# Setup LEDs
control_logging 1 1

while [ $end_test -eq 0 ]; do
  echo "Date:"
  date
  echo "Uptime:"
  uptime
  echo ""
  # Clean up
  control_logging 0 0
  # Generate new or copy given schedule
  if [ $schedule_given -eq 0 ]; then
    ./generate.py
  else
    cp $test_case log/$schedule
  fi
  start_data_master
  ./parse.py log/$schedule_ts
  control_logging 1 0
 ./capture_dev.sh $ttf_gateway_interface $ttf_data_master_ip &
  sleep 5
  
  # Wait until all events were send
  duration=`cat log/duration.txt`
  poll_dm_time
  sleep 5
  control_logging 0 0
  killall tcpdump
  sleep 5
  
  #Sort event lists
  sort -k1 -n log/expected_events.txt > log/e_cmp.txt
  
  # Finally compare the lists
  compare_log_files
  
  #sleep 5  # !!!
  # Wait for capture.sh script
  while [ $gateway_capture_done -eq 0 ]; do
    ps | grep capture_dev.sh > /dev/null
    if [ $? -eq 1 ]; then
      gateway_capture_done=1
      echo "Gateway $ttf_gateway_host capture process done!"
    fi
  done
  
  cmp log/s_cmp_$ttf_gateway_host.txt log/e_cmp.txt  # !!!
  if [ $? -eq 0 ]; then
    gateway_success_count=$((gateway_success_count+1))
    echo "Gateway $ttf_gateway_host got all expected events!"
  else
    gateway_fail_count=$((gateway_fail_count+1))
    echo "Gateway $ttf_gateway_host missed or got different events!"
  fi
  
  # Check for other errors
  if [ $trap -eq 1 ]; then
    end_test=1
  fi
  if [ $test_mode -ne 0 ]; then
    if [ $test_failed -ne 0 ]; then
      end_test=1
    fi
  fi
  
  # Check for other conditions
  iter_count=$((iter_count+1))
  if [ $test_loops -ne 0 ]; then
    if [ $iter_count -eq $test_loops ]; then
      end_test=1
    fi
  fi
  
  # Small report
  echo "Iteration count:       $iter_count"
  echo "Devices under test:    $duts"
  echo "Success count:         $success_count"
  echo "Fail count:            $fail_count"
  echo "Gateway success count: $gateway_success_count"
  echo "Gateway fail count:    $gateway_fail_count"
  echo "Test done!"
  echo ""
  echo "======================================================================"
  echo ""
  sleep 3
done
