
#!/bin/bash
# =====================================================
# Author: Richard Barrett
# Date Created: 03/14/2020
# Organziation: Mirantis
# Purpose: Initalize Manual Logrotate on Openstack Logs
# =====================================================

# Rotate the following logs from salt master
sudo salt '*cmp*' cmd.run "sudo logrotate -f /etc/logrotate.d/telegraf"
sudo salt '*cmp*' cmd.run "sudo logrotate -f /etc/logrotate.d/td-agent"
sudo salt '*cmp*' cmd.run "sudo logrotate -f /etc/logrotate.d/nova-common"
sudo salt '*cmp*' cmd.run "sudo logrotate -f /etc/logrotate.d/neutron-common"
