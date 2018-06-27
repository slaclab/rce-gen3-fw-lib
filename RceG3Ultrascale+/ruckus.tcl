# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code
loadSource -dir  "$::DIR_PATH/rtl/"
loadSource -dir  "$::DIR_PATH/../RceG3/hdl/common"
loadSource -path "$::DIR_PATH/../RceG3/simlink/rtl/RceG3CpuSim.vhd"
loadIpCore -dir  "$::DIR_PATH/ip"

# Check for Vivado 2018.2
if { [VersionCheck 2018.2 "mustBeExact" ] < 0 } {exit -1}

# Check for submodule tagging
if { [info exists ::env(OVERRIDE_SUBMODULE_LOCKS)] != 1 || $::env(OVERRIDE_SUBMODULE_LOCKS) == 0 } {
   if { [SubmoduleCheck {ruckus} {1.6.8}  "mustBeExact" ] < 0 } {exit -1}
   if { [SubmoduleCheck {surf}   {1.8.5}  "mustBeExact" ] < 0 } {exit -1}
} else {
   puts "\n\n*********************************************************"
   puts "OVERRIDE_SUBMODULE_LOCKS != 0"
   puts "Ignoring the submodule locks in rce-gen3-fw-lib/RceG3Ultrascale+/ruckus.tcl"
   puts "*********************************************************\n\n"
}
