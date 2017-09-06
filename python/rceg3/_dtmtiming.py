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
import pyrogue as pr


class RceDtmTiming(pr.Device):
    def __init__(self, **kwargs):
        super(self.__class__, self).__init__(
            description="RCE DTM Timing Registers.", **kwargs)

        self.addRemoteVariables(
            number=8,
            stride=4,
            name="FbDelay",
            description='FbDelay Value For Dpm',
            offset=0x100,
            mode='RW',
            bitSize=5,
            bitOffset=0,
            base=pr.UInt,
            disp='range',
            minimum=0,
            maximum=31)

        self.addRemoteVariables(
            number=8,
            stride=4,
            name="FbErrors",
            description='FbErrors Value For Dpm',
            offset=0x200,
            bitSize=16,
            bitOffset=16,
            base=pr.UInt,
            mode='RO')

        self.addRemoteVariables(
            number=8,
            stride=4,
            name="FbIdle",
            description='FbIdle Value For Dpm',
            offset=0x200,
            bitSize=16,
            bitOffset=0,
            base=pr.UInt,
            mode='RO')

        self.addRemoteVariables(
            number=8,
            stride=4,
            name="RxCount",
            description='Rx Data Count For Dpm',
            offset=0x500,
            bitSize=16,
            bitOffset=0,
            base=pr.UInt,
            mode='RO')

        self.add(pr.RemoteVariable(
            name='TxCount0', 
            description='TX Data 0 Counter',
            offset=0x414, 
            bitSize=32, 
            bitOffset=0))

        self.add(pr.RemoteVariable(
            name='TxCount1', 
            description='TX Data 1 Counter',
            offset=0x418, 
            bitSize=32, 
            bitOffset=0))

        self.add(pr.RemoteCommand(
            name='TxCmd0',
            description='Transmit Data On Channel 0',
            offset=0x400,
            bitSize=10,
            function=RemoteCommand.touch))

        self.add(pr.RemoteCommand(
            name='TxCmd1',
            description='Transmit Data On Channel 1',
            offset=0x410,
            bitSize=10,
            function=RemoteCommand.touch))

        self.add(pr.RemoteCommand(
            name='CountReset',
            offset=0x41C,
            bitSize=1,
            function=RemoteCommand.touchOne))

    def countReset(self):
        self.CountReset()

            

        
