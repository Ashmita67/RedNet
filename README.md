# 🛡️ RedNet - Automated Penetration Testing System

RedNet is an automated network and web penetration testing system designed to identify vulnerabilities in networks, servers, and web applications. It uses Bash-based tools under the hood integrating with **Nessus** and provides a simple Streamlit web interface for usability.

---

## 🚀 Features

- 🔍 **Automated Recon & Scanning**  
  Input a domain and IP address; RedNet runs scanning scripts using tools like Nmap and Nikto.

- 📄 **Beautiful Streamlit Interface**  
  Simple, interactive UI for launching scans and viewing results.

- ⚠️ **High-Risk Port Detection**  
  Highlights common vulnerable ports like FTP (21), Telnet (23), etc.

- 📁 **Downloadable Report**  
  Scan results saved to text files and available for download.

- 🧩 **Modular Bash Scripts**  
  Easy to extend or customize scanning logic in `scripts/scan.sh`.

---

## 📦 Tech Stack

- **Frontend:** Python, Streamlit  
- **Backend Scripts:** Bash (scan.sh, others)  
- **OS Compatibility:** Linux, Windows (with Git Bash)  
- **Optional:** Nessus integration for full-scale vulnerability assessment

---
