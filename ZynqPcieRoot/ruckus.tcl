# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load the wrapper
loadSource -path "$::DIR_PATH/rtl/AxiIconWrapper.vhd"

loadBlockDesign -path "$::DIR_PATH/bd/axi_icon.bd

