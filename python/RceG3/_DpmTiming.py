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

class DpmTiming(pr.Device):
    def __init__(self, **kwargs):
        super(self.__class__, self).__init__(
            description="RCE DPM Timing Registers.", **kwargs)

        self.add(pr.RemoteCommand(
            name='ClkReset',
            offset=0x0,
            function=pr.RemoteCommand.touchOne
        ))
        self.add(pr.RemoteVariable(
            name='RxDelay0', 
            description='Delay Value For Rx Data 0 input',
            offset=0x08, 
            bitSize=5, 
            bitOffset=0, 
            disp='{:d}',
            minimum=0,
            maximum=31))

        self.add(pr.RemoteVariable(
            name='RxErrors0', 
            description='RxErrors Value For Input 0',
            offset=0x0C, 
            bitSize=16, 
            bitOffset=16,
            mode='RO',
            pollInterval=1
        ))

        self.add(pr.RemoteVariable(
            name='RxIdle0', 
            description='RxIdle Value For Input 0',
            offset=0x0C, 
            bitSize=16, 
            bitOffset=0,
            mode='RO',
            pollInterval=1,
        ))

        self.add(pr.RemoteVariable(
            name='RxDelay1', 
            description='Delay Value For Rx Data 1 input',
            offset=0x18, 
            bitSize=5, 
            bitOffset=0,
            disp='{:d}',
            minimum=0,
            maximum=31,
        ))


        self.add(pr.RemoteVariable(
            name='RxErrors1', 
            description='RxErrors Value For Input 1',
            offset=0x1C, 
            bitSize=16, 
            bitOffset=16,
            mode='RO', 
            pollInterval=1))

        self.add(pr.RemoteVariable(
            name='RxIdle1', 
            description='RxIdle Value For Input 1',
            offset=0x1C, 
            bitSize=16, 
            bitOffset=0,
            mode='RO',
            pollInterval=1,
        ))



        self.add(pr.RemoteCommand(
            name='CountReset',
            offset=0x20,
            function=pr.RemoteCommand.touchOne,
        ))

        self.add(pr.RemoteVariable(
            name='RxCount0', 
            description='RxCount Value For Input 0',
            offset=0x24, 
            bitSize=32, 
            bitOffset=0,
            mode='RO',
            pollInterval=1))

        self.add(pr.RemoteVariable(
            name='RxCount1', 
            description='RxCount Value For Input 1',
            offset=0x28, 
            bitSize=32, 
            bitOffset=0,
            mode='RO',
            pollInterval=1))

        self.add(pr.RemoteVariable(
            name='TxCount',
            description='TxCount Value',
            offset=0x2C,
            mode='RO',
            pollInterval=1,
        ))

        #self.hideVariables(hidden=True, variables=[self.enable])
        #self.enable.set(True)

    def softReset(self):
        self.SoftReset()
        
    def hardReset(self):
        self.ClkReset()

