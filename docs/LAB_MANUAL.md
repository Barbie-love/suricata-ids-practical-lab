# Suricata IDS Practical Lab Manual

## 1. Lab overview

This practical introduces Suricata as a network intrusion detection system (IDS). You will install or verify Suricata, identify the interface to monitor, configure the local network scope, add a custom signature, generate authorized TCP traffic using Netcat, and review alerts in fast.log and eve.json.

This lab is designed for a controlled, private VirtualBox host-only network. Do not scan or generate test traffic against systems you do not own or have explicit permission to test.

## 2. Learning objectives

By the end, you should be able to:
• Explain the role of a network IDS and how Suricata inspects traffic.
• Identify the correct Linux network interface and IPv4 subnet.
• Back up and edit Suricata configuration safely.
• Create, load, and test a custom Suricata rule.
• Generate benign test traffic with Netcat.
• Verify a detection in fast.log and eve.json using grep and jq.
• Troubleshoot common connectivity and detection problems.

## 3. Lab environment and topology

Recommended setup: two Linux VMs connected to the same VirtualBox Host-only Adapter.

Suricata sensor VM: Kali Linux or Ubuntu, Suricata installed, interface attached to the host-only network.
Client VM: Kali/Ubuntu, Netcat installed, also attached to the same host-only network.
Example network only: 192.168.56.0/24. Your actual addresses may differ; replace placeholders.

Topology:
[Client VM: <CLIENT_IP>] -- Host-only network -- [Suricata VM: <SURICATA_IP>, interface <INTERFACE>]

The sensor is the destination for the Netcat test. It runs a listener on TCP/9999, while Suricata monitors the sensor's host-only interface. If using VirtualBox, set the host-only adapter on both VMs. For passive monitoring of traffic not addressed to the sensor, VirtualBox promiscuous-mode settings and network placement may be necessary; this lab intentionally sends traffic to the sensor to make the test easier.

## 4. Prerequisites

• Two Linux VMs on the same isolated Host-only network (or a single VM with an appropriate loopback/self-test adaptation).
• sudo privileges and internet access for package installation/rule updates.
• Suricata 6/7/8 or a distro-supported release; configuration locations can vary.
• Netcat (`nc`) on the client and sensor.
• jq for JSON log filtering.
• A terminal on each VM.
• A screenshot folder in your portfolio repository.

## 5. Identify addresses and interface

On BOTH VMs run:
  ip -br addr
  ip route

Expected: `ip -br addr` lists interfaces and addresses. The interface carrying your host-only address is the one to identify. `ip route` shows routes and the `dev` interface. Do not assume the interface is eth0; common names include enp0s3, eth0, ens33.

On the Client, record its host-only IP as <CLIENT_IP>.
On the Suricata VM, record its host-only IP as <SURICATA_IP> and the interface name as <INTERFACE>.
Use `ip route get <CLIENT_IP>` on the sensor to see the route/interface Linux would use to reach the client.

## 6. Install and verify Suricata

On the Suricata VM:
  sudo apt update
  sudo apt install suricata jq netcat-openbsd -y
  suricata -V
  sudo suricata --build-info

Expected: package installation completes and version/build information is displayed. If Suricata is already installed, verify it instead of reinstalling. Netcat is installed on both VMs if needed.

## 7. Back up configuration and find key settings

On the Suricata VM:
  sudo cp /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml.backup
  sudo ls -l /etc/suricata/suricata.yaml*

Edit:
  sudo nano /etc/suricata/suricata.yaml

Find `HOME_NET`, `af-packet`, `default-rule-path`, and `rule-files`. Use Ctrl+W in nano to search. Save with Ctrl+O, Enter; exit with Ctrl+X.

HOME_NET: set it to the private lab subnet you are monitoring, for example:
  HOME_NET: "[192.168.56.0/24]"
Do not copy this example unless it matches your lab. Some configs include other private ranges; preserve additional networks you still need.

AF-PACKET: in the af-packet section, ensure the interface matches your identified interface. Example:
  af-packet:
    - interface: enp0s3
      cluster-id: 99
      cluster-type: cluster_flow
      defrag: yes
      tpacket-v3: yes
The example interface is a placeholder. Preserve the structure and indentation of your installed configuration; avoid adding a duplicate af-packet section.

Rule path: commonly:
  default-rule-path: /var/lib/suricata/rules
  rule-files:
    - suricata.rules
