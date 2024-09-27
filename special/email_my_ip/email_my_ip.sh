#!/bin/bash

IP=$(hostname -I)

mail -s "Zig bootup email $IP" dom@apollotech.co << EOF
Have a nice day!
EOF

