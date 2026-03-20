#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════╗
# ║  GRITS — AI Agent Host Hardening (Docker)                                 ║
# ║  Ubuntu 24.04 LTS — CIS Benchmark + Docker Best Practices + DISA STIG          ║
# ║                                                                      ║
# ║  Run as root:  sudo bash harden-docker.sh                           ║
# ║  Run AFTER:    cleanup.sh (Docker installed, bloat removed)         ║
# ║  Review log:   /var/log/grits-harden.log                           ║
# ╚══════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ─── Configuration ────────────────────────────────────────────────────
# !! EDIT THESE before running !!

VPN_SUBNET="10.10.0.0/16"           # All local subnets
SSH_PORT=22                         # SSH port
APP_PORT=3000                      # Your agent/app port (adjust to your setup)
ADMIN_USER="admin"                     # Your SSH user
LOG="/var/log/grits-harden.log"

# ─── Helpers ──────────────────────────────────────────────────────────

G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; C='\033[0;36m'; NC='\033[0m'
log()  { echo -e "${G}[✓]${NC} $*" | tee -a "$LOG"; }
warn() { echo -e "${Y}[!]${NC} $*" | tee -a "$LOG"; }
err()  { echo -e "${R}[✗]${NC} $*" | tee -a "$LOG"; exit 1; }
banner() {
    echo "" | tee -a "$LOG"
    echo -e "${C}═══════════════════════════════════════════════════${NC}" | tee -a "$LOG"
    echo -e "${C}  $*${NC}" | tee -a "$LOG"
    echo -e "${C}═══════════════════════════════════════════════════${NC}" | tee -a "$LOG"
}

[[ $EUID -ne 0 ]] && err "Run as root: sudo bash harden-docker.sh"

echo "" | tee -a "$LOG"
echo "╔════════════════════════════════════════════════════╗" | tee -a "$LOG"
echo "║  AI Agent Host Hardening (Docker)                             ║" | tee -a "$LOG"
echo "║  $(date -Iseconds)                  ║" | tee -a "$LOG"
echo "╚════════════════════════════════════════════════════╝" | tee -a "$LOG"


# ═══════════════════════════════════════════════════════════════════════
#  PHASE 1: SSH Hardening
# ═══════════════════════════════════════════════════════════════════════

phase1_ssh() {
    banner "PHASE 1: SSH Hardening"

    # Backup
    cp /etc/ssh/sshd_config "/etc/ssh/sshd_config.bak.$(date +%Y%m%d)" 2>/dev/null || true

    mkdir -p /etc/ssh/sshd_config.d

    cat > /etc/ssh/sshd_config.d/99-grits-hardening.conf << SSHEOF
# ── GRITS SSH Hardening ──
# Generated: $(date -Iseconds)

AllowUsers ${ADMIN_USER}
Port ${SSH_PORT}

Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes

AllowTcpForwarding no
AllowAgentForwarding no
X11Forwarding no
PermitTunnel no

LoginGraceTime 30
MaxAuthTries 3
MaxSessions 3
ClientAliveInterval 300
ClientAliveCountMax 2

LogLevel VERBOSE

KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

Banner /etc/issue.net
SSHEOF

    # Login banner
    cat > /etc/issue.net << 'BANNEREOF'
╔════════════════════════════════════════════════════════════╗
║  AUTHORIZED ACCESS ONLY — All connections are logged.      ║
╚════════════════════════════════════════════════════════════╝
BANNEREOF

    # Validate before restarting
    if sshd -t 2>/dev/null; then
        systemctl restart ssh
        log "SSH hardened + restarted"
    else
        err "SSH config validation FAILED — removing hardening config"
        rm -f /etc/ssh/sshd_config.d/99-grits-hardening.conf
        systemctl restart ssh
    fi

    warn "TEST SSH IN ANOTHER TERMINAL BEFORE CLOSING THIS SESSION"
}


# ═══════════════════════════════════════════════════════════════════════
#  PHASE 2: Firewall (UFW)
# ═══════════════════════════════════════════════════════════════════════

