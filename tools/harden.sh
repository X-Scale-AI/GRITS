#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════╗
# ║  GRITS Agent Host VM Hardening Script — Ubuntu 24.04 LTS                  ║
# ║  Based on CIS Benchmark Level 2 + DISA STIG principles             ║
# ║  Purpose: AI agent host, zero-trust hardened, VPN-only access            ║
# ║                                                                      ║
# ║  Run as root:  sudo bash harden.sh                                  ║
# ║  Review the log:  /var/log/grits-harden.log                         ║
# ╚══════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ─── Configuration ────────────────────────────────────────────────────
# !! EDIT THESE before running !!

VPN_SUBNET="10.0.0.0/24"          # Your Ubiquiti VPN subnet (adjust!)
SSH_PORT=22                         # Change if you want non-standard SSH port
APP_PORT=80                         # Agent application port
ADMIN_USER="admin"                    # Your admin SSH user (will be created if missing)
SERVICE_USER="agent-svc"                # Unprivileged service account (no login)
APP_DIR="/opt/agent"                # Application directory
SECRETS_DIR="${APP_DIR}/secrets"     # tmpfs mount for tokens (RAM only)
LOG="/var/log/grits-harden.log"

# ─── Helpers ──────────────────────────────────────────────────────────

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $*" | tee -a "$LOG"; }
warn() { echo -e "${YELLOW}[!]${NC} $*" | tee -a "$LOG"; }
err()  { echo -e "${RED}[✗]${NC} $*" | tee -a "$LOG"; }

banner() {
    echo "" | tee -a "$LOG"
    echo "═══════════════════════════════════════════════════════" | tee -a "$LOG"
    echo "  $*" | tee -a "$LOG"
    echo "═══════════════════════════════════════════════════════" | tee -a "$LOG"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        err "This script must be run as root (sudo bash harden.sh)"
        exit 1
    fi
}

check_ubuntu() {
    if ! grep -qi "ubuntu" /etc/os-release 2>/dev/null; then
        err "This script is designed for Ubuntu. Detected: $(cat /etc/os-release | head -1)"
        exit 1
    fi
    local ver
    ver=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)
    log "Detected Ubuntu ${ver}"
}

# ═══════════════════════════════════════════════════════════════════════
#  PHASE 1: System Updates & Base Packages
# ═══════════════════════════════════════════════════════════════════════

phase1_updates() {
    banner "PHASE 1: System Updates & Base Packages"

    log "Updating package lists..."
    apt-get update -qq

    log "Upgrading all packages..."
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq

    log "Installing essential packages..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        ufw \
        fail2ban \
        auditd \
        audispd-plugins \
        unattended-upgrades \
        apt-listchanges \
        libpam-pwquality \
        aide \
        rkhunter \
        acl \
        age \
        jq \
        curl \
        python3 \
        python3-venv \
        python3-pip \
        net-tools \
        2>&1 | tee -a "$LOG"

    log "Phase 1 complete."
}

# ═══════════════════════════════════════════════════════════════════════
#  PHASE 2: User Accounts & Access Control
# ═══════════════════════════════════════════════════════════════════════

phase2_users() {
    banner "PHASE 2: User Accounts & Access Control"

    # Create admin user if doesn't exist
    if ! id "$ADMIN_USER" &>/dev/null; then
        log "Creating admin user: ${ADMIN_USER}"
        adduser --disabled-password --gecos "" "$ADMIN_USER"
        usermod -aG sudo "$ADMIN_USER"
        warn "Set a password for ${ADMIN_USER}: passwd ${ADMIN_USER}"
        warn "Copy your SSH key: ssh-copy-id ${ADMIN_USER}@this-server"
    else
        log "Admin user ${ADMIN_USER} already exists."
        # Ensure they're in sudo group
        usermod -aG sudo "$ADMIN_USER" 2>/dev/null || true
    fi

    # Create service user (no login, no home, no shell)
    if ! id "$SERVICE_USER" &>/dev/null; then
        log "Creating service user: ${SERVICE_USER}"
        useradd -r -s /usr/sbin/nologin -M "$SERVICE_USER"
    else
        log "Service user ${SERVICE_USER} already exists."
    fi

    # Lock root account (disable direct root login)
    log "Locking root password (use sudo instead)..."
    passwd -l root 2>/dev/null || true

    # Set password aging policies (CIS 5.5.1)
    log "Setting password aging policies..."
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/' /etc/login.defs
    sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs

    # Restrict su to sudo group (CIS 5.7)
    log "Restricting su command to sudo group..."
    if ! grep -q "pam_wheel.so" /etc/pam.d/su; then
        echo "auth required pam_wheel.so use_uid group=sudo" >> /etc/pam.d/su
    fi

    # Set umask to 027 (CIS default)
    log "Setting default umask to 027..."
    sed -i 's/^UMASK.*/UMASK   027/' /etc/login.defs

    log "Phase 2 complete."
}

