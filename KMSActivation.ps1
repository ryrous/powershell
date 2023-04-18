### Description: This script will activate Windows Server 2022 Standard LTSC using KMS ###
# Install Key
slmgr.vbs /ipk 'VDYBN-27WPP-V4HQT-9VMD4-VMK7H'
# Activate
slmgr /ato
# Check Activation Status
slmgr /dlv