# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for valid FPGA 
if { $::env(PRJ_PART) != "XCZU9EG-FFVB1156-2-E" } {
   puts "\n\nERROR: PRJ_PART must be either XCZU9EG-FFVB1156-2-E in the Makefile\n\n"; exit -1
}

# Set the board part
set_property board_part xilinx.com:zcu102:part0:3.2 [current_project]

# Check for version 2018.3 of Vivado (or later)
if { [VersionCheck 2018.3] < 0 } {exit -1}

# Check for submodule tagging
if { [SubmoduleCheck {ruckus} {1.7.4} ] < 0 } {exit -1}
if { [SubmoduleCheck {surf}   {1.9.8} ] < 0 } {exit -1}

# Load local Source Code and constraints
loadSource -lib rce_gen3_fw_lib      -dir "$::DIR_PATH/hdl"
loadConstraints -dir "$::DIR_PATH/xdc"
loadIpCore      -dir "$::DIR_PATH/ip"

loadSource -lib rce_gen3_fw_lib -path "$::DIR_PATH/../RceG3/hdl/zynquplus/RceG3Clocks.vhd"
loadSource -lib rce_gen3_fw_lib -path "$::DIR_PATH/../RceG3/hdl/zynquplus/RceG3Cpu.vhd"
loadSource -lib rce_gen3_fw_lib -path "$::DIR_PATH/../RceG3/hdl/zynquplus/RceG3Pkg.vhd"
loadSource -lib rce_gen3_fw_lib -dir  "$::DIR_PATH/../RceG3/hdl"

# Load the dependent source code
loadRuckusTcl "$::DIR_PATH/../PpiCommon"
loadRuckusTcl "$::DIR_PATH/../PpiPgp"
