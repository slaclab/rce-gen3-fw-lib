#!/usr/bin/env python
#-----------------------------------------------------------------------------
# Title      : RCE Gen3 Version Register space
#-----------------------------------------------------------------------------
# File       : _RceVersion.py
# Created    : 2017-02-25
#-----------------------------------------------------------------------------
# This file is part of the RCE GEN3 firmware platform. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the rogue RCE GEN3 firmware platform, including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import pr as pr

class RceVersion(pr.Device):
    def __init__(self, **kwargs):
        super(self.__class__, self).__init__(offset=0x80000000, description="RCE Version and BSI register.", **kwargs)

        self.add(pr.RemoteVariable(name='FpgaVersion', description='Fpga firmware version number',
                                   offset=0x0, bitsize=32, bitoffset=0, base=pr.UInt, mode='RO'))

        self.add(pr.RemoteVariable(name='ScratchPad', description='Scratchpad Register',
                                   offset=0x4, bitsize=32, bitoffset=0, base=pr.UInt, mode='RW'))

        self.add(pr.RemoteVariable(name='RceVersion', description='RCE registers version number',
                                   offset=0x8, bitsize=32, bitoffset=0, base=pr.UInt, mode='RO'))

        self.add(pr.RemoteVariable(name='DeviceDna', description='Xilinx Device DNA Value',
                                   offset=0x20, bitsize=64, bitoffset=0, base=pr.UInt, mode='RO'))

        self.add(pr.RemoteVariable(name='EFuseValue', description='Xilinx E-Fuse Value',
                                   offset=0x30, bitsize=32, bitoffset=0, base=pr.UInt, mode='RO'))

        self.add(pr.RemoteVariable(name='EthMode', description='Ethernet Mode',
                                   offset=0x34, bitsize=32, bitoffset=0, base=pr.UInt, mode='RO'))

        self.add(pr.RemoteVariable(name='HeartBeat', description='A constantly incrementing value',
                                   offset=0x38, bitsize=32, bitoffset=0, 
                                   pollInterval=1, base=pr.UInt, mode='RO'))

        self.add(pr.RemoteVariable(name='GitHash', description='GIT SHA-1 Hash',
                                  offset=0x40, bitSize=160, bitOffset=0, base=pr.UInt, mode='RO'))

        self.add(pr.RemoteVariable(name='BuildStamp', description='Firmware build string',
                                  offset=0x1000, bitSize=256*8, bitOffset=0, base='string', mode='RO'))

        self.add(pr.RemoteVariable(name='SerialNumber', description='Serial Number',
                                  offset=0x4000140, bitSize=64, bitOffset=0, base=pr.UInt, mode='RO'))

        self.add(pr.RemoteVariable(name='AtcaSlot', description='ATCA Slot',
                                   offset=0x4000148, bitSize=8, bitOffset=16, base=pr.UInt, mode='RO'))

        self.add(pr.RemoteVariable(name='CobBay', description='COB Bay',
                                   offset=0x4000148, bitSize=8, bitOffset=8, base=pr.UInt, mode='RO'))

        self.add(pr.RemoteVariable(name='CobElement', description='COB Element',
                                   offset=0x4000148, bitSize=8, bitOffset=0, base=pr.UInt, mode='RO'))

