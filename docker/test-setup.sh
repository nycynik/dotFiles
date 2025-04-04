#!/bin/bash
# test-setup.sh

# Create answers file for automated testing
cat > /tmp/answers << EOL
1
testuser
test@example.com
supersecurepassphrase
/home/testuser/dev
y
EOL

# Run setup script with predefined answers
cat /tmp/answers | ./setup.sh
