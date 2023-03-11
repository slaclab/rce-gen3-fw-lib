-------------------------------------------------------------------------------
-- Title         : Clock generation block
-- File          : RceG3Clocks.vhd
-------------------------------------------------------------------------------
-- Description:
-- Clock generation block for generation 3 RCE core.
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


library surf;
use surf.StdRtlPkg.all;

library unisim;
use unisim.vcomponents.all;

entity RceG3Clocks is
   generic (
      TPD_G        : time    := 1 ns;
      SLOW_PLL_G   : boolean := false;
      SEL_REFCLK_G : boolean := true;   -- false = ZYNQ ref, true = ETH ref
      SIMULATION_G : boolean := false);
   port (
      -- ZYNQ Reference
      fclkClk0   : in  sl;
      fclkRst0   : in  sl;
      -- Ethernet Reference Clock
      ethRefClkP : in  sl;
      ethRefClkN : in  sl;
      ethRefClk  : out sl;
      stableClk  : out sl;              -- free-running clock reference
      stableRst  : out sl;
      -- Top-level clocks and resets
      clk312     : out sl;
      rst312     : out sl;
      clk200     : out sl;
      rst200     : out sl;
      clk156     : out sl;
      rst156     : out sl;
      clk125     : out sl;
      rst125     : out sl;
      clk62      : out sl;
      rst62      : out sl;
      locked     : out sl;
      -- DMA clock and reset
      axiDmaClk  : out sl;              -- 200 MHz
      axiDmaRst  : out sl;
      -- AXI-Lite clock and reset
      axilClk    : out sl;              -- 125 MHz
      axilRst    : out sl);
end RceG3Clocks;

architecture mapping of RceG3Clocks is

   constant CLKIN_PERIOD_C    : real    := ite(SEL_REFCLK_G, 12.8, 10.0);  -- true = 156.25MHz/2, false = 100MHz
   constant CLKFBOUT_MULT_F_C : real    := ite(SEL_REFCLK_G, 16.0, ite(SLOW_PLL_G, 6.25, 12.5)); -- VCO = 1.25 GHz (625Mhz for SLOW PLL)
   constant CLK0_DIV_G        : real    := ite(SLOW_PLL_G, 4.0, 6.25);      -- 156.25 / 200Mhz
   constant CLK1_DIV_G        : integer := ite(SLOW_PLL_G, 2,      4);      -- 312.5Mhz
   constant CLK2_DIV_G        : integer := ite(SLOW_PLL_G, 4,      8);      -- 156.25Mhz
   constant CLK3_DIV_G        : integer := ite(SLOW_PLL_G, 5,      10);     -- 125Mhz
   constant CLK4_DIV_G        : integer := ite(SLOW_PLL_G, 10,     20);     -- 62.5Mhz

   signal ethRefClkDiv2 : sl;
   signal stableClock   : sl;
   signal stableReset   : sl;
   signal clkOut        : slv(4 downto 0);
   signal rstOut        : slv(4 downto 0);

begin

   GEN_ZYNQ_REF : if (SEL_REFCLK_G = false) generate

      ethRefClk <= '0';

      GEN_SYNTH : if (SIMULATION_G = false) generate
         stableClock <= fclkClk0;
         stableReset <= fclkRst0;
      end generate;

      GEN_SIM : if (SIMULATION_G = true) generate
         U_SimClkRst : entity surf.ClkRst
            generic map (
               CLK_PERIOD_G      => 10 ns,
               RST_START_DELAY_G => 0 ns,
               RST_HOLD_TIME_G   => 1000 ns)
            port map (
               clkP => stableClock,
               rst  => stableReset);
      end generate;

   end generate;

   GEN_ETH_REF : if (SEL_REFCLK_G = true) generate

      ------------------
      -- Reference Clock
      ------------------
      U_IBUFDS_GTE2 : IBUFDS_GTE2
         port map (
            I     => ethRefClkP,
            IB    => ethRefClkN,
            CEB   => '0',
            ODIV2 => ethRefClkDiv2,
            O     => ethRefClk);

      U_BUFG : BUFG
         port map (
            I => ethRefClkDiv2,
            O => stableClock);

      -----------------
      -- Power Up Reset
      -----------------
      PwrUpRst_Inst : entity surf.PwrUpRst
         generic map (
            TPD_G         => TPD_G,
            SIM_SPEEDUP_G => SIMULATION_G)
         port map (
            clk    => stableClock,
            rstOut => stableReset);

   end generate;

   -----------------
   -- Clock Managers
   -----------------
   U_MMCM : entity surf.ClockManager7
      generic map(
         TPD_G              => TPD_G,
         SIMULATION_G       => SIMULATION_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => false,   -- minimize BUFG for 7-series FPGAs
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 5,
         -- MMCM attributes
         CLKIN_PERIOD_G     => CLKIN_PERIOD_C,
         CLKFBOUT_MULT_F_G  => CLKFBOUT_MULT_F_C,
         CLKOUT0_DIVIDE_F_G => CLK0_DIV_G, -- 200 MHz = (1.25 GHz/6.25)
         CLKOUT1_DIVIDE_G   => CLK1_DIV_G, -- 312.5 MHz = (1.25 GHz/4)
         CLKOUT2_DIVIDE_G   => CLK2_DIV_G, -- 156.25 MHz=(1.25GHz/8)
         CLKOUT3_DIVIDE_G   => CLK3_DIV_G, -- 125 MHz = (1.25 GHz/10)
         CLKOUT4_DIVIDE_G   => CLK4_DIV_G) -- 62.5 MHz = (1.25 GHz/20)
      port map(
         clkIn  => stableClock,
         rstIn  => stableReset,
         -- Clock Outputs
         clkOut => clkOut,
         -- Reset Outputs
         rstOut => rstOut,
         -- Status
         locked => locked);


   GEN_AXI_200 : if (SLOW_PLL_G = false) generate
      axiDmaClk <= clkOut(0);
      axiDmaRst <= rstOut(0);
   end generate;

   GEN_AXI_125 : if (SLOW_PLL_G = true) generate
      axiDmaClk <= clkOut(3);
      axiDmaRst <= rstOut(3);
   end generate;

   axilClk <= clkOut(3);
   axilRst <= rstOut(3);

   clk200 <= clkOut(0);
   clk312 <= clkOut(1);
   clk156 <= clkOut(2);
   clk125 <= clkOut(3);
   clk62  <= clkOut(4);

   rst200 <= rstOut(0);
   rst312 <= rstOut(1);
   rst156 <= rstOut(2);
   rst125 <= rstOut(3);
   rst62  <= rstOut(4);

   stableClk <= stableClock;
   stableRst <= stableReset;

end mapping;
