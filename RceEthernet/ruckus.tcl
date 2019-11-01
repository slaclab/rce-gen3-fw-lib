# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Get the family type
set family [getFpgaFamily]

# Load local Source Code
loadSource -lib rce_gen3_fw_lib -dir "$::DIR_PATH/rtl"
loadSource -lib rce_gen3_fw_lib -dir "$::DIR_PATH/rtl/${family}"
