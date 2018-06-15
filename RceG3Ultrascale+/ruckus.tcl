# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code
loadSource -dir  "$::DIR_PATH/rtl/"
loadSource -dir  "$::DIR_PATH/../RceG3/hdl/common"
loadSource -path "$::DIR_PATH/../RceG3/simlink/rtl/RceG3CpuSim.vhd"
loadIpCore -dir  "$::DIR_PATH/ip"

# Check for submodule tagging
if { [SubmoduleCheck {ruckus} {1.6.3} ] < 0 } {exit -1}
if { [SubmoduleCheck {surf}   {1.7.4} ] < 0 } {exit -1}

# Check for version 2018.1 of Vivado (or later)
if { [VersionCheck 2018.1] < 0 } {exit -1}
