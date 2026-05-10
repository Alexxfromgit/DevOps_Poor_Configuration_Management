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
