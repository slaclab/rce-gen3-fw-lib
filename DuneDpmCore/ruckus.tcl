# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for valid FPGA 
if { $::env(PRJ_PART) != "XCZU15EG-FFVB1156-1-E" } {
   puts "\n\nERROR: PRJ_PART was not defined as XCZU15EG-FFVB1156-1-E in the Makefile\n\n"; exit -1
}

# Load the dependent source code
loadRuckusTcl "$::DIR_PATH/../RceG3Ultrascale+"
loadRuckusTcl "$::DIR_PATH/../PpiCommon"
loadRuckusTcl "$::DIR_PATH/../ZynqEthernet"
loadRuckusTcl "$::DIR_PATH/../ZynqEthernet10G"
loadRuckusTcl "$::DIR_PATH/core"
loadRuckusTcl "$::DIR_PATH/ddr"
