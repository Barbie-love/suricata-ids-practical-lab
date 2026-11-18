# Screenshot evidence guide

Capture your own screenshots and name them:
- `01-network-interfaces.png` — `ip -br addr` and `ip route`
- `02-suricata-version.png` — version/build info
- `03-custom-rule.png` — local.rules content
- `04-config-test.png` — successful `suricata -T`
- `05-service-running.png` — service status
- `06-netcat-listener.png` — listener waiting on TCP/9999
- `07-client-traffic.png` — client sends payload / connection result
- `08-fast-log-alert.png` — matching alert
- `09-eve-json-jq.png` — jq filtered alert

Only include screenshots of your own execution. Mask sensitive addresses/identifiers if necessary.
