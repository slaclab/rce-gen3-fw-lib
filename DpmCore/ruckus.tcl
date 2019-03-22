# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Get the family type
set family [getFpgaFamily]

# Check for valid FPGA 
if { $::env(PRJ_PART) != "XC7Z045FFG900-2" && $::env(PRJ_PART) != "XCZU15EG-FFVC900-1-E" } {
   puts "\n\nERROR: PRJ_PART must be either XC7Z045FFG900-2 or XCZU15EG-FFVC900-1-E in the Makefile\n\n"; exit -1
}

# Load the dependent source code
loadRuckusTcl "$::DIR_PATH/../RceG3"
loadRuckusTcl "$::DIR_PATH/../RceEthernet"
loadRuckusTcl "$::DIR_PATH/../CobTiming"
loadRuckusTcl "$::DIR_PATH/../PpiCommon"
loadRuckusTcl "$::DIR_PATH/../PpiPgp"

# Load local Source Code and constraints
loadSource      -dir "$::DIR_PATH/hdl"
loadConstraints -dir "$::DIR_PATH/xdc/${family}"