# ═══════════════════════════════════════════════════════════════════════
#  PHASE 3: SSH Hardening (CIS 5.3 / STIG)
# ═══════════════════════════════════════════════════════════════════════

phase3_ssh() {
    banner "PHASE 3: SSH Hardening"

    local SSHD_CONF="/etc/ssh/sshd_config"

    # Backup original
    cp "$SSHD_CONF" "${SSHD_CONF}.bak.$(date +%Y%m%d)"

    log "Writing hardened SSH config..."
    cat > /etc/ssh/sshd_config.d/99-grits-hardening.conf << SSHEOF
# ── GRITS Agent Host SSH Hardening ──
# Generated: $(date -Iseconds)

# Only allow specific user
AllowUsers ${ADMIN_USER}

# Port
Port ${SSH_PORT}

# Protocol & Authentication
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes

# Restrict forwarding & tunnels
AllowTcpForwarding no
AllowAgentForwarding no
X11Forwarding no
PermitTunnel no

# Timeouts & limits
LoginGraceTime 30
MaxAuthTries 3
MaxSessions 3
ClientAliveInterval 300
ClientAliveCountMax 2

# Logging
LogLevel VERBOSE

# Crypto (modern only — disable weak ciphers)
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

# Banner
Banner /etc/issue.net
SSHEOF

    # Login warning banner (STIG requirement)
    cat > /etc/issue.net << 'BANNEREOF'
╔═══════════════════════════════════════════════════════════════╗
║  AUTHORIZED ACCESS ONLY                                       ║
║  All connections are monitored and logged.                     ║
║  Unauthorized access will be prosecuted.                       ║
╚═══════════════════════════════════════════════════════════════╝
BANNEREOF

    # Validate config before restarting
    if sshd -t 2>/dev/null; then
        log "SSH config validated. Restarting sshd..."
        systemctl restart sshd
    else
        err "SSH config validation FAILED. Restoring backup."
        rm /etc/ssh/sshd_config.d/99-grits-hardening.conf
        systemctl restart sshd
        return 1
    fi

    warn "IMPORTANT: Ensure your SSH key is on this server before you disconnect!"
    warn "Test SSH in another terminal BEFORE closing this session."

    log "Phase 3 complete."
}

# ═══════════════════════════════════════════════════════════════════════
#  PHASE 4: Firewall (UFW — Only VPN Subnet)
# ═══════════════════════════════════════════════════════════════════════

phase4_firewall() {
    banner "PHASE 4: Firewall Configuration"

    log "Resetting UFW to defaults..."
    ufw --force reset

    # Default policies: deny everything
    ufw default deny incoming
    ufw default deny outgoing
    ufw default deny routed

    # Allow outbound essentials
    log "Allowing outbound: DNS, HTTPS, NTP..."
    ufw allow out 53/udp    comment "DNS"
    ufw allow out 53/tcp    comment "DNS"
    ufw allow out 443/tcp   comment "HTTPS (Agent APIs + package updates)"
    ufw allow out 80/tcp    comment "HTTP (package updates)"
    ufw allow out 123/udp   comment "NTP (time sync)"

    # Allow inbound ONLY from VPN subnet
    log "Allowing inbound from VPN subnet ${VPN_SUBNET} only..."
    ufw allow from "$VPN_SUBNET" to any port "$SSH_PORT" proto tcp  comment "SSH from VPN"
    ufw allow from "$VPN_SUBNET" to any port "$APP_PORT" proto tcp  comment "Agent app from VPN"

    # Allow loopback
    ufw allow in on lo
    ufw allow out on lo

    # Enable UFW
    log "Enabling firewall..."
    ufw --force enable

    log "Firewall rules:"
    ufw status verbose | tee -a "$LOG"

    log "Phase 4 complete."
}

