# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Get the family type
set family [getFpgaFamily]

# Load local Source Code
loadSource -dir "$::DIR_PATH/rtl"
loadSource -dir "$::DIR_PATH/rtl/${family}"