#-----------------------------------------------------------------------------
# Title      : RCE Gen3 Version Register space
#-----------------------------------------------------------------------------
# This file is part of the RCE GEN3 firmware platform. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the rogue RCE GEN3 firmware platform, including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import parse
import pyrogue as pr

class RceVersion(pr.Device):
    def __init__(
            self,
            description = 'Container for RceVersion Module',
            offset      = 0x00000000, # Unused
            intOffset   = 0x80000000, # Internal registers offset (zynq=0x80000000, zynquplus=0xB0000000)
            bsiOffset   = 0x84000000, # BSI I2C Slave Registers   (zynq=0x84000000, zynquplus=0xB0010000)
            **kwargs):

        super().__init__(
            description = description,
            offset      = 0x00000000, #This module using absolute address (not offsets)
            **kwargs)

        self.add(pr.RemoteVariable(
            name        = 'FpgaVersion',
            description = 'Fpga firmware version number',
            offset      = intOffset+0x0,
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'ScratchPad',
            description = 'Scratchpad Register',
            offset      = intOffset+0x4,
            mode        = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name        = 'RceVersion',
            description = 'RCE registers version number',
            offset      = intOffset+0x8,
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'DeviceDna',
            description = 'Xilinx Device DNA Value',
            offset      = intOffset+0x20,
            bitSize     = 64,
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'EFuseValue',
            description = 'Xilinx E-Fuse Value',
            offset      = intOffset+0x30,
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'EthMode',
            description = 'Ethernet Mode',
            offset      = intOffset+0x34,
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'HeartBeat',
            description = 'A constantly incrementing value',
            offset      = intOffset+0x38,
            mode        = 'RO',
            pollInterval= 1,
        ))

        self.add(pr.RemoteVariable(
            name         = 'GitHash',
            description  = 'GIT SHA-1 Hash',
            offset       = intOffset+0x40,
            bitSize      = 160,
            bitOffset    = 0,
            base         = pr.UInt,
            mode         = 'RO',
            hidden       = True,
        ))

        self.add(pr.LinkVariable(
            name         = 'GitHashShort',
            mode         = 'RO',
            dependencies = [self.GitHash],
            linkedGet    = lambda read: f'{(self.GitHash.get(read=read) >> 132):x}'
        ))

        self.add(pr.RemoteVariable(
            name         = 'BuildStamp',
            description  = 'Firmware Build String',
            offset       = intOffset+0x1000,
            bitSize      = 8*256,
            base         = pr.String,
            mode         = 'RO',
            hidden       = True,
        ))

        self.add(pr.RemoteVariable(
            name        = 'SerialNumber',
            description = 'Serial Number',
            offset      = bsiOffset+0x140,
            bitSize     = 64,
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'AtcaSlot',
            description = 'ATCA Slot',
            offset      = bsiOffset+0x148,
            bitSize     = 8,
            bitOffset   = 16,
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CobBay',
            description = 'COB Bay',
            offset      = bsiOffset+0x148,
            bitSize     = 8,
            bitOffset   = 8,
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CobElement',
            description = 'COB Element',
            offset      = bsiOffset+0x148,
            bitSize     = 8,
            mode        = 'RO',
        ))

        def parseBuildStamp(var, read):
            p = parse.parse("{ImageName}: {BuildEnv}, {BuildServer}, Built {BuildDate} by {Builder}", var.dependencies[0].get(read))
            if p is None:
                return ''
            else:
                return p[var.name]

        self.add(pr.LinkVariable(
            name = 'ImageName',
            mode = 'RO',
            linkedGet = parseBuildStamp,
            variable = self.BuildStamp))

        self.add(pr.LinkVariable(
            name = 'BuildEnv',
            mode = 'RO',
            linkedGet = parseBuildStamp,
            variable = self.BuildStamp))

        self.add(pr.LinkVariable(
            name = 'BuildServer',
            mode = 'RO',
            linkedGet = parseBuildStamp,
            variable = self.BuildStamp))

        self.add(pr.LinkVariable(
            name = 'BuildDate',
            mode = 'RO',
            linkedGet = parseBuildStamp,
            variable = self.BuildStamp))

        self.add(pr.LinkVariable(
            name = 'Builder',
            mode = 'RO',
            linkedGet = parseBuildStamp,
            variable = self.BuildStamp))


    def hardReset(self):
        print('RceVersion hard reset called')

    def softReset(self):
        print('RceVersion soft reset called')

    def countReset(self):
        print('RceVersion count reset called')

    def printStatus(self):
        self.BuildStamp.get()
        gitHash = self.GitHash.get()
        print("FwVersion    = {}".format(hex(self.FpgaVersion.get())))
        if (gitHash != 0):
            print("GitHash      = {}".format(hex(self.GitHash.get())))
        else:
            print("GitHash      = dirty (uncommitted code)")
        print("FwTarget     = {}".format(self.ImageName.get()))
        print("BuildEnv     = {}".format(self.BuildEnv.get()))
        print("BuildServer  = {}".format(self.BuildServer.get()))
        print("BuildDate    = {}".format(self.BuildDate.get()))
        print("Builder      = {}".format(self.Builder.get()))
