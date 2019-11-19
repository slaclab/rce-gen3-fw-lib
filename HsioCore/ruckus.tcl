# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for valid FPGA 
if { $::env(PRJ_PART) != "XC7Z030FBG484-2" } {
   puts "\n\nERROR: PRJ_PART was not defined as XC7Z030FBG484-2 in the Makefile\n\n"; exit -1
}

# Load the dependent source code
loadRuckusTcl "$::DIR_PATH/../RceG3"
loadRuckusTcl "$::DIR_PATH/../RceEthernet"
loadRuckusTcl "$::DIR_PATH/../ZynqPcieMaster"
loadRuckusTcl "$::DIR_PATH/../CobTiming"
loadRuckusTcl "$::DIR_PATH/../PpiCommon"
loadRuckusTcl "$::DIR_PATH/../PpiPgp"

# Load local Source Code and constraints
loadSource -lib rce_gen3_fw_lib -dir "$::DIR_PATH/rtl"
loadIpCore      -dir "$::DIR_PATH/ip"
loadConstraints -dir "$::DIR_PATH/xdc"

set_property PROCESSING_ORDER {EARLY}           [get_files {GmiiToRgmiiCore.xdc}]
set_property SCOPED_TO_REF    {GmiiToRgmiiCore} [get_files {GmiiToRgmiiCore.xdc}]
set_property SCOPED_TO_CELLS  {U0}              [get_files {GmiiToRgmiiCore.xdc}]

set_property PROCESSING_ORDER {LATE}            [get_files {GmiiToRgmiiCore_clocks.xdc}]
set_property SCOPED_TO_REF    {GmiiToRgmiiCore} [get_files {GmiiToRgmiiCore_clocks.xdc}]
set_property SCOPED_TO_CELLS  {U0}              [get_files {GmiiToRgmiiCore_clocks.xdc}]

set_property PROCESSING_ORDER {EARLY}            [get_files {GmiiToRgmiiSlave.xdc}]
set_property SCOPED_TO_REF    {GmiiToRgmiiSlave} [get_files {GmiiToRgmiiSlave.xdc}]
set_property SCOPED_TO_CELLS  {U0}               [get_files {GmiiToRgmiiSlave.xdc}]

set_property PROCESSING_ORDER {LATE}             [get_files {GmiiToRgmiiSlave_clocks.xdc}]
set_property SCOPED_TO_REF    {GmiiToRgmiiSlave} [get_files {GmiiToRgmiiSlave_clocks.xdc}]
set_property SCOPED_TO_CELLS  {U0}               [get_files {GmiiToRgmiiSlave_clocks.xdc}]
