#!/bin/bash

# =============================
echo "Network Penetration Testing System"
echo "==============================="

# ---- User Input Validation ----
read -p "Enter the target domain: " domain
if [[ -z "$domain" ]]; then
    echo "[!] Domain cannot be empty. Exiting."
    exit 1
fi

read -p "Enter the target IP: " ip
if [[ -z "$ip" ]]; then
    echo "[!] IP cannot be empty. Exiting."
    exit 1
fi

# ---- Caching Check ----
cachedir="scan_cache"
mkdir -p "$cachedir"

if [[ -f "$cachedir/whois_info.txt" ]]; then
    echo "Using cached WHOIS info."
else
    echo "1. WHOIS Information"
    whois "$domain" > "$cachedir/whois_info.txt"
    echo "Saved WHOIS info to $cachedir/whois_info.txt"
fi

if [[ -f "$cachedir/dns_info.txt" ]]; then
    echo "Using cached DNS info."
else
    echo "2. DNS Information (nslookup)"
    nslookup "$domain" > "$cachedir/dns_info.txt"
    echo "Saved DNS info to $cachedir/dns_info.txt"
fi

if [[ -f "$cachedir/dig_info.txt" ]]; then
    echo "Using cached dig info."
else
    echo "3. Domain Info (dig)"
    dig "$domain" ANY +noall +answer > "$cachedir/dig_info.txt"
    echo "Saved dig output to $cachedir/dig_info.txt"
fi

# ---- Parallel Scanning Execution ----
echo "4. Running scans in parallel..."

nmap_scan() {
    echo "Running Nmap Scan..."
    nmap -sP "$ip" -oN "$cachedir/nmap_scan.txt"
    echo "Saved Nmap scan to $cachedir/nmap_scan.txt"
}

harvester_scan() {
    echo "Running theHarvester OSINT Scan..."
    theHarvester -d "$domain" -b bing -f "$cachedir/theharvester_result"
    echo "Saved theHarvester results to $cachedir/theharvester_result.*"
}

nikto_scan() {
    echo "Running Nikto Web Server Vulnerability Scan..."
    nikto -h http://"$ip" -output "$cachedir/nikto_scan.txt"
    echo "Saved Nikto scan to $cachedir/nikto_scan.txt"
}

# ---- Run scans concurrently ----
nmap_scan &
harvester_scan &
nikto_scan &

# ---- Wait for all scans to finish ----
wait

echo "All parallel scans completed."

# ---- Nessus Launch ----
echo "5. Starting Nessus..."
sudo systemctl start nessusd
sleep 5

echo "Opening Nessus in browser at https://localhost:8834 ..."
xdg-open https://localhost:8834 &

# ---- Risk-Based Filtering Example ----
echo "\nFiltering Nmap results for high-risk services (e.g., ftp, telnet, smb):"
grep -Ei "ftp|telnet|smb" "$cachedir/nmap_scan.txt" > "$cachedir/high_risk_ports.txt"
echo "Filtered high-risk ports saved to $cachedir/high_risk_ports.txt"

# ---- Asynchronous I/O Optimization Tip ----
# Suggest using background file parsing with tail or grep &
# Example: tail -n 100 nikto_scan.txt & or parallel parsing using xargs for multi-file input

exit 0
