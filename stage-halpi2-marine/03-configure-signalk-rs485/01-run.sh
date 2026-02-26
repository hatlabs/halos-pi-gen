#!/bin/bash -e

# Add HALPI2 RS-485 NMEA 0183 provider to Signal K settings.json.
# The file is installed by marine-signalk-server-container (via stage-halos-marine).

SETTINGS="${ROOTFS_DIR}/var/lib/container-apps/marine-signalk-server-container/data/data/settings.json"

python3 -c "
import json, sys

with open(sys.argv[1]) as f:
    settings = json.load(f)

settings['pipedProviders'].append({
    'id': 'halpi2-rs485',
    'pipeElements': [
        {
            'type': 'providers/serialport',
            'options': {
                'device': '/dev/ttyAMA4',
                'baudrate': 4800,
                'toStdout': 'nmea0183out'
            }
        },
        {
            'type': 'providers/nmea0183-signalk'
        }
    ],
    'enabled': True
})

with open(sys.argv[1], 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
" "${SETTINGS}"
