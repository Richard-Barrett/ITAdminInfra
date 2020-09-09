#!/bin/bash

# Check Security Benchmark on Cluster
echo "============================== SECURITY BENCHMARK CHECK PROCESS ==============================\N"
while true; do
    read -p "Do you want to check cluster security (yes/no)?" yn
    case $yn in
        [Yy]* ) echo "============================== SECURITY BENCHMARK CHECK IN PROGRESS ==============================\N"; \
                docker run -it --net host --pid host --cap-add audit_control \
                -v /var/lib:/var/lib \
                -v /var/run/docker.sock:/var/run/docker.sock \
                -v /usr/lib/systemd:/usr/lib/systemd \
                -v /etc:/etc --label docker_bench_security \
                docker/docker-bench-security; \
		echo "============================== SECURITY BENCHMARK CHECK IN SUCCESS ===============================\N"; \
                break;; \
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
