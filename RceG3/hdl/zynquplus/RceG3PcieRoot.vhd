-------------------------------------------------------------------------------
-- File       : RceG3PcieRoot.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-08-21
-- Last update: 2018-08-29
-------------------------------------------------------------------------------
-- Description: RceG3PcieRoot Wrapper
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiPkg.all;

library unisim;
use unisim.vcomponents.all;

entity RceG3PcieRoot is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Clock and reset
      axiClk          : in  sl;
      axiRst          : in  sl;
      -- GP Master, axi clock
      mGpReadMaster   : in  AxiReadMasterType;
      mGpReadSlave    : out AxiReadSlaveType   := AXI_READ_SLAVE_INIT_C;
      mGpWriteMaster  : in  AxiWriteMasterType;
      mGpWriteSlave   : out AxiWriteSlaveType  := AXI_WRITE_SLAVE_INIT_C;
      -- Local Master, axi clock
      locReadMaster   : out AxiReadMasterType  := AXI_READ_MASTER_INIT_C;
      locReadSlave    : in  AxiReadSlaveType;
      locWriteMaster  : out AxiWriteMasterType := AXI_WRITE_MASTER_INIT_C;
      locWriteSlave   : in  AxiWriteSlaveType;
      -- DMA Master, pcieAxiClk
      pcieReadMaster  : out AxiReadMasterType  := AXI_READ_MASTER_INIT_C;
      pcieReadSlave   : in  AxiReadSlaveType;
      pcieWriteMaster : out AxiWriteMasterType := AXI_WRITE_MASTER_INIT_C;
      pcieWriteSlave  : in  AxiWriteSlaveType;
      -- PCIE
      pciRefClkP      : in  sl;
      pciRefClkN      : in  sl;
      pciResetL       : out sl                 := '1';
      pcieInt         : out sl                 := '0';
      pcieRxP         : in  sl;
      pcieRxN         : in  sl;
      pcieTxP         : out sl                 := '0';
      pcieTxN         : out sl                 := '1');
end RceG3PcieRoot;

architecture mapping of RceG3PcieRoot is

begin

   assert (false) report "RCE ZYNQ Ultrascale+ uses the PS's GTs for the PCIe root complex (instead of PL GTs)" severity warning;

end mapping;
