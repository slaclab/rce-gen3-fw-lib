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

class RceBsi(pyrogue.Device):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.add(pyrogue.RemoteVariable(
            name='SerialNumber',
            description='Serial Number',
            offset=0x140,
            bitSize=64,
            mode='RO'))

        self.add(pyrogue.RemoteVariable(
            name='AtcaSlot',
            description='ATCA Slot',
            offset=0x148,
            bitSize=8,
            bitOffset=16,
            mode='RO'))

        self.add(pyrogue.RemoteVariable(
            name='CobBay',
            description='COB Bay',
            offset=0x148,
            bitSize=8,
            bitOffset=8,
            mode='RO'))

        self.add(pyrogue.RemoteVariable(
            name='CobElement',
            description='COB Element',
            offset=0x148,
            bitSize=8,
            mode='RO'))