Add `local.rules` to the rule-files list. Depending on the installed config, use the filename under its configured rule directory. This manual uses `/etc/suricata/rules/local.rules` as an explicit file path in the example configuration to reduce ambiguity.

## 8. Update community rules

Run:
  sudo suricata-update
  ls -lh /var/lib/suricata/rules/

Expected: suricata-update reports sources/rules processed and the main rules file is present. Internet or source errors may occur if connectivity is unavailable. The custom lab rule is separate from the downloaded ruleset.

## 9. Create a custom detection rule

Create the local rule file:
  sudo mkdir -p /etc/suricata/rules
  sudo nano /etc/suricata/rules/local.rules

Paste this one-line rule:
  alert tcp $HOME_NET any -> $HOME_NET 9999 (msg:"SURICATA LAB NETCAT TEST"; flow:to_server,established; content:"SURICATA-LAB-TEST"; sid:1000001; rev:1;)

Rule breakdown:
• alert — generate an alert when the signature matches.
• tcp — inspect TCP traffic.
• $HOME_NET any — source in the configured local network, any source port.
• -> $HOME_NET 9999 — traffic directed to local network destination port 9999.
• msg — human-readable alert name.
• flow:to_server,established — match established client-to-server direction.
• content — require the test text in the payload.
• sid — unique signature ID for this local rule (1000001).
• rev — rule revision.

This rule is meant for this lab. Avoid using local SID values already assigned in your environment; use the 1,000,000+ range for locally authored examples.

## 10. Add the custom rule and validate configuration

In `/etc/suricata/suricata.yaml`, make sure the rule-files list loads the custom file. A simple example:
  rule-files:
    - suricata.rules
    - /etc/suricata/rules/local.rules

The exact layout varies by release. Do not replace the whole list blindly; add the entry to the existing list. Then test:
  sudo suricata -T -c /etc/suricata/suricata.yaml

Expected: the configuration and rules load successfully. If the test fails, read the error and correct the configuration before starting the service. To check the custom rule text:
  sudo grep -n 'SURICATA LAB NETCAT TEST' /etc/suricata/rules/local.rules

## 11. Start and verify Suricata

Start/restart the service:
  sudo systemctl restart suricata
  sudo systemctl status suricata --no-pager

Expected: `Active: active (running)` if service mode works. If service does not start, inspect:
  sudo journalctl -u suricata -n 50 --no-pager
  sudo tail -n 50 /var/log/suricata/suricata.log

The service reads its configured interface from suricata.yaml. Verify that the interface is correct. You can inspect service options with `systemctl cat suricata`; avoid launching a second Suricata process on the same capture interface while the service is running.

## 12. Generate Netcat traffic

On the Suricata VM, start a listener in a terminal:
  nc -lvnp 9999

Expected: Netcat waits for a connection on TCP port 9999. Keep this terminal open.

On the Client VM, create/use the traffic script:
  chmod +x scripts/generate_traffic.sh
  ./scripts/generate_traffic.sh <SURICATA_IP>

Or run the manual command from the Client:
  printf 'SURICATA-LAB-TEST\n' | nc -nv <SURICATA_IP> 9999

Replace `<SURICATA_IP>` with the sensor's host-only IP. Expected: Netcat reports a connection (message varies by implementation) and the listener receives `SURICATA-LAB-TEST`. If the client command hangs, stop it with Ctrl+C and troubleshoot connectivity.

The included script accepts the sensor IP as its argument and sends only the fixed test string to TCP/9999. Use it only on your authorized lab network.

## 13. Trigger and analyze alerts

On the Suricata VM, in another terminal:
  sudo tail -f /var/log/suricata/fast.log

Send the test string again from the Client. Expected alert text contains:
  SURICATA LAB NETCAT TEST
  [1:1000001:1]

Stop tail with Ctrl+C.

Search the log without live-follow:
  sudo grep -n 'SURICATA LAB NETCAT TEST' /var/log/suricata/fast.log

View EVE JSON alert events:
  sudo grep '"event_type":"alert"' /var/log/suricata/eve.json | tail -n 5

With jq:
  sudo jq 'select(.event_type == "alert") | {timestamp, src_ip, src_port, dest_ip, dest_port, alert: .alert.signature, sid: .alert.signature_id}' /var/log/suricata/eve.json | tail -n 30

Expected: a structured object with source/destination IPs, ports, signature name and SID. EVE JSON formatting/fields can vary by Suricata version. `jq` reads JSON and filters selected fields; the `select` expression keeps alert records only.

