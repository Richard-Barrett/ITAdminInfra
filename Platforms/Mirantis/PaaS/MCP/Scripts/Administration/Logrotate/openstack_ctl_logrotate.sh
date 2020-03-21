#!/bin/bash
# =====================================================
# Author: Richard Barrett
# Date Created: 03/14/2020
# Organziation: Mirantis
# Purpose: Initalize Manual Logrotate on Openstack Logs
# =====================================================

# Rotate the following logs from salt master
sudo salt '*ctl*' cmd.run "sudo logrotate -f /etc/logrotate.d/keystone"
sudo salt '*ctl*' cmd.run "sudo logrotate -f /etc/logrotate.d/cinder-common"
sudo salt '*ctl*' cmd.run "sudo logrotate -f /etc/logrotate.d/glance-common"
sudo salt '*ctl*' cmd.run "sudo logrotate -f /etc/logrotate.d/nova-common"
sudo salt '*ctl*' cmd.run "sudo logrotate -f /etc/logrotate.d/neutron-common"
sudo salt '*ctl*' cmd.run "sudo logrotate -f /etc/logrotate.d/heat-common"