# ═══════════════════════════════════════════════════════════════════════
#  PHASE 5: Kernel Hardening (sysctl — CIS 3.x / STIG)
# ═══════════════════════════════════════════════════════════════════════

phase5_kernel() {
    banner "PHASE 5: Kernel Hardening (sysctl)"

    cat > /etc/sysctl.d/99-grits-hardening.conf << 'SYSEOF'
# ── GRITS Agent Host Kernel Hardening ──
# Based on CIS Benchmark 3.x + DISA STIG

# ── Network: IP Spoofing & Routing ──
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# ── Network: ICMP Hardening ──
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# ── Network: Not a router ──
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# ── Network: TCP Hardening ──
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# ── Kernel: Memory & Process Protection ──
kernel.randomize_va_space = 2
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.perf_event_paranoid = 3
kernel.yama.ptrace_scope = 2
kernel.sysrq = 0
kernel.core_uses_pid = 1

# ── Kernel: Restrict unprivileged eBPF and userns ──
kernel.unprivileged_bpf_disabled = 1
kernel.unprivileged_userns_clone = 0

# ── FS: Hardlinks & Symlinks ──
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.suid_dumpable = 0
SYSEOF

    log "Applying sysctl settings..."
    sysctl -p /etc/sysctl.d/99-grits-hardening.conf 2>&1 | tee -a "$LOG"

    log "Phase 5 complete."
}

# ═══════════════════════════════════════════════════════════════════════
#  PHASE 6: Audit Logging (auditd — CIS 4.1 / STIG)
# ═══════════════════════════════════════════════════════════════════════

phase6_audit() {
    banner "PHASE 6: Audit Logging"

    cat > /etc/audit/rules.d/99-grits.rules << 'AUDITEOF'
# ── GRITS Agent Host Audit Rules ──

# Delete all existing rules (start clean)
-D

# Set buffer size
-b 8192

# Failure mode: 1=printk, 2=panic
-f 1

# Monitor authentication events
-w /etc/pam.d/ -p wa -k pam_changes
-w /etc/shadow -p wa -k shadow_changes
-w /var/log/auth.log -p wa -k auth_log

# Monitor sudo usage
-w /etc/sudoers -p wa -k sudoers_changes
-w /etc/sudoers.d/ -p wa -k sudoers_changes
-w /usr/bin/sudo -p x -k sudo_usage

# Monitor SSH config changes
-w /etc/ssh/sshd_config -p wa -k sshd_config
-w /etc/ssh/sshd_config.d/ -p wa -k sshd_config

# Monitor GRITS Agent Host secrets directory
-w /opt/grits/.env.age -p rwa -k grits_secrets
-w /opt/grits/.age-key -p rwa -k grits_secrets
-w /opt/grits/secrets/ -p rwa -k grits_tokens

# Monitor user/group changes
-w /etc/passwd -p wa -k user_changes
-w /etc/group -p wa -k group_changes

# Monitor cron
-w /etc/crontab -p wa -k cron_changes
-w /etc/cron.d/ -p wa -k cron_changes
-w /var/spool/cron/ -p wa -k cron_changes

# Monitor systemd service changes
-w /etc/systemd/ -p wa -k systemd_changes

# Monitor network config
-w /etc/hosts -p wa -k network_changes
-w /etc/ufw/ -p wa -k firewall_changes

# Log all commands by root
-a always,exit -F arch=b64 -F euid=0 -S execve -k root_commands

# Make rules immutable (requires reboot to change)
-e 2
AUDITEOF

    log "Loading audit rules..."
    augenrules --load 2>&1 | tee -a "$LOG"
    systemctl enable auditd
    systemctl restart auditd

    log "Phase 6 complete."
}

