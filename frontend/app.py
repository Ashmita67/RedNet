import streamlit as st
import subprocess
import os
import webbrowser

# Page configuration
st.set_page_config(page_title="Network Penetration Testing", layout="centered")
st.title("🛡️ Network Penetration Testing System")
st.markdown("---")

# Input fields
domain = st.text_input("🔍 Enter Target Domain", placeholder="e.g. scanme.nmap.org")
ip = st.text_input("💻 Enter Target IP Address", placeholder="e.g. 127.0.0.1")

if st.button("🚀 Run Scan"):
    if not domain or not ip:
        st.error("❌ Please enter both a domain and an IP address.")
    else:
        with st.spinner("Running scans... this may take a moment..."):
            try:
                # Run Bash script with domain and IP
                result = subprocess.run(
                    ["bash", "script/scan.sh", domain, ip],
                    capture_output=True,
                    text=True,
                    timeout=300
                )

                output = result.stdout
                errors = result.stderr

                # Show output
                st.success("✅ Scan completed successfully.")
                st.subheader("📋 Scan Output")
                st.code(output)

                # Risk detection
                if any(service in output.lower() for service in ["ftp", "telnet", "smb"]):
                    st.warning("⚠️ High-risk ports detected (FTP/Telnet/SMB). See output for details.")
                else:
                    st.info("✅ No high-risk ports found.")

                # Report download
                st.download_button(
                    label="📄 Download Full Report",
                    data=output,
                    file_name="scan_report.txt",
                    mime="text/plain"
                )

                nessus_url = "https://172.16.16.29:8834"

                # Force open in Google Chrome
                chrome_path = "C:/Program Files/Google/Chrome/Application/chrome.exe %s"
                try:
                    webbrowser.get(chrome_path).open(nessus_url)
                    st.markdown(f"🔗 [Nessus opened in Chrome]({nessus_url})", unsafe_allow_html=True)
                except webbrowser.Error:
                    st.warning("⚠️ Could not open Chrome automatically. Please open Nessus manually:")
                    st.markdown(f"🔗 [Click to open Nessus]({nessus_url})", unsafe_allow_html=True)

            except subprocess.TimeoutExpired:
                st.error("❌ The scan took too long and timed out.")
            except FileNotFoundError:
                st.error("❌ Could not find 'script/scan.sh'. Make sure it exists and is in the correct location.")
            except Exception as e:
                st.error(f"❌ An error occurred: {e}")
