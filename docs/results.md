# Lab Results – Suricata IDS Practical

## 1. Lab Environment

- **IDS:** Suricata 6.0.4 RELEASE
- **Monitoring machine:** Cybersecurity Lab VM
- **Test machine:** Kali Linux
- **Monitoring interface:** enp0s3
- **Suricata IP address:** 192.168.1.10
- **Kali IP address:** 192.168.1.11
- **Test protocol:** TCP
- **Test destination port:** 9999

## 2. Configuration Results

Suricata was configured to monitor the `enp0s3` network interface.

The default rule path was configured as `/var/lib/suricata/rules`, and a custom rule file named `local.rules` was created.

The configuration test completed successfully.

The Suricata log reported:
- 2 rule files processed.
- 53,461 rules successfully loaded.
- 0 rules failed.
- 53,466 signatures processed.
- All AF_PACKET capture threads running.

## 3. Custom Detection Rule

The following custom rule was created:

```text
alert tcp $HOME_NET any -> $HOME_NET 9999 (msg:"SURICATA LAB NETCAT TEST"; flow:to_server,established; content:"SURICATA-LAB-TEST"; sid:1000001; rev:1;)
```

The rule was designed to detect the test message sent over TCP to destination port 9999.

## 4. Connectivity Test

A ping test was performed from Kali Linux to the Cybersecurity Lab VM.

Results:
- Packets transmitted: 4
- Packets received: 4
- Packet loss: 0%
- Average response time: 1.000 ms

## 5. Traffic Generation and Detection

Netcat was used to listen on port 9999 on the Cybersecurity Lab VM.

The following command was executed from Kali Linux:

```bash
echo "SURICATA-LAB-TEST" | nc -v 192.168.1.10 9999
```

The listener successfully received the connection and displayed:

```text
Connection received on 192.168.1.11
SURICATA-LAB-TEST
```

Suricata generated the expected custom alert.

## 6. Alert Evidence

The alert was recorded in `fast.log` and `eve.json`.

| Field | Observed value |
|---|---|
| Event type | alert |
| Signature ID | 1000001 |
| Alert message | SURICATA LAB NETCAT TEST |
| Source IP | 192.168.1.11 |
| Destination IP | 192.168.1.10 |
| Destination port | 9999 |
| Protocol | TCP |
| Severity | 3 |
| Action | allowed |

## 7. Final Result

The practical lab was successfully completed.

Suricata was configured to monitor network traffic, a custom detection rule was created and loaded, and test traffic was generated from Kali Linux.

The IDS successfully detected the test traffic and recorded the matching alert in its log files.

This practical demonstrated how an Intrusion Detection System can monitor network traffic and identify activity matching configured detection rules.