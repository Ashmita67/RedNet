#!/bin/bash

# =============================
echo "Network Penetration Testing System"
echo "==============================="

# ---- Accept Parameters from CLI ----
domain="$1"
ip="$2"

# ---- Validation ----
if [[ -z "$domain" ]]; then
    echo "[!] Domain cannot be empty. Exiting."
    exit 1
fi

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

# ---- Launch Nessus ----
echo "5. Starting Nessus..."
sudo systemctl start nessusd
sleep 5

# ---- Open Nessus in browser based on OS ----
url="https://localhost:8834"

echo "Opening Nessus in browser at $url ..."
if command -v xdg-open > /dev/null; then
    xdg-open "$url" &
elif command -v open > /dev/null; then
    open "$url" &
elif command -v start > /dev/null; then
    start "$url" &
else
    echo "Cannot auto-launch browser. Please open $url manually."
fi

# ---- Risk-Based Filtering Example ----
echo ""
echo "Filtering Nmap results for high-risk services (e.g., ftp, telnet, smb):"
grep -Ei "ftp|telnet|smb" "$cachedir/nmap_scan.txt" > "$cachedir/high_risk_ports.txt"
echo "Filtered high-risk ports saved to $cachedir/high_risk_ports.txt"

exit 0
