# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code
loadSource -dir  "$::DIR_PATH/hdl/"

loadSource -path "$::DIR_PATH/simlink/rtl/RceG3CpuSim.vhd"

loadIpCore -dir       "$::DIR_PATH/coregen/processing_system7_0/"
loadBlockDesign -path "$::DIR_PATH/coregen/pcie_root/pcie_root.bd"

loadSource -sim_only -path "$::DIR_PATH/tb/rceg3_tb.vhd"

# Check for submodule tagging
if { [SubmoduleCheck {ruckus} {1.6.3} ] < 0 } {exit -1}
if { [SubmoduleCheck {surf}   {1.7.4} ] < 0 } {exit -1}

# Check for version 2018.1 of Vivado (or later)
if { [VersionCheck 2018.1] < 0 } {exit -1}
