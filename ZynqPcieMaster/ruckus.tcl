# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code
loadSource -lib rce_gen3_fw_lib -dir "$::DIR_PATH/coregen/pcie_7x_v1_9/source/"
loadSource -lib rce_gen3_fw_lib -dir "$::DIR_PATH/hdl/"