# ═══════════════════════════════════════════════════════════════════════
#  PHASE 7: Fail2Ban (Brute-Force Protection)
# ═══════════════════════════════════════════════════════════════════════

phase7_fail2ban() {
    banner "PHASE 7: Fail2Ban Configuration"

    cat > /etc/fail2ban/jail.local << F2BEOF
[DEFAULT]
bantime  = 3600
findtime = 600
maxretry = 3
backend  = systemd
banaction = ufw

[sshd]
enabled  = true
port     = ${SSH_PORT}
filter   = sshd
maxretry = 3
bantime  = 7200
F2BEOF

    log "Enabling and starting fail2ban..."
    systemctl enable fail2ban
    systemctl restart fail2ban

    log "Phase 7 complete."
}

# ═══════════════════════════════════════════════════════════════════════
#  PHASE 8: Automatic Security Updates
# ═══════════════════════════════════════════════════════════════════════

phase8_autoupdates() {
    banner "PHASE 8: Automatic Security Updates"

    cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'UUEOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
// Reboot if needed, at 3 AM (low-traffic maintenance window)
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";
UUEOF

    cat > /etc/apt/apt.conf.d/20auto-upgrades << 'AUTOEOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
AUTOEOF

    log "Automatic security updates configured."
    log "Phase 8 complete."
}

# ═══════════════════════════════════════════════════════════════════════
#  PHASE 9: Disable Unnecessary Services & Harden mounts
# ═══════════════════════════════════════════════════════════════════════

phase9_services() {
    banner "PHASE 9: Disable Unnecessary Services & Harden Mounts"

    # Disable services not needed on an agent host
    local DISABLE_SERVICES=(
        "avahi-daemon"       # mDNS (network discovery)
        "cups"               # Printing
        "bluetooth"          # Bluetooth
        "ModemManager"       # Modem management
        "whoopsie"           # Error reporting
        "apport"             # Crash reporting
        "snapd"              # Snap packages (not needed)
    )

    for svc in "${DISABLE_SERVICES[@]}"; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            log "Disabling: ${svc}"
            systemctl disable --now "$svc" 2>/dev/null || true
        fi
    done

    # Harden /tmp mount (CIS 1.1.4-5)
    log "Hardening /tmp mount options..."
    if ! grep -q "^tmpfs /tmp" /etc/fstab; then
        echo "tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
    fi

    # Harden /dev/shm (CIS 1.1.7)
    if ! grep -q "^tmpfs /dev/shm" /etc/fstab; then
        echo "tmpfs /dev/shm tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
    fi

    # Disable core dumps (CIS 1.6.1)
    log "Disabling core dumps..."
    echo "* hard core 0" > /etc/security/limits.d/99-no-core.conf
    if ! grep -q "fs.suid_dumpable" /etc/sysctl.d/99-grits-hardening.conf; then
        echo "fs.suid_dumpable = 0" >> /etc/sysctl.d/99-grits-hardening.conf
    fi

    # Disable USB storage (if not needed)
    log "Disabling USB storage module..."
    echo "install usb-storage /bin/true" > /etc/modprobe.d/disable-usb-storage.conf
    echo "blacklist usb-storage" >> /etc/modprobe.d/disable-usb-storage.conf

    log "Phase 9 complete."
}

# ═══════════════════════════════════════════════════════════════════════
#  PHASE 10: Application Directory & Secrets Infrastructure
# ═══════════════════════════════════════════════════════════════════════