## 14. Common troubleshooting

NO ROUTE TO HOST
• Confirm both VMs are attached to the same Host-only network and the adapter is enabled.
• Run `ip -br addr` and `ip route` on both machines.
• Check the destination IP is the correct host-only address, not an address from another adapter.
• Check `ip route get <SURICATA_IP>` on the client.
• A firewall may reject or block traffic. Inspect firewall rules on your own lab VMs.

CONNECTION REFUSED
• The destination is reachable, but no process is listening on TCP/9999 or a firewall is actively rejecting it.
• On the sensor, confirm the listener is running: `nc -lvnp 9999`.
• Check the port: `sudo ss -lntp | grep 9999`.

WRONG INTERFACE / NO PACKETS
• `ip route` and `ip -br addr` identify your real interface.
• Verify `af-packet` interface in suricata.yaml matches it.
• If using VirtualBox, ensure both VMs are connected to the same host-only network. For passive traffic not addressed to the sensor, promiscuous mode may be required; this lab traffic is addressed to the sensor.

NO ALERTS
• Validate rule loaded: `sudo suricata -T -c /etc/suricata/suricata.yaml`.
• Check the rule file and SID/message: `sudo grep -n 'SURICATA LAB NETCAT TEST' /etc/suricata/rules/local.rules`.
• Ensure rule-files includes local.rules and the file path exists.
• Confirm Suricata is running and logs are being written.
• Send the exact payload `SURICATA-LAB-TEST` to TCP/9999 after the listener starts.
• Check `fast.log` and `eve.json` paths; ensure output settings are enabled.
• Check the service logs: `sudo journalctl -u suricata -n 50 --no-pager`.
• If you change config/rules, run the config test and restart the service.

jq: command not found
• Install it: `sudo apt update && sudo apt install jq -y`.

Permission denied reading logs
• Use `sudo` for log-reading commands.

## 15. Verification checklist

[ ] Suricata version verified
[ ] Both VMs are on the same isolated host-only network
[ ] Client and sensor IP addresses recorded
[ ] Sensor interface identified
[ ] suricata.yaml backed up
[ ] HOME_NET reflects the lab subnet
[ ] af-packet interface matches the sensor interface
[ ] Rules updated
[ ] local.rules created with SID 1000001
[ ] local.rules referenced in rule-files
[ ] Configuration test passes
[ ] Suricata service active
[ ] Netcat listener running on TCP/9999
[ ] Client sent the exact test payload
[ ] Alert visible in fast.log
[ ] Alert JSON located and filtered with jq
[ ] Evidence screenshots saved and filenames descriptive

## 16. Student questions

1. What is the difference between an IDS and an IPS?
2. What does HOME_NET tell Suricata?
3. Why is identifying the correct interface important?
4. Explain each part of the custom rule header and its options.
5. What does SID 1000001 identify? Why should a local SID be unique?
6. What is the difference between fast.log and eve.json?
7. Which source/destination IP and port were shown in your alert? (Use your own evidence.)
8. What could cause a TCP connection to be refused?
9. What steps would you take if the traffic reached Netcat but no alert appeared?
10. Why should this experiment be run on an authorized lab network?

## 17. Practical challenge

Change the rule message and SID revision (increase rev), then add a second custom rule that alerts on a different benign payload of your choice on TCP/9999. Validate the rules, restart Suricata, send the new payload, and demonstrate that the second alert appears in fast.log and eve.json. Document the rule, command, alert evidence, and a short explanation in your portfolio. Do not test against systems outside your lab.

## 18. GitHub evidence and report

Capture screenshots showing: (1) network interfaces/IPs, (2) configuration test successful, (3) custom rule contents, (4) service active, (5) Netcat listener and client message, (6) fast.log alert, and (7) jq-filtered EVE alert. Use the provided evidence/screenshot naming guide. Do not fabricate screenshots or results.

Fill in `results.md` with your actual environment, addresses (mask if public or sensitive), commands performed, observed results, and answers. The repository is a documentation/evidence template; example alert files are clearly marked as sample data.

## 19. Cleanup

Stop the Netcat listener with Ctrl+C. If desired, remove the custom rule from the installed config and local.rules, restore the backup configuration, test it, and restart Suricata. Keep your GitHub evidence and project files separate from system configuration. Do not publish private IPs, credentials, sensitive logs, or unrelated personal data.