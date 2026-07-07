#!/bin/bash

# Linux System Security Check
# Basic security audit script
# Author: cyberbezpieczenstwo

set -u

echo "===================================="
echo " Linux System Security Check"
echo "===================================="
echo

# Check root privileges
if [ "$EUID" -ne 0 ]; then
    echo "[!] Run this script as root for complete results"
    echo "    Example: sudo ./system-security-check.sh"
    echo
fi

echo "[1] System information"
echo "------------------------------------"
hostnamectl 2>/dev/null || uname -a
echo


echo "[2] OS version"
echo "------------------------------------"
cat /etc/os-release 2>/dev/null | grep PRETTY_NAME
echo


echo "[3] Kernel version"
echo "------------------------------------"
uname -r
echo


echo "[4] Last system updates"
echo "------------------------------------"

if command -v apt >/dev/null 2>&1; then
    echo "Debian/Ubuntu based system"
    apt list --upgradable 2>/dev/null | head -20
elif command -v dnf >/dev/null 2>&1; then
    echo "Fedora/RHEL based system"
    dnf check-update 2>/dev/null | head -20
else
    echo "Package manager not detected"
fi

echo


echo "[5] Listening network services"
echo "------------------------------------"

if command -v ss >/dev/null 2>&1; then
    ss -tulnp
else
    netstat -tulnp 2>/dev/null || echo "Install iproute2 or net-tools"
fi

echo


echo "[6] Firewall status"
echo "------------------------------------"

if command -v ufw >/dev/null 2>&1; then
    ufw status
elif command -v firewall-cmd >/dev/null 2>&1; then
    firewall-cmd --state
else
    echo "No common firewall tool detected"
fi

echo


echo "[7] SSH configuration check"
echo "------------------------------------"

if [ -f /etc/ssh/sshd_config ]; then

    echo "PermitRootLogin:"
    grep "^PermitRootLogin" /etc/ssh/sshd_config || echo "Not configured"

    echo "PasswordAuthentication:"
    grep "^PasswordAuthentication" /etc/ssh/sshd_config || echo "Not configured"

else
    echo "SSH server configuration not found"
fi

echo


echo "[8] Users with login shells"
echo "------------------------------------"

cat /etc/passwd | grep -E "/bin/bash|/bin/sh"

echo


echo "[9] SUID files (potential security risk)"
echo "------------------------------------"

find / -perm -4000 -type f 2>/dev/null | head -30

echo


echo "[10] Failed login attempts"
echo "------------------------------------"

if command -v journalctl >/dev/null 2>&1; then
    journalctl -u ssh --no-pager 2>/dev/null | grep -i "failed" | tail -10
else
    echo "systemd journal not available"
fi

echo


echo "[11] Disk encryption status"
echo "------------------------------------"

if command -v lsblk >/dev/null 2>&1; then
    lsblk -f
fi

echo


echo "===================================="
echo " Security check completed"
echo "===================================="

echo
echo "Recommendations:"
echo "- Keep the system updated"
echo "- Disable unnecessary services"
echo "- Use SSH keys instead of passwords"
echo "- Enable firewall rules"
echo "- Review user permissions regularly"
echo "- Monitor authentication logs"
