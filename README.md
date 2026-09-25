<p align="center">
  <h1 align="center">Nipe</h1>
  <p align="center"><strong>An engine to make Tor Network your default gateway.</strong></p>
  <p align="center">
    <a href="LICENSE.md">
      <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License">
    </a>
    <a href="https://github.com/Tagbirulmohoshin781/nipe/releases">
      <img src="https://img.shields.io/badge/version-1.0.0-blue.svg" alt="Version 1.0.0">
    </a>
    <img src="https://img.shields.io/badge/tests-passing-brightgreen.svg" alt="Tests Passing">
    <img src="https://img.shields.io/badge/tor-transparent%20proxy-purple.svg" alt="Tor Proxy">
  </p>
</p>

---

### Summary

The Tor project allows users to surf the Internet, chat, and communicate anonymously through onion routing. Nipe is an engine developed in Perl that routes all traffic from your machine to the Internet through the Tor network, providing enhanced privacy and anonymity in cyberspace.

Nipe supports both **IPv4 and IPv6** traffic routing:
- Transparent proxying using `iptables` and `ip6tables`.
- Traffic destined for loopback (`lo`) and local network ranges is preserved.
- Non-TCP traffic (UDP/ICMP) outside of local DNS is explicitly rejected to eliminate deanonymization leaks.
- Universal distribution support: Kali Linux, Debian, Ubuntu, Fedora, CentOS, RHEL, Arch Linux, Void Linux, and openSUSE.

---

### Download & Installation

```bash
# Clone the repository
git clone https://github.com/Tagbirulmohoshin781/nipe.git && cd nipe

# Install Perl library dependencies
cpanm --installdeps .

# Install system dependencies (Tor, iptables)
sudo perl nipe.pl install
```

---

### Usage & Commands

```
COMMAND / FLAG     FUNCTION                                   PRIVILEGE
install            Install system dependencies                Root (sudo)
start              Start transparent routing through Tor      Root (sudo)
stop               Stop routing and restore clearnet rules    Root (sudo)
restart            Restart circuit & refresh Tor exit node    Root (sudo)
status             Check routing status and public IP         User / Root
help, -h, --help   Display usage documentation                User / Root
-v, --version      Display version information                User / Root
```

#### Examples:

```bash
# Check status without root:
perl nipe.pl status

# Start routing through Tor:
sudo perl nipe.pl start

# Rebuild Tor circuit (get a new exit IP):
sudo perl nipe.pl restart

# Return to clearnet:
sudo perl nipe.pl stop
```

---

### Docker Container

```bash
# Build the container
docker build -t nipe .

# Run with NET_ADMIN capability for iptables
docker run -d -it --name nipe-container --privileged --cap-add=NET_ADMIN nipe

# Run commands inside container
docker exec -it nipe-container ./nipe.pl status
docker exec -it nipe-container ./nipe.pl start
```

---

### Automated Testing & Verification

Nipe includes both Perl unit tests and a multi-stage QA verification suite:

```bash
# Run Perl test harness
prove -l t/

# Run the comprehensive QA test runner
python verify_project.py
```

---

### Security & Privacy Architecture

- **Leak Prevention**: All non-Tor UDP and ICMP traffic is dropped to prevent DNS or IP leaks.
- **Circuit Isolation**: Re-routing flushes the output chain cleanly to ensure no orphaned redirect rules remain.
- **Fail-safe Fallback**: Status checking features resilient fallback mechanisms to ensure accurate connection diagnosis.

---

### License

This project is licensed under the [MIT License](LICENSE.md).