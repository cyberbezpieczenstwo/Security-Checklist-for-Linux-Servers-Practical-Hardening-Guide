#!/bin/bash

echo "Checking listening network services..."
echo

ss -tulnp

echo
echo "Review services exposed to network before allowing external access."
