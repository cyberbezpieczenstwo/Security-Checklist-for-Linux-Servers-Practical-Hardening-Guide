# SSH Hardening Guide

## Introduction

SSH (Secure Shell) is one of the most commonly used protocols for remote Linux server administration.

A default SSH installation is functional, but leaving it unchanged may expose the system to unnecessary risks such as brute-force attacks, unauthorized access attempts, and credential abuse.

SSH hardening is the process of improving the security of the SSH service by reducing the attack surface and applying stronger authentication methods.

The goal is not to hide SSH, but to configure it properly.

---

# 1. Keep OpenSSH Updated

The first step in securing SSH is keeping the OpenSSH server package updated.

Security vulnerabilities in SSH software are uncommon, but outdated packages can still expose systems to known issues.

## Debian / Ubuntu

```bash
sudo apt update
sudo apt upgrade openssh-server
````

## Fedora / RHEL

```bash
sudo dnf update openssh-server
```

Check the installed version:

```bash
ssh -V
```

---

# 2. Backup the SSH Configuration

Before making changes, create a backup of the current configuration.

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
```

This allows restoring the previous configuration if something goes wrong.

---

# 3. Disable Direct Root Login

Allowing direct root login over SSH is a common security risk.

If an attacker discovers the root password, they immediately gain full system access.

Edit:

```bash
sudo nano /etc/ssh/sshd_config
```

Set:

```text
PermitRootLogin no
```

Recommended approach:

* log in with a normal user account
* use `sudo` when administrative privileges are required

---

# 4. Use SSH Key Authentication

Password authentication is vulnerable to:

* brute-force attacks
* password reuse
* leaked credentials

SSH keys provide stronger authentication.

Generate an Ed25519 key:

```bash
ssh-keygen -t ed25519
```

Copy the public key to the server:

```bash
ssh-copy-id username@server-ip
```

After confirming key authentication works, disable password login:

```text
PasswordAuthentication no
```

---

# 5. Limit SSH Users

By default, any local user may attempt SSH access.

Restrict SSH access to specific accounts.

Example:

```text
AllowUsers admin backup
```

or using groups:

```text
AllowGroups sshusers
```

This reduces unnecessary exposure.

---

# 6. Change SSH Port (Optional)

The default SSH port is:

```text
22
```

Changing it can reduce automated scanning noise.

Example:

```text
Port 2222
```

However, this is not a real security mechanism.

A properly configured firewall, authentication, and monitoring are much more important.

---

# 7. Configure SSH Protocol Version

Modern OpenSSH uses protocol version 2.

Verify configuration:

```text
Protocol 2
```

Older SSH protocol versions should not be used.

---

# 8. Configure Login Attempts

Limit the number of authentication attempts.

Example:

```text
MaxAuthTries 3
```

This reduces the effectiveness of brute-force attacks.

---

# 9. Disable Unnecessary Features

If features are not required, disable them.

Example:

Disable X11 forwarding:

```text
X11Forwarding no
```

Disable empty passwords:

```text
PermitEmptyPasswords no
```

Disable TCP forwarding if not needed:

```text
AllowTcpForwarding no
```

Every enabled feature increases the potential attack surface.

---

# 10. Configure Firewall Rules

SSH should not necessarily be accessible from everywhere.

Example using UFW:

Allow SSH:

```bash
sudo ufw allow 22/tcp
```

Allow SSH only from a trusted network:

```bash
sudo ufw allow from 192.168.1.0/24 to any port 22
```

For production servers, consider:

* VPN access
* IP allowlists
* jump hosts

---

# 11. Monitor SSH Logs

Regular monitoring helps detect suspicious activity.

View SSH logs:

## Systemd systems

```bash
journalctl -u ssh
```

## Debian / Ubuntu

```bash
cat /var/log/auth.log
```

Look for:

* repeated failed logins
* unknown usernames
* unusual source IP addresses

---

# 12. Use Fail2Ban

Fail2Ban can automatically block IP addresses after repeated failed authentication attempts.

Install:

## Debian / Ubuntu

```bash
sudo apt install fail2ban
```

## Fedora

```bash
sudo dnf install fail2ban
```

Example protection:

* multiple failed SSH attempts
* temporary IP blocking
* automated abuse prevention

---

# 13. Additional Security Improvements

For higher security environments consider:

## Multi-factor authentication

Combine SSH keys with additional authentication factors.

Examples:

* TOTP codes
* hardware security keys
* FIDO2 devices

## Disable Internet Exposure

Instead of exposing SSH directly:

* use VPN access
* use private networks
* use bastion hosts

## Centralized Logging

For larger environments:

* forward authentication logs
* monitor events
* create alerts

---

# Recommended SSH Configuration Example

Example hardened configuration:

```text
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
MaxAuthTries 3
X11Forwarding no
AllowTcpForwarding no
```

Always test configuration before restarting SSH.

Validate:

```bash
sudo sshd -t
```

Restart:

```bash
sudo systemctl restart ssh
```

---

# Common SSH Hardening Mistakes

## Changing only the SSH port

Moving SSH from port 22 does not secure the service.

## Disabling passwords before testing keys

This can lock administrators out.

## Blocking SSH access without backup access

Always keep a recovery method.

## Applying random security settings

Security changes should have a purpose.

---

# Final Thoughts

SSH is one of the most reliable tools for managing Linux systems remotely, but it should not be left with default settings.

A secure SSH configuration is based on a few principles:

* use strong authentication
* remove unnecessary access
* limit users
* monitor activity
* keep software updated

Good security is usually not about adding more tools.

It is about reducing unnecessary risk.

---

## Author

Marek "Netbe" Lampart

Cybersecurity, Linux administration and infrastructure security.

Website:
[https://netbe.pl](https://netbe.pl)