phase10_app_setup() {
    banner "PHASE 10: Application Directory & Secrets Infrastructure"

    # Create app directory
    log "Creating application directory: ${APP_DIR}"
    mkdir -p "$APP_DIR"
    chown "${SERVICE_USER}:${SERVICE_USER}" "$APP_DIR"
    chmod 750 "$APP_DIR"

    # Create secrets directory (will be tmpfs)
    log "Creating secrets tmpfs mount: ${SECRETS_DIR}"
    mkdir -p "$SECRETS_DIR"

    # Add tmpfs to fstab (RAM-only, restricted perms)
    if ! grep -q "$SECRETS_DIR" /etc/fstab; then
        local SVC_UID
        SVC_UID=$(id -u "$SERVICE_USER")
        local SVC_GID
        SVC_GID=$(id -g "$SERVICE_USER")
        echo "tmpfs ${SECRETS_DIR} tmpfs size=2M,mode=700,uid=${SVC_UID},gid=${SVC_GID},noexec,nosuid,nodev 0 0" >> /etc/fstab
        mount "$SECRETS_DIR"
        log "tmpfs mounted at ${SECRETS_DIR} (tokens will only live in RAM)"
    else
        log "tmpfs already configured for ${SECRETS_DIR}"
    fi

    # Generate age encryption key for the service
    local AGE_KEY="${APP_DIR}/.age-key"
    if [[ ! -f "$AGE_KEY" ]]; then
        log "Generating age encryption key..."
        sudo -u "$SERVICE_USER" age-keygen -o "$AGE_KEY" 2>&1 | tee -a "$LOG"
        chmod 400 "$AGE_KEY"
        chown "${SERVICE_USER}:${SERVICE_USER}" "$AGE_KEY"

        local PUB_KEY
        PUB_KEY=$(grep "public key" "$AGE_KEY" | awk '{print $NF}')
        log "Age public key: ${PUB_KEY}"
        warn "Save this public key — you'll need it to encrypt .env on your Mac:"
        warn "  age -r ${PUB_KEY} -o .env.age .env"
    else
        log "Age key already exists at ${AGE_KEY}"
    fi

    # Create Python venv
    if [[ ! -d "${APP_DIR}/venv" ]]; then
        log "Creating Python virtual environment..."
        sudo -u "$SERVICE_USER" python3 -m venv "${APP_DIR}/venv"
        sudo -u "$SERVICE_USER" "${APP_DIR}/venv/bin/pip" install --quiet \
            fastapi uvicorn python-dotenv pandas requests 2>&1 | tee -a "$LOG"
    fi

    log "Phase 10 complete."
}

# ═══════════════════════════════════════════════════════════════════════
#  PHASE 11: systemd Service (Sandboxed)
# ═══════════════════════════════════════════════════════════════════════

phase11_systemd() {
    banner "PHASE 11: systemd Service Configuration"

    cat > /etc/systemd/system/grits.service << SVCEOF
[Unit]
Description=GRITS Hardened AI Agent Service
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/rizviz/GRITS

[Service]
Type=simple
User=${SERVICE_USER}
Group=${SERVICE_USER}
WorkingDirectory=${APP_DIR}
ExecStart=${APP_DIR}/venv/bin/python -m uvicorn server:app --host 0.0.0.0 --port ${APP_PORT}
Restart=on-failure
RestartSec=10
TimeoutStopSec=30

# ── Environment ──
EnvironmentFile=-${APP_DIR}/.env.decrypted
# The .env.decrypted is written to tmpfs at startup by ExecStartPre

# ── Sandboxing (systemd hardening) ──
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
PrivateDevices=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectKernelLogs=true
ProtectControlGroups=true
ProtectClock=true
ProtectHostname=true
RestrictRealtime=true
RestrictSUIDSGID=true
RestrictNamespaces=true
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
LockPersonality=true
MemoryDenyWriteExecute=true
SystemCallArchitectures=native

# Only allow these syscall families
SystemCallFilter=@system-service
SystemCallFilter=~@privileged @resources @mount @swap @reboot @cpu-emulation @debug @obsolete @raw-io

# Read-write only where needed
ReadWritePaths=${APP_DIR} ${SECRETS_DIR}
ReadOnlyPaths=/opt

# Limit resources
LimitNOFILE=1024
LimitNPROC=64

# Restrict capabilities
CapabilityBoundingSet=
AmbientCapabilities=

[Install]
WantedBy=multi-user.target
SVCEOF

    log "Reloading systemd..."
    systemctl daemon-reload

    warn "Service created but NOT started (deploy code first, then: systemctl enable --now grits)"

    log "Phase 11 complete."
}

