# Lab Reflection – Suricata IDS Practical

## 1. What did I learn from this practical?

I learned how to configure and use Suricata as an Intrusion Detection System (IDS). I learned how to identify the correct network interface, configure the Suricata rules directory, create a custom detection rule, and monitor network traffic.

I also learned how to use Netcat to generate test traffic from Kali Linux and how to examine Suricata alerts using `fast.log` and `eve.json`.

## 2. What challenges did I encounter?

One challenge was configuring Suricata to use the correct network interface because the original configuration referenced `eth0`, while my actual interface was `enp0s3`.

I also encountered a missing rules-file issue. I resolved this by updating the rules and correcting the default rule path.

Another challenge was confirming that Suricata was running and detecting the test traffic. I used the Suricata logs to verify that the engine started successfully and that my custom rule generated an alert.

## 3. How did I verify that the IDS worked?

I verified the IDS by sending the message `SURICATA-LAB-TEST` from Kali Linux to the Cybersecurity Lab VM over TCP port 9999.

The message was received by the Netcat listener, and Suricata generated an alert with signature ID `1000001`. I confirmed the detection in both `fast.log` and `eve.json`.

## 4. What would I improve in a future practical?

In a future practical, I would explore more Suricata detection rules, investigate different types of network traffic, and learn how to analyze alerts to identify potentially suspicious activity.

I would also improve my understanding of Suricata's configuration options and event logs.