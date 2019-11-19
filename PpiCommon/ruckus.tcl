# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load Source Code
loadSource -lib rce_gen3_fw_lib -dir "$::DIR_PATH/hdl/"
# loadSource -lib rce_gen3_fw_lib -sim_only -dir "$::DIR_PATH/tb/"
