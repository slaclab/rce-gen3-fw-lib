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
            description="RCE Version and BSI register.", **kwargs):
        
        self.add(pyrogue.RemoteVariable(
            name='FpgaVersion',
            description='Fpga firmware version number',
            offset=0x00,
            mode='RO'))

        self.add(pyrogue.RemoteVariable(
            name='ScratchPad',
            description='Scratchpad Register',
            offset=0x04,
            mode='RW'))

        self.add(pyrogue.RemoteVariable(
            name='RceVersion',
            description='RCE registers version number',
            offset=0x08,
            mode='RO'))

        self.add(pyrogue.RemoteVariable(
            name='DeviceDna',
            description='Xilinx Device DNA Value',
            offset=0x20,
            bitsize=64,
            mode='RO'))

        self.add(pyrogue.RemoteVariable(
            name='EFuseValue',
            description='Xilinx E-Fuse Value',
            offset=0x30,
            mode='RO'))

        self.add(pyrogue.RemoteVariable(
            name='EthMode',
            description='Ethernet Mode',
            offset=0x34,
            mode='RO'))

        self.add(pyrogue.RemoteVariable(
            name='Heartbeat',
            description='A constantly incrementing value',
            offset=0x38, 
            pollInterval=1,
            mode='RO'))

        self.add(pyrogue.RemoteVariable(
            name='GitHash',
            description='GIT SHA-1 Hash',
            offset=0x40,
            bitSize=160,
            mode='RO'))
        
        @self.linkedGet(dependencies=[self.GitHash], disp='{:x}')
        def GitHashShort():
            return self.GitHash.value() >>132

        self.add(pyrogue.RemoteVariable(
            name='BuildStamp',
            description='Firmware build string',
            offset=0x1000,
            bitSize=256*8,
            base=pr.String,
            mode='RO'))

