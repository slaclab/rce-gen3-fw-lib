# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

if { [info exists ::env(BYP_MIG_CORE)] != 1 || $::env(BYP_MIG_CORE) == 0 } {
   loadSource      -path "$::DIR_PATH/rtl/MigCore.vhd"
   loadConstraints -path "$::DIR_PATH/xdc/MigCore.xdc"
   loadIpCore      -path "$::DIR_PATH/ip/MigIpCore.xci"
} else {
   loadSource      -path "$::DIR_PATH/rtl/MigCoreEmpty.vhd"
   loadConstraints -path "$::DIR_PATH/xdc/MigCoreEmpty.xdc"
}

loadSource      -path "$::DIR_PATH/rtl/MigCorePkg.vhd"
