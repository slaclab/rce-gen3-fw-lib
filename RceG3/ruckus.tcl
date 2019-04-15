# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Get the family type
set family [getFpgaFamily]

# Load local Source Code
loadSource -dir "$::DIR_PATH/hdl"
loadSource -dir "$::DIR_PATH/hdl/${family}"
loadIpCore -dir "$::DIR_PATH/coregen/${family}"

# Check for submodule tagging
if { [SubmoduleCheck {ruckus} {1.6.3} ] < 0 } {exit -1}
if { [SubmoduleCheck {surf}   {1.9.8} ] < 0 } {exit -1}

# Check for version 2018.1 of Vivado (or later)
if { [VersionCheck 2018.1] < 0 } {exit -1}