# ═══════════════════════════════════════════════════════════════════════
#  PHASE 12: File Integrity Monitoring (AIDE)
# ═══════════════════════════════════════════════════════════════════════

phase12_integrity() {
    banner "PHASE 12: File Integrity Monitoring (AIDE)"

    # Add GRITS paths to AIDE config
    cat >> /etc/aide/aide.conf << 'AIDEEOF'

# GRITS Agent Host monitoring
/opt/agent/app.py  Full
/opt/agent/lib/       Full
/etc/systemd/system/grits.service Full
AIDEEOF

    log "Initializing AIDE database (this may take a few minutes)..."
    aideinit 2>&1 | tee -a "$LOG" || warn "AIDE init had warnings (normal on first run)"
    if [[ -f /var/lib/aide/aide.db.new ]]; then
        cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    fi

    # Daily AIDE check via cron
    cat > /etc/cron.daily/aide-check << 'CRONEOF'
#!/bin/bash
/usr/bin/aide --check --config=/etc/aide/aide.conf | mail -s "AIDE Report $(hostname)" root 2>/dev/null || true
CRONEOF
    chmod 700 /etc/cron.daily/aide-check

    log "Phase 12 complete."
}

# ═══════════════════════════════════════════════════════════════════════
#  PHASE 13: AppArmor Profile for GRITS
# ═══════════════════════════════════════════════════════════════════════

