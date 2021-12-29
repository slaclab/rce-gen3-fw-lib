# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for valid FPGA 
if { $::env(PRJ_PART) != "XCZU7EV-FFVC1156-2-E" } {
   puts "\n\nERROR: PRJ_PART must be either XCZU7EV-FFVC1156-2-E in the Makefile\n\n"; exit -1
}

# Check for version 2018.3 of Vivado (or later)
if { [VersionCheck 2018.3] < 0 } {exit -1}

# Check for submodule tagging
if { [info exists ::env(OVERRIDE_SUBMODULE_LOCKS)] != 1 || $::env(OVERRIDE_SUBMODULE_LOCKS) == 0 } {
   if { [SubmoduleCheck {ruckus} {2.0.1}  ] < 0 } {exit -1}
   if { [SubmoduleCheck {surf}   {2.18.1} ] < 0 } {exit -1}
} else {
   puts "\n\n*********************************************************"
   puts "OVERRIDE_SUBMODULE_LOCKS != 0"
   puts "Ignoring the submodule locks in XilinxZcu106Core/ruckus.tcl"
   puts "*********************************************************\n\n"
} 

# Check for Vivado 2018.3
if { $::env(VIVADO_VERSION) == 2021.2 } {

   # Set the board part
   set_property board_part xilinx.com:zcu106:part0:2.6 [current_project]
   
   # Load the IPI design
   loadBlockDesign -path "$::DIR_PATH/ip/2019.1/Base_Zynq_MPSoC.bd"
   
# Check for Vivado 2019.1 (or later)
} else {

   # Set the board part
   set_property board_part xilinx.com:zcu106:part0:2.6 [current_project]
   
   # Load the IPI design
   loadBlockDesign -path "$::DIR_PATH/ip/2019.1/Base_Zynq_MPSoC.bd"
   
}

# Load local Source Code and constraints
loadSource -lib rce_gen3_fw_lib      -dir "$::DIR_PATH/hdl"
loadConstraints -dir "$::DIR_PATH/xdc"

loadSource -lib rce_gen3_fw_lib -path "$::DIR_PATH/../RceG3/hdl/zynquplus/RceG3Clocks.vhd"
loadSource -lib rce_gen3_fw_lib -path "$::DIR_PATH/../RceG3/hdl/zynquplus/RceG3Cpu.vhd"
loadSource -lib rce_gen3_fw_lib -path "$::DIR_PATH/../RceG3/hdl/zynquplus/RceG3Pkg.vhd"
loadSource -lib rce_gen3_fw_lib -dir  "$::DIR_PATH/../RceG3/hdl"

# Load the dependent source code
loadRuckusTcl "$::DIR_PATH/../PpiCommon"
loadRuckusTcl "$::DIR_PATH/../PpiPgp"
