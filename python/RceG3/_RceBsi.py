import pyrogue as pr

class RceBsi(pr.Device):
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
