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
import collections

class DpmTiming(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.add(pr.RemoteCommand(
            name='ClkReset',
            offset=0x0,
            function=RemoteCommand.touchOne
        ))

        self.add(pr.RemoteVariable(
            name='RxDelay0',
            offset=0x8,
            disp='range',
            minimum=0,
            maximum=31,
        ))

        self.add(pr.RemoteVariable(
            name='RxErrors0',
            offset=0xC,
            mode='RO',
            bitOffset=16,
            bitSize=16,
            pollInterval=1,
        ))

        self.add(pr.RemoteVariable(
            name='RxIdle0',
            offset=0xC,
            mode='RO',
            bitOffset=0,
            bitSize=16,
            pollInterval=1,
        ))
                 
        self.add(pr.RemoteVariable(
            name='RxDelay1',
            offset=0x18,
            disp='range',
            minimum=0,
            maximum=31,
        ))

        self.add(pr.RemoteVariable(
            name='RxErrors1',
            offset=0x1C,
            mode='RO',
            bitOffset=16,
            bitSize=16,
            pollInterval=1,
        ))

        self.add(pr.RemoteVariable(
            name='RxIdle1',
            offset=0x1C,
            mode='RO',
            bitOffset=0,
            bitSize=16,
            pollInterval=1,
        ))

        self.add(pr.RemoteCommand(
            name='CountReset',
            offset=0x20,
            function=RemoteCommand.touchOne,
        ))

        self.add(pr.RemoteVariable(
            name='RxCount0',
            offset=0x024,
            mode='RO',
            pollInterval=1,
        ))

        self.add(pr.RemoteVariable(
            name='RxCount1',
            offset=0x28,
            mode='RO',
            pollInterval=1,
        ))
        
        self.add(pr.RemoteVariable(
            name='TxCount',
            offset=0x2C,
            mode='RO',
            pollInterval=1,
        ))

        self.hideVariables(hidden=True, [self.enabled])
        self.enabled.set(True)

    def softReset(self):
        self.SoftReset()
        
    def hardReset(self):
        self.ClkReset()

