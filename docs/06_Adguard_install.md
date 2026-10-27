# Setting up Adguard for Home server

## 1. Static IP

A DNS server must not change address. A static IP was set in netplan.

Verify:

```bash
ip -4 addr show wlp1s0     # should show inet <SERVER-IP>/22
ip route | grep default
```


## 2. Free up port 53

Ubuntu's `systemd-resolved` runs a "stub listener" on pot 53, which blocks AdGuard from binding port 53.

Check what holds the port:

```bash
sudo ss -lunpt | grep ':53 '
```

### 2a. Turn off only the stub listener

Edit the main settings file:

```bash
sudo vim /etc/systemd/resolved.conf
```

Under `[Resolve]`, uncomment and set:

```
DNSStubListener=no
```

### 2b. Repoint `/etc/resolv.conf`

`/etc/resolv.conf` is a symlink that programs on the server read to find a DNS server. By default it points to `/run/systemd/resolve/stub-resolv.conf`, which says `nameserver 127.0.0.53`. That address stops answering once the stub is off, so the server would lose name resolution.

Point it at the file that lists the real upstream servers instead:

```bash
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
ls -l /etc/resolv.conf
```

## 3. Install AdGuard Home

```bash
curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sudo sh -s -- -v
```

Check the service and the boot setting:

```bash
sudo systemctl status AdGuardHome
sudo systemctl is-enabled AdGuardHome     # should print: enabled
```

## 4. Setup wizard

The wizard runs at `http://<SERVER-IP>:3000`, opened from another device on the LAN (Ubuntu Server has no desktop or browser, the web UI is just a page served over the network).

## 5. Verify it works

```bash
sudo ss -lntup | grep -E ':53 |:80 '
dig @127.0.0.1 example.com          # returns real IPs
dig @127.0.0.1 doubleclick.net      # returns 0.0.0.0 
```

Result:

- `AdGuardHome` listening on `*:53` (UDP and TCP) and `*:80` (admin page).
- `example.com` resolved (~14 ms, answered by an upstream).
- `doubleclick.net` returned `0.0.0.0` in ~1 ms. AdGuard answered it itself because the domain is on the default blocklist.

`dig` comes from `sudo apt install dnsutils` if missing.

## 6. AdGuard settings

**Upstream DNS servers** (all encrypted):

```
https://dns10.quad9.net/dns-query
tls://unfiltered.adguard-dns.com
tls://1.1.1.1
tls://9.9.9.9
```

- A bare IP means plain DNS. The `https://` and `tls://` prefixes are what make an upstream encrypted.
- Mode: load balancing (default).

**Bootstrap DNS servers:** plain public IPs (for example `9.9.9.10`, `1.1.1.1`). They are only used at startup to find the IP of upstreams given by name.

**Fallback DNS servers:** `192.168.4.1` (the router). Used only if all upstreams fail.

**Private reverse DNS servers:** `192.168.4.1`, with reverse resolving of client IPs enabled, so the Query Log can show device names.

**Rate limiting:**

| Setting | Value | Why |
|---|---|---|
| Rate limit | 20 | Per client, per second. |
| Subnet prefix length, IPv4 | **32** | One bucket per device. A `/22` would put the whole LAN in one bucket and drop queries. |
| Subnet prefix length, IPv6 | 64 | Groups a device's rotating privacy addresses. |

The prefix length field groups clients for the rate limit. It is not the network's subnet mask.

**DNS cache size:** `4194304` (4 MB, default). Plenty for a home network. Optimistic caching is optional.

**Allowed clients** (optional, do last so a mistake doesn't confuse testing):

```
127.0.0.1
192.168.4.0/22
100.64.0.0/10
```

## 7. Firewall (UFW)

UFW was inactive. Rules were added **before** enabling it so SSH wasn't cut off.

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow from 192.168.4.0/22 to any port 22 proto tcp     
sudo ufw allow from 192.168.4.0/22 to any port 53               
sudo ufw allow from 192.168.4.0/22 to any port 80 proto tcp     
sudo ufw allow in on tailscale0                                 

sudo ufw show added      
sudo ufw enable
```

Final state (`sudo ufw status verbose`):

```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)

22/tcp                     ALLOW IN    192.168.4.0/22
53                         ALLOW IN    192.168.4.0/22
80/tcp                     ALLOW IN    192.168.4.0/22
Anywhere on tailscale0     ALLOW IN    Anywhere
Anywhere (v6) on tailscale0 ALLOW IN    Anywhere (v6)
```

- "Implicit deny" is the default policy: anything that matches no allow rule is dropped.
- Blocked packets show as `[UFW BLOCK]` in `/var/log/ufw.log`.
- Port 53 has no `proto` on purpose: DNS needs both UDP and TCP.
- The blanket `tailscale0` rule can be replaced by per-port rules or Tailscale ACLs later.
- Do **not** forward port 53 on the router. An open resolver on the internet gets abused.

## 8. Using it from devices

**On the LAN (per device, since the router can't be changed):**

- Windows 11: Settings, Network & internet, Wi-Fi, the network, DNS server assignment, Edit, Manual, IPv4, preferred DNS = `<SERVER-IP>`, alternate = `192.168.4.1`.
- Leave **DNS over HTTPS off** for both entries. The router and this AdGuard setup don't serve DoH, so turning it on would break lookups.
- Browsers can bypass system DNS with their own Secure DNS / DoH. Turn it off or set it to use the system resolver, otherwise the Query Log stays empty.

**Away from home (Tailscale):**

- Tailscale admin console, DNS, Nameservers, add a custom nameserver = the server's Tailscale IP (`tailscale ip -4` on the server).
- Add a public resolver (for example `1.1.1.1`) as a second nameserver so those devices keep DNS if the server is down.

**Escape hatch:** set the device's DNS back to Automatic/DHCP and it returns to the router's DNS immediately.