phase2_firewall() {
    banner "PHASE 2: Firewall (UFW)"

    ufw --force reset

    ufw default deny incoming
    ufw default allow outgoing  # Docker needs outbound for pulls
    ufw default deny routed

    # Inbound from LAN/VPN only
    ufw allow from "$VPN_SUBNET" to any port "$SSH_PORT" proto tcp comment "SSH from LAN"
    ufw allow from "$VPN_SUBNET" to any port "$APP_PORT" proto tcp comment "Agent app from LAN"

    # Docker internal networking (needed for compose)
    ufw allow in on docker0

    # Loopback
    ufw allow in on lo
    ufw allow out on lo

    ufw --force enable
    log "Firewall enabled"
    ufw status verbose | tee -a "$LOG"
}


# ═══════════════════════════════════════════════════════════════════════
#  PHASE 3: Kernel Hardening (sysctl)
# ═══════════════════════════════════════════════════════════════════════

phase3_kernel() {
    banner "PHASE 3: Kernel Hardening"

    cat > /etc/sysctl.d/99-grits-hardening.conf << 'SYSEOF'
# ── GRITS Kernel Hardening ──

# IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP broadcasts
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Disable source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# SYN flood protection
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 0

# Log martian packets
net.ipv4.conf.all.log_martians = 1

# NOTE: ip_forward=1 is REQUIRED for Docker networking
net.ipv4.ip_forward = 1

# Memory protections
kernel.randomize_va_space = 2
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.yama.ptrace_scope = 2
kernel.sysrq = 0

# Filesystem protections
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.suid_dumpable = 0
SYSEOF

    sysctl -p /etc/sysctl.d/99-grits-hardening.conf 2>&1 | tee -a "$LOG"
    log "Kernel hardening applied"
}


# ═══════════════════════════════════════════════════════════════════════
#  PHASE 4: Fail2Ban
# ═══════════════════════════════════════════════════════════════════════

phase4_fail2ban() {
    banner "PHASE 4: Fail2Ban"

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

    systemctl enable fail2ban
    systemctl restart fail2ban
    log "Fail2Ban configured"
}


# ═══════════════════════════════════════════════════════════════════════
#  PHASE 5: Auditd
# ═══════════════════════════════════════════════════════════════════════

phase5_audit() {
    banner "PHASE 5: Audit Logging"

    cat > /etc/audit/rules.d/99-grits.rules << 'AUDITEOF'
-D
-b 8192
-f 1

# Auth & sudo
-w /etc/pam.d/ -p wa -k pam_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/sudoers -p wa -k sudoers_changes
-w /usr/bin/sudo -p x -k sudo_usage

# SSH
-w /etc/ssh/sshd_config -p wa -k sshd_config
-w /etc/ssh/sshd_config.d/ -p wa -k sshd_config

# Docker
-w /usr/bin/docker -p x -k docker_usage
-w /etc/docker/ -p wa -k docker_config
-w /var/lib/docker/ -p wa -k docker_data

# Firewall
-w /etc/ufw/ -p wa -k firewall_changes

# User changes
-w /etc/passwd -p wa -k user_changes
-w /etc/group -p wa -k group_changes

# Root commands
-a always,exit -F arch=b64 -F euid=0 -S execve -k root_commands

# Lock rules
-e 2
AUDITEOF

    augenrules --load 2>&1 | tee -a "$LOG" || true
    systemctl enable auditd
    systemctl restart auditd
    log "Audit logging configured (Docker commands tracked)"
}


# ═══════════════════════════════════════════════════════════════════════
#  PHASE 6: Docker Daemon Hardening
# ═══════════════════════════════════════════════════════════════════════

phase6_docker() {
    banner "PHASE 6: Docker Daemon Hardening"

    mkdir -p /etc/docker

    cat > /etc/docker/daemon.json << 'DOCKEREOF'
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "storage-driver": "overlay2",
    "live-restore": true,
    "userns-remap": "default",
    "no-new-privileges": true,
    "icc": false,
    "iptables": true,
    "default-ulimits": {
        "nofile": {
            "Name": "nofile",
            "Hard": 1024,
            "Soft": 512
        },
        "nproc": {
            "Name": "nproc",
            "Hard": 256,
            "Soft": 128
        }
    }
}
DOCKEREOF

    systemctl restart docker
    log "Docker daemon hardened (userns-remap, no-new-privileges, icc disabled)"

    warn "NOTE: userns-remap may require rebuilding existing containers"
}


# ═══════════════════════════════════════════════════════════════════════
#  PHASE 7: Automatic Security Updates
# ═══════════════════════════════════════════════════════════════════════

phase7_autoupdates() {
    banner "PHASE 7: Automatic Security Updates"

    # Re-install if removed during cleanup
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq unattended-upgrades apt-listchanges 2>/dev/null || true

    cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'UUEOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";
UUEOF

    cat > /etc/apt/apt.conf.d/20auto-upgrades << 'AUTOEOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
AUTOEOF

    log "Auto security updates: ON (reboot at 3 AM if needed)"
}


# ═══════════════════════════════════════════════════════════════════════
#  PHASE 8: Misc Hardening
# ═══════════════════════════════════════════════════════════════════════

phase8_misc() {
    banner "PHASE 8: Misc Hardening"

    # Lock root password
    passwd -l root 2>/dev/null || true
    log "Root password locked (use sudo)"

    # Harden /tmp
    if ! grep -q "^tmpfs /tmp" /etc/fstab; then
        echo "tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
        log "Hardened /tmp mount"
    fi

    # Disable core dumps
    echo "* hard core 0" > /etc/security/limits.d/99-no-core.conf
    log "Core dumps disabled"

    # Restrict su
    if ! grep -q "pam_wheel.so" /etc/pam.d/su; then
        echo "auth required pam_wheel.so use_uid group=sudo" >> /etc/pam.d/su
        log "Restricted su to sudo group"
    fi

    # Secure umask
    sed -i 's/^UMASK.*/UMASK   027/' /etc/login.defs 2>/dev/null || true
    log "Set umask to 027"
}


# ═══════════════════════════════════════════════════════════════════════
#  SUMMARY
# ═══════════════════════════════════════════════════════════════════════

print_summary() {
    banner "HARDENING COMPLETE"

    echo "" | tee -a "$LOG"
    echo "┌──────────────────────────────────────────────────────┐" | tee -a "$LOG"
    echo "│  AI Agent Host Hardening (Docker) — Summary                      │" | tee -a "$LOG"
    echo "├──────────────────────────────────────────────────────┤" | tee -a "$LOG"
    echo "│  ✓ SSH: key-only, ${ADMIN_USER} only, modern crypto  │" | tee -a "$LOG"
    echo "│  ✓ Firewall: LAN only (${VPN_SUBNET})               │" | tee -a "$LOG"
    echo "│  ✓ Kernel: sysctl hardening (Docker-compatible)      │" | tee -a "$LOG"
    echo "│  ✓ Fail2Ban: SSH brute-force protection              │" | tee -a "$LOG"
    echo "│  ✓ Auditd: Docker commands + auth tracked            │" | tee -a "$LOG"
    echo "│  ✓ Docker: userns-remap, no-new-privileges, icc off  │" | tee -a "$LOG"
    echo "│  ✓ Auto-updates: security patches at 3 AM            │" | tee -a "$LOG"
    echo "│  ✓ Root locked, core dumps disabled, /tmp hardened   │" | tee -a "$LOG"
    echo "├──────────────────────────────────────────────────────┤" | tee -a "$LOG"
    echo "│                                                      │" | tee -a "$LOG"
    echo "│  ⚠  TEST SSH in a new terminal NOW:                  │" | tee -a "$LOG"
    echo "│     ssh ${ADMIN_USER}@$(hostname -I | awk '{print $1}')  │" | tee -a "$LOG"
    echo "│                                                      │" | tee -a "$LOG"
    echo "│  DEPLOY:                                             │" | tee -a "$LOG"
    echo "│     # cd /opt/your-agent-app                                    │" | tee -a "$LOG"
    echo "│     docker compose up -d                             │" | tee -a "$LOG"
    echo "│                                                      │" | tee -a "$LOG"
    echo "│  LOG: ${LOG}                                         │" | tee -a "$LOG"
    echo "└──────────────────────────────────────────────────────┘" | tee -a "$LOG"
    echo ""
}


# ═══════════════════════════════════════════════════════════════════════
#  RUN ALL PHASES
# ═══════════════════════════════════════════════════════════════════════

phase1_ssh
phase2_firewall
phase3_kernel
phase4_fail2ban
phase5_audit
phase6_docker
phase7_autoupdates
phase8_misc
print_summary
