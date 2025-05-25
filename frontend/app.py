import streamlit as st
import subprocess
import os

st.set_page_config(page_title="RedNet - Penetration Testing System", layout="centered")

st.title("🛡️ RedNet - Automated Penetration Testing System")

domain = st.text_input("🌐 Enter Target Domain")
ip = st.text_input("💻 Enter Target IP Address")

if st.button("🚀 Run Scan"):
    if not domain or not ip:
        st.warning("Please provide both Domain and IP.")
    else:
        st.info("Running Bash script... Please wait.")
        command = f"bash scripts/scan.sh"
        result = subprocess.run(command, shell=True, capture_output=True, text=True, input=f"{domain}\n{ip}\n")
        st.success("Scan Completed ✅")

        # Display Raw Scan Output nicely in an expandable box
        with st.expander("📄 Raw Scan Output"):
            st.text_area("Scan Output", value=result.stdout, height=300)

        high_risk_path = "scan_cache/high_risk_ports.txt"
        if os.path.exists(high_risk_path):
            with open(high_risk_path, 'r') as f:
                high_risk_data = f.read()
            with st.expander("⚠️ High-Risk Ports Detected"):
                if high_risk_data.strip():
                    st.code(high_risk_data)
                else:
                    st.info("No high-risk ports detected.")
        else:
            high_risk_data = "No high-risk ports detected."
            st.info(high_risk_data)

        # Prepare a basic text report
        report_content = f"""
RedNet Scan Report
==================
Target Domain: {domain}
Target IP: {ip}

--- Raw Scan Output ---
{result.stdout}

--- High-Risk Ports ---
{high_risk_data}
"""

        # Add download button for the report
        st.download_button(
            label="📥 Download Scan Report",
            data=report_content,
            file_name=f"RedNet_Scan_Report_{domain.replace(' ', '_')}.txt",
            mime="text/plain"
        )
