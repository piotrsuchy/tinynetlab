#!/bin/bash

for i in {1..100}; do
    echo "Iteration ${i}"
    /setup_vrf.sh
    /teardown_vrf.sh
    if [ $? -ne 0 ]; then
        echo "Stopping loop at iteration $i due to VRF configuration found."
        break
    fi
done

