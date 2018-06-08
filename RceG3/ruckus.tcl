# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code
loadSource -dir  "$::DIR_PATH/hdl/"

loadSource -path "$::DIR_PATH/simlink/rtl/RceG3CpuSim.vhd"

loadIpCore -dir  "$::DIR_PATH/coregen/processing_system7_0/"

loadSource -sim_only -path "$::DIR_PATH/tb/rceg3_tb.vhd"

set_property ip_repo_paths "$::DIR_PATH/coregen/iprepo/" [current_fileset]
update_ip_catalog

loadBlockDesign -path "$::DIR_PATH/coregen/pcie_root/pcie_root.bd"

#loadSource -dir  "$::DIR_PATH/coregen/pcie_root/synth/"

#loadSource      -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_auto_cc_0/synth/"
#loadConstraints -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_auto_cc_0/"

#loadSource      -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_auto_cc_1/synth/"
#loadConstraints -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_auto_cc_1/"

#loadSource      -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_auto_cc_2/synth/"
#loadConstraints -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_auto_cc_2/"

#loadSource      -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_auto_ds_0/synth/"
#loadConstraints -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_auto_ds_0/"

#loadSource      -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_auto_ds_1/synth/"
#loadConstraints -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_auto_ds_1/"

#loadSource      -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_auto_pc_0/synth/"
#loadConstraints -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_auto_pc_0/"

#loadSource      -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_auto_us_0/synth/"
#loadConstraints -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_auto_us_0/"

#loadIpCore "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_axi_interconnect_0_0/pcie_root_axi_interconnect_0_0.xci"
#loadIpCore "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_axi_interconnect_1_0/pcie_root_axi_interconnect_1_0.xci"

#loadSource      -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_axi_pcie_0_0/synth/"
#loadConstraints -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_axi_pcie_0_0/synth/"

#loadSource      -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_axi_pcie_0_0/hdl/"
#loadSource      -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_axi_pcie_0_0/synth/"
#loadConstraints -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_axi_pcie_0_0/pcie_root_axi_pcie_0_0/source"

#loadIpCore      -path "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_system_ila_0_0/pcie_root_system_ila_0_0.xci"
#loadIpCore      -path "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_system_ila_1_0/pcie_root_system_ila_1_0.xci"

#loadSource -dir      "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_xbar_0/synth/"
#loadConstraints -dir "$::DIR_PATH/coregen/pcie_root/ip/pcie_root_xbar_0/"

#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/0cde/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/2c2b/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/2c14/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/2c14/hdl/verilog"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/2f66/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/7aff/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/67bb/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/67d8/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/0513/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/1229/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/2751/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/2875/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/2875/hdl/verilog"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/6078/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/6180/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/6180/hdl/verilog"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/9340/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/a08d/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/a08d/hdl/verilog"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/b752/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/d114/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/d293/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/d322/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/d371/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/e6d5/hdl/"
#loadSource -dir "$::DIR_PATH/coregen/pcie_root/ipshared/ec67/hdl/"

