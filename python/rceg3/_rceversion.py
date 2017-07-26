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
import pyrogue
import pyrogue as pr
import collections

class RceVersion(pr.Device):
    def __init__(self, **kwargs):
        super(self.__class__, self).__init__(
            description="RCE Version and BSI register.", **kwargs)

        self.add(pr.RemoteVariable(
            name='FpgaVersion', 
            description='Fpga firmware version number',
            offset=0x0, 
            bitSize=32, 
            bitOffset=0,
            mode='RO'))

        self.add(pr.RemoteVariable(
            name='ScratchPad', 
            description='Scratchpad Register',
            offset=0x04, 
            bitSize=32, 
            bitOffset=0, 
            mode='RW'))

        self.add(pr.RemoteVariable(
            name='RceVersion', 
            description='RCE registers version number',
            offset=0x08, 
            bitSize=32, 
            bitOffset=0, 
            mode='RO'))

        self.add(pr.RemoteVariable(
            name='DeviceDna', 
            description='Xilinx Device DNA Value',
            offset=0x20, 
            bitSize=64, 
            bitOffset=0, 
            mode='RO'))

        self.add(pr.RemoteVariable(
            name='EFuseValue', 
            description='Xilinx E-Fuse Value',
            offset=0x30, 
            bitSize=32, 
            bitOffset=0,
            mode='RO'))

        self.add(pr.RemoteVariable(
            name='EthMode', 
            description='Ethernet Mode',
            offset=0x34, 
            bitSize=32, 
            bitOffset=0,
            mode='RO'))

        self.add(pr.RemoteVariable(
            name='HeartBeat', 
            description='A constantly incrementing value',
            offset=0x38, 
            bitSize=32, 
            bitOffset=0, 
            mode='RO'))

        self.add(pr.RemoteVariable(
            name='GitHash', 
            description='GIT SHA-1 Hash',
            offset=0x40, 
            bitSize=160, 
            bitOffset=0,
            mode='RO'))

        self.add(pr.RemoteVariable(
            name='BuildStamp', 
            description='Firmware build string',
            offset=0x1000, 
            bitSize=256*8, 
            bitOffset=0, 
            mode='RO'))

        self.add(pr.RemoteVariable(
            name='SerialNumber', 
            description='Serial Number',
            offset=0x140, 
            bitSize=64, 
            bitOffset=0,
            mode='RO'))

        self.add(pr.RemoteVariable(
            name='AtcaSlot', 
            description='ATCA Slot',
            offset=0x148, 
            bitSize=8, 
            bitOffset=16, 
            mode='RO'))

        self.add(pr.RemoteVariable(
            name='CobBay', 
            description='COB Bay',
            offset=0x148, 
            bitSize=8, 
            bitOffset=8, 
            mode='RO'))

        self.add(pr.RemoteVariable(
            name='CobElement', 
            description='COB Element',
            offset=0x148, 
            bitSize=8, 
            bitOffset=0,
            mode='RO'))

    # def getRcePosition(slot,bay,element): 
    #     MappedMemory *mem = new MappedMemory (1, 0x84000000, 0x00001000);
    #     mem->open();

    #     uint32_t cluster = mem->read(0x84000148);

    #     *slot = (cluster >> 16) & 0xFF;
    #     *bay = (cluster >> 8) & 0xFF;
    #     *element = cluster & 0xFF;

    #      # Slot = 0 is invalid, no BSI, return DTM
    #     if ( *slot == 0 ) {
    #         *slot    = 1;
    #         *bay     = 4;
    #         *element = 0;
    #     }

    #     mem->close();
    #     delete mem;
    