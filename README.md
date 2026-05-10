# Task 4.2 — Configuration Management "for the Poor"

## Overview

Bash scripts to deploy and verify an NTP server configuration on Ubuntu.

---

## Scripts

### `ntp_deploy.sh`

- Installs the NTP server package
- Removes default NTP server entries from `ntp.conf` (e.g. `0.ubuntu.pool.ntp.org`)
- Configures `ua.pool.ntp.org` as the sole NTP server
- Restarts the NTP service
- Registers `ntp_verify.sh` to run once per minute via cron

### `ntp_verify.sh`

- Checks whether the NTP process is running; starts it if not
- Checks `ntp.conf` for unauthorized changes:
  - Outputs the diff to stdout if changes are detected
  - Restores `ntp.conf` to its deployed state (`ua.pool.ntp.org` only)
  - Restarts the NTP service

---

## Additional Requirements

1. Both scripts must be uploaded to a GitHub repository named **`task4_2`**.
2. The repository must contain exactly two files: `ntp_deploy.sh` and `ntp_verify.sh`.
3. `ntp_verify.sh` may be run multiple times during task verification.

---

## Environment Setup Guide

This section describes how to spin up a local Ubuntu 16.04 environment that matches the grader's setup so you can verify the solution before submission.

### Option A — Docker (recommended, works on Windows / macOS / Linux)

**Prerequisites:** Docker Desktop installed and running.

```bash
# 1. Pull the Ubuntu 16.04 image
docker pull ubuntu:16.04

# 2. Start a privileged container (required for the 'service' command)
docker run -it --privileged --name ntp-test ubuntu:16.04 /bin/bash
```

Inside the container:

```bash
# 3. Install prerequisites
apt-get update && apt-get install -y git cron

# 4. Clone the repository (replace with your actual URL)
git clone https://github.com/<your-username>/task4_2 /root/task4_2
cd /root/task4_2

# 5. Run the deploy script
bash ntp_deploy.sh

# 6. Verify NTP config — should produce no output (no changes)
bash ntp_verify.sh

# 7. Simulate a config change, then verify again
sed -i 's/ua.pool.ntp.org/us.pool.ntp.org/' /etc/ntp.conf
bash ntp_verify.sh
# Expected: prints NOTICE header + unified diff, then restores the file

# 8. Simulate a stopped daemon, then verify
service ntp stop
bash ntp_verify.sh
# Expected: prints "NOTICE: ntp is not running" and starts the service

# 9. Confirm cron mail delivery (wait ~1 min after a config change)
cat /var/mail/root
```

To re-use the container later:

```bash
docker start -ai ntp-test
```

To start fresh:

```bash
docker rm ntp-test
```

---

### Option B — Vagrant (closer to bare-metal, good for cron testing)

**Prerequisites:** [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/) installed.

Create a `Vagrantfile` in any working directory:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y git
  SHELL
end
```

```bash
# Start and SSH into the VM
vagrant up
vagrant ssh

# Then follow steps 4–9 from Option A above (inside the VM)
sudo -i
git clone https://github.com/<your-username>/task4_2 /root/task4_2
cd /root/task4_2
bash ntp_deploy.sh
```

---

### Verification Checklist

| Check | Command | Expected result |
|---|---|---|
| NTP installed | `dpkg -l ntp` | Package listed |
| Only `ua.pool.ntp.org` in conf | `grep '^pool' /etc/ntp.conf` | Single line: `pool ua.pool.ntp.org iburst` |
| NTP running | `service ntp status` | `active (running)` |
| Backup exists | `ls /etc/ntp.conf.bak` | File present |
| Cron entry registered | `grep ntp_verify /etc/crontab` | Entry with `* * * * *` |
| Verify script — no diff | `bash ntp_verify.sh` | No output |
| Verify script — diff | Corrupt conf, then run script | NOTICE header + diff printed, conf restored |
| Verify script — daemon down | `service ntp stop && bash ntp_verify.sh` | NOTICE printed, daemon restarted |

---

## Verification Procedure

### Environment

- **OS:** Ubuntu Xenial 16.04 Server
- **User:** `root`
- **Pre-installed packages:** `sendmail`
- **Network:** internet access available

### Execution Rules

- The repository is cloned by URL (e.g. `https://github.com/user/task4_2`); a different repository name results in automatic failure.
- `ntp_deploy.sh` is launched automatically from the repository root; a different script name or subdirectory location results in automatic failure.
- `ntp_verify.sh` may also be run manually from the console without waiting for cron.

---

## Expected Behavior

### After `ntp_deploy.sh`

- `ntp.conf` must differ from the default only in the NTP server section, with `ua.pool.ntp.org` as the sole configured server.

### `ntp_verify.sh` — no changes detected

- Produces no output and does not restart the NTP service.

### `ntp_verify.sh` — changes detected in `ntp.conf`

- Prints the following header line to stdout:
  ```
  NOTICE: /etc/ntp.conf was changed. Calculated diff:
  ```
- Outputs the diff in **unified format** immediately after the header.
- Restores `ntp.conf` to the correct state (default settings + `ua.pool.ntp.org` only).
- Restarts the NTP daemon.

**Sample output:**

```diff
NOTICE: /etc/ntp.conf was changed. Calculated diff:
--- /etc/ntp.conf.bak   2018-03-27 16:45:40.693954805 +0000
+++ /etc/ntp.conf       2018-03-27 16:56:55.723992297 +0000
@@ -20 +20 @@
-pool ua.pool.ntp.org
+pool us.pool.ntp.org
```

### `ntp_verify.sh` — NTP daemon is stopped

- Outputs `NOTICE: ntp is not running` to stdout.
- Starts the NTP service.

> **Note:** When triggered via cron, stdout output is delivered to `/var/mail/root` and will be verified there.
