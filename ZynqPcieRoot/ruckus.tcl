# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load the wrapper
loadSource -path "$::DIR_PATH/rtl/ZynqPcieRoot.vhd"

loadBlockDesign -path "$::DIR_PATH/bd/axi_icon.bd"

loadIpCore -path "$::DIR_PATH/xci/axi_pcie_0.xci"
#loadSource -path "$::DIR_PATH/ip/TenGigEthGtx7Core.dcp"
