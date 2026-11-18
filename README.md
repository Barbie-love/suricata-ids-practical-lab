# Suricata IDS Practical Lab

## Project Overview

This project documents a hands-on practical exercise using **Suricata 6.0.4** as an Intrusion Detection System (IDS).

The objective was to configure Suricata to monitor network traffic, create a custom detection rule, generate test traffic from a second virtual machine, and verify that the IDS detected the traffic.

## Lab Environment

| Component | Details |
|---|---|
| IDS software | Suricata 6.0.4 RELEASE |
| Monitoring machine | Cybersecurity Lab VM |
| Test machine | Kali Linux |
| Monitoring interface | enp0s3 |
| Suricata IP | 192.168.1.10 |
| Kali IP | 192.168.1.11 |
| Test protocol | TCP |
| Test port | 9999 |

## Practical Objectives

- Install and verify Suricata.
- Identify the active network interface.
- Configure Suricata to monitor network traffic.
- Update and configure detection rules.
- Create a custom Suricata rule.
- Generate test traffic using Netcat.
- Verify detection through Suricata logs.

## Custom Detection Rule

A custom rule was created to detect the test message `SURICATA-LAB-TEST` sent over TCP port 9999.

**Signature ID:** `1000001`

## Testing and Results

Kali Linux successfully connected to the Cybersecurity Lab VM.

The test message was received by the Netcat listener, and Suricata generated the expected alert.

The detection was verified in:

- `fast.log`
- `eve.json`

**Result:** Successful custom-rule detection.

## Evidence

Screenshots documenting the practical exercise are stored in:

`evidence/screenshots/`

The screenshots include network configuration, Suricata setup, custom rule creation, connectivity testing, traffic generation, and alert detection.

## Project Documentation

- `docs/` – Lab manual, command sheet, results and reflection.
- `evidence/screenshots/` – Practical screenshots.
- `rules/` – Custom detection rule documentation.
- `scripts/` – Supporting scripts, if included.

## Learning Outcomes

Through this practical, I gained experience configuring Suricata, writing a custom detection rule, generating network traffic, and analyzing IDS alerts.

## Conclusion

The practical demonstrated how Suricata can monitor network traffic and identify activity matching a custom detection rule. The successful alert confirmed that the configured IDS detected the test traffic.

## Author

Uzoeto Anneth

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.