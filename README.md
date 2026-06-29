<div align="center">
  <h1>🚀 IMAGITECH AUTOSCRIPT - COMMUNITY EDITION</h1>
  <p><b>An automated, highly-resilient, and elite VPN & SSH orchestration engine built for modern VPS infrastructure.</b></p>
</div>

---

Imagitech Provisions a multi-protocol proxy environment complete with real-time tracking, aggressive bandwidth enforcement, multi-login prevention, anti-DDoS features, and a dynamic CLI dashboard. 

Built exclusively for **Ubuntu (20.04, 22.04, 24.04)** and **Debian (11, 12)** LTS to guarantee 100% stability.

## 🌟 Elite Features

### 🔌 Next-Gen Tunneling & Routing
- **OpenSSH & Dropbear:** Multi-port SSH tunneling (Ports 22, 109, 143, 8880).
- **Stunnel4 (SSL/TLS):** Encrypted TLS bridging and SNI routing (Ports 443, 447, 777).
- **Asynchronous WebSocket Proxy:** High-performance async WS multiplexer supporting HTTP Injection and ISP Bypassing on ports 80, 443, and 8880.
- **UDP Custom:** High-performance direct UDP tunneling for intensive gaming/voice packets (Ports 1-65535).
- **DNSTT (SlowDNS):** Advanced payload encapsulation through DNS queries for deeply restricted networks (Ports 53, 5300).
- **Dante SOCKS5 Proxy:** Standalone, high-speed SOCKS5 proxy (Port 1080).

### 🛡️ Security & Active Monitoring
- **Python-Powered Active Monitor:** A resilient Python background daemon (`daemon.py`) tracks active logins in real-time, strictly enforcing maximum concurrent logins.
- **Bandwidth Limits & Accounting:** Granular byte tracking using low-level `/proc/io` data, securely logged to an SQLite3 database. Enforces strict GB limits on accounts.
- **The OS Reaper:** Automatically eradicates Linux accounts and instantly drops connections the exact second a user's subscription expires.
- **Military-Grade Backups:** Uses AES-256-CBC with PBKDF2 to encrypt your database, TLS certificates, and DNS keys. Seamless SFTP disaster recovery.
- **TCP KeepAlives:** Enforced kernel-level heartbeats prevent Cloudflare and Azure from silently dropping idle connections.

## 📦 Zero-Touch Installation

To deploy the platform on a fresh Ubuntu or Debian server, run the following command as `root`:

```bash
apt update && apt upgrade -y
```

```bash
bash <(curl -sS -L https://raw.githubusercontent.com/imagi-tech/autoscriptssh/main/install.sh)
```

## 🛠️ Operations & Usage

Once the installation completes, manage your server securely:

1. **Interactive Dashboard:** Type `menu` to launch the beautiful and comprehensive TUI panel for managing users, monitoring connections, and modifying system settings.

<p align="center">
  <img src="https://github.com/user-attachments/assets/84a494f4-7f92-4c77-bd8d-31398cf2978d" alt="Dashboard & Menus" width="300">
</p>
   
2. **Headless Internal API:** Type `imagitech` followed by an API command to script automations natively.
   - Example: `imagitech user add test 12345 30 2 10` (Create user 'test', pass '12345', 30 days, 2 devices, 10GB Limit)
   - Example: `imagitech service restart all`

## 📂 System Architecture

The script strictly adheres to modern Linux engineering principles. It avoids polluting your global namespace; all configurations, python daemons, and databases are strictly sandboxed.

- `/opt/imagitech/core/`: SQLite3 Databases, SSL certificates, DNSTT public/private keys.
- `/opt/imagitech/services/`: Python engine (`daemon.py`) and Async Routing Proxy (`ws-proxy.py`).
- `/opt/imagitech/lib/`: Core bash logic modules.
- `/opt/imagitech/backups/`: Location for encrypted snapshots and disaster recovery via SFTP.

## ⚠️ Disclaimer
This software is intended for educational purposes, privacy enhancement, and legal network administration. Abuse of this service for spam, DDoS, or illegal operations is strictly prohibited. The developer takes no responsibility for misuse.


<div align="center">
  <p>
    <b>Subscribe</b> → <a href="https://t.me/imagivpnbot">@imagivpnbot</a><br>
    <b>Channel</b> → <a href="https://t.me/imagitech001">@imagitech001</a><br>
    <b>Developer</b> → <a href="https://t.me/DR34_M3R">†hε drεαmεr</a>
  </p>
</div>
