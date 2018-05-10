# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code
loadSource -dir  "$::DIR_PATH/hdl/"

loadSource -path "$::DIR_PATH/simlink/rtl/RceG3CpuSim.vhd"

loadIpCore -dir  "$::DIR_PATH/coregen/processing_system7_0/"

loadBlockDesign -path "$::DIR_PATH/coregen/pcie_root/pcie_root.bd"

loadSource -sim_only -path "$::DIR_PATH/tb/rceg3_tb.vhd"
