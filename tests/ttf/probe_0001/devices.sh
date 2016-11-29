#!/bin/bash

# Devices and hosts under test
ttf_pexaria_names=(pexaria5_27t pexaria5_41t pexaria5_15t pexaria5_43t)
ttf_pexaria_hosts=(tsl011 tsl011 tsl011 tsl011)
ttf_pexaria_ipv4=(192.168.191.91 192.168.191.110 192.168.191.79 192.168.191.112)
ttf_pexaria_dev_ids=(dev/wbm0 dev/wbm1 dev/wbm2 dev/wbm3)
ttf_pexaria_user=root

ttf_scu_names=(scuxl0001t scuxl0099t scuxl0007t scuxl0085t scuxl0088t scuxl0133t)
ttf_scu_hosts=(scuxl0001 scuxl0099 scuxl0007 scuxl0085 scuxl0088 scuxl0133)
ttf_scu_ipv4=(192.168.135.1 192.168.135.99 192.168.135.7 192.168.191.85 192.168.135.88 192.168.191.133)
ttf_scu_dev_id=dev/wbm0
ttf_scu_user=root

ttf_vetar_names=(vetar14t)
ttf_vetar_hosts=(kp1cx01)
ttf_vetar_ipv4=(192.168.191.118)
ttf_vetar_dev_id=dev/wbm0
ttf_vetar_user=root

ttf_exploder_names=(exploder5_11t)
ttf_exploder_hosts=(tsl012)
ttf_exploder_ipv4=(192.168.191.153)
ttf_exploder_dev_id=dev/wbm1
ttf_exploder_user=root

# Data master(s)
ttf_data_master="udp/192.168.191.92"
ttf_data_master_ip="192.168.191.92"
ttf_data_master_backup="udp/192.168.191.96"
ttf_data_master_backup_ip="192.168.191.96"
ttf_data_master_host="tsl010"
ttf_data_master_pps_core_id=0
ttf_data_master_traffic_core_id=1

# Other defines and constants
ttf_gateway_host="tsl011"
ttf_gateway_user="root"
ttf_gateway_interface="eth5"
tff_postfix="acc.gsi.de"
ttf_default_saft_dev="baseboard"
