# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Get the family type
set family [getFpgaFamily]

# Check for version 2018.1 of Vivado (or later)
if { [VersionCheck 2018.1] < 0 } {exit -1}

# Check for submodule tagging
if { [info exists ::env(OVERRIDE_SUBMODULE_LOCKS)] != 1 || $::env(OVERRIDE_SUBMODULE_LOCKS) == 0 } {
   if { [SubmoduleCheck {ruckus} {2.0.1}  ] < 0 } {exit -1}
   if { [SubmoduleCheck {surf}   {2.18.1} ] < 0 } {exit -1}
} else {
   puts "\n\n*********************************************************"
   puts "OVERRIDE_SUBMODULE_LOCKS != 0"
   puts "Ignoring the submodule locks in axi-pcie-core/ruckus.tcl"
   puts "*********************************************************\n\n"
} 

# Load local Source Code
loadSource -lib rce_gen3_fw_lib -dir "$::DIR_PATH/hdl"
loadSource -lib rce_gen3_fw_lib -dir "$::DIR_PATH/hdl/${family}"
loadIpCore -dir "$::DIR_PATH/coregen/${family}"
