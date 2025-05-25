# RedNet - Penetration Testing System

RedNet is an automated penetration testing system designed to identify vulnerabilities in networks, servers, and web applications. It uses Bash-based tools under the hood and provides a simple Streamlit web interface for usability.

## Features

- Domain/IP scanning
- Service and port detection
- Vulnerability scanning (Nikto, Nmap, etc.)
- Simple, user-friendly dashboard
- Downloadable reports

## Folder Structure

RedNet/
│
├── frontend/
│ └── app.py # Streamlit dashboard
├── scans/ # Output reports (ignored in Git)
├── scripts/ # Bash scripts (will be added in Phase 2)
├── README.md
└── .gitignore

## Getting Started

1. Clone the repo
2. Create virtual environment
3. Run the Streamlit app:
```bash
streamlit run frontend/app.py