phase13_apparmor() {
    banner "PHASE 13: AppArmor (Mandatory Access Control)"

    # Ensure AppArmor is enabled
    if ! systemctl is-active --quiet apparmor; then
        systemctl enable --now apparmor
    fi
    log "AppArmor status: $(aa-status --enabled 2>&1 && echo 'enabled' || echo 'check needed')"

    # Create AppArmor profile for the agent host
    cat > /etc/apparmor.d/opt.grits.server << 'AAEOF'
#include <tunables/global>

/opt/grits/venv/bin/python {
  #include <abstractions/base>
  #include <abstractions/python>
  #include <abstractions/nameservice>
  #include <abstractions/openssl>

  # App directory
  /opt/grits/** r,
  /opt/agent/lib/** r,
  /opt/grits/venv/** r,
  /opt/grits/venv/bin/python ix,

  # Secrets (tmpfs)
  /opt/grits/secrets/ rw,
  /opt/grits/secrets/tokens.json rw,

  # Age key (read only)
  /opt/grits/.age-key r,

  # Network (agent external APIs)
  network inet stream,
  network inet6 stream,
  network inet dgram,

  # Python needs
  /usr/lib/python3/** r,
  /usr/lib/python3/dist-packages/** r,
  /tmp/** rw,
  /proc/self/** r,
  /proc/sys/net/** r,

  # Deny everything else
  deny /etc/shadow r,
  deny /etc/passwd w,
  deny /home/** rw,
  deny /root/** rw,
}
AAEOF

    log "Loading AppArmor profile (complain mode for now)..."
    apparmor_parser -r -C /etc/apparmor.d/opt.grits.server 2>&1 | tee -a "$LOG" || \
        warn "AppArmor profile load had issues — review manually"

    warn "AppArmor profile loaded in COMPLAIN mode."
    warn "After testing, switch to enforce: aa-enforce /etc/apparmor.d/opt.grits.server"

    log "Phase 13 complete."
}

# ═══════════════════════════════════════════════════════════════════════
#  FINAL: Summary & Next Steps
# ═══════════════════════════════════════════════════════════════════════

print_summary() {
    banner "HARDENING COMPLETE"

    echo "" | tee -a "$LOG"
    echo "┌───────────────────────────────────────────────────────┐" | tee -a "$LOG"
    echo "│  VM Hardening Summary                                 │" | tee -a "$LOG"
    echo "├───────────────────────────────────────────────────────┤" | tee -a "$LOG"
    echo "│  ✓ SSH: key-only, ${ADMIN_USER} only, port ${SSH_PORT}            │" | tee -a "$LOG"
    echo "│  ✓ Firewall: VPN subnet only (${VPN_SUBNET})   │" | tee -a "$LOG"
    echo "│  ✓ Kernel: CIS/STIG sysctl hardening applied         │" | tee -a "$LOG"
    echo "│  ✓ Audit: auditd monitoring secrets & auth            │" | tee -a "$LOG"
    echo "│  ✓ Fail2Ban: SSH brute-force protection               │" | tee -a "$LOG"
    echo "│  ✓ Auto-updates: Security patches at 3 AM             │" | tee -a "$LOG"
    echo "│  ✓ Services: Unnecessary daemons disabled             │" | tee -a "$LOG"
    echo "│  ✓ Secrets: tmpfs (RAM-only) for tokens               │" | tee -a "$LOG"
    echo "│  ✓ Age encryption: Ready for .env encryption          │" | tee -a "$LOG"
    echo "│  ✓ systemd: Sandboxed service with 18 restrictions    │" | tee -a "$LOG"
    echo "│  ✓ AIDE: File integrity monitoring                    │" | tee -a "$LOG"
    echo "│  ✓ AppArmor: Mandatory access control (complain mode) │" | tee -a "$LOG"
    echo "└───────────────────────────────────────────────────────┘" | tee -a "$LOG"
    echo "" | tee -a "$LOG"

    warn "═══ NEXT STEPS ═══"
    echo "" | tee -a "$LOG"
    echo "  1. TEST SSH in a NEW terminal before closing this session:" | tee -a "$LOG"
    echo "     ssh ${ADMIN_USER}@this-vm-ip" | tee -a "$LOG"
    echo "" | tee -a "$LOG"
    echo "  2. Deploy your agent code:" | tee -a "$LOG"
    echo "     scp -r your-agent-code/* ${ADMIN_USER}@vm-ip:/opt/grits/" | tee -a "$LOG"
    echo "" | tee -a "$LOG"
    echo "  3. Encrypt your .env on your Mac (using the age public key above):" | tee -a "$LOG"
    echo "     age -r <public-key> -o .env.age .env" | tee -a "$LOG"
    echo "     scp .env.age ${ADMIN_USER}@vm-ip:/opt/grits/" | tee -a "$LOG"
    echo "" | tee -a "$LOG"
    echo "  4. Copy tokens.json to tmpfs (first time):" | tee -a "$LOG"
    echo "     scp tokens.json ${ADMIN_USER}@vm-ip:/opt/grits/secrets/" | tee -a "$LOG"
    echo "" | tee -a "$LOG"
    echo "  5. Start the service:" | tee -a "$LOG"
    echo "     sudo systemctl enable --now grits" | tee -a "$LOG"
    echo "" | tee -a "$LOG"
    echo "  6. After testing, enforce AppArmor:" | tee -a "$LOG"
    echo "     sudo aa-enforce /etc/apparmor.d/opt.grits.server" | tee -a "$LOG"
    echo "" | tee -a "$LOG"

    log "Full log: ${LOG}"
}

# ═══════════════════════════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════════════════════════

main() {
    echo "$(date -Iseconds) — GRITS Agent Host VM Hardening Script" > "$LOG"

    check_root
    check_ubuntu

    echo ""
    echo "This script will harden this Ubuntu VM for GRITS Agent Host."
    echo "Configuration:"
    echo "  VPN Subnet:    ${VPN_SUBNET}"
    echo "  SSH Port:      ${SSH_PORT}"
    echo "  App Port:      ${APP_PORT}"
    echo "  Admin User:    ${ADMIN_USER}"
    echo "  Service User:  ${SERVICE_USER}"
    echo ""
    read -rp "Continue? (yes/no): " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "Aborted."
        exit 0
    fi

    phase1_updates
    phase2_users
    phase3_ssh
    phase4_firewall
    phase5_kernel
    phase6_audit
    phase7_fail2ban
    phase8_autoupdates
    phase9_services
    phase10_app_setup
    phase11_systemd
    phase12_integrity
    phase13_apparmor
    print_summary
}

main "$@"
