import RceG3
import pyrogue as pr

class RceEthernet(pr.Device):
    def __init__(self, **kwargs):
        
        # Offset of this module is always the same
        # Override any offset passed in
        kwargs['offset'] = 0xB0000000 
        super().__init__(**kwargs)

        self.add(pr.RemoteCommand(
            name = 'CountReset',
            offset = 0x000,
            function = pr.RemoteCommand.toggle))

        self.add(pr.RemoteVariable(
            name = 'PhyConfig',
            mode = 'RO',
            offset = 0x008,
            bitOffset = 0,
            bitSize = 7,
            base = pr.UInt))

        self.add(pr.RemoteVariable(
            name = 'PauseTime',
            offset = 0x10,
            bitOffset = 0,
            bitSize = 16,
            base = pr.UInt,
            mode = 'RO'))

        self.add(pr.RemoteVariable(
            name = 'MacAddressRaw',
            offset = 0x014,
            bitOffset = 0,
            bitSize = 48,
            base = pr.UInt,
            mode = 'RO'))

        self.add(pr.LinkVariable(
            name = 'MacAddress',
            mode = 'RO',
            dependencies = [self.MacAddressRaw]
            linkedGet = lambda: ':'.join(f'{b:02x}' for b in self.MacAddressRaw.value().to_bytes(6, 'little'))))
        
        self.add(pr.RemoteVariable(
            name = 'IpAddressRaw',
            offset = 0x01C,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RW'))

        self.add(pr.LinkVariable(
            name = 'IpAddress',
            mode = 'RW',
            dependencies = [self.IpAddressRaw]
            linkedGet = lambda: '.'.join(f'{b:d}' for b in self.IpAddressRaw.value().to_bytes(4, 'little'))
            linkedSet = lambda value: self.IpAddressRaw.set(int.from_bytes((int(x) for x in value.split('.')), 'little')            
        
        self.add(pr.RemoteVariable(
            name = 'PhyStatus',
            offset = 0x020,
            bitOffset = 0,
            bitSize = 8,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'PhyDebug',
            offset = 0x024,
            bitOffset = 0,
            bitSize = 6,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'TxShift'
            offset = 0x038,
            bitOffset = 0,
            bitSize = 4,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'RxShift',
            offset = 0x038,
            bitOffset = 4,
            bitSize = 4,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'FiltEnable',
            offset = 0x038,
            bitOffset = 16,
            bitSize = 1,
            base = pr.Bool,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'IpChecksumEnable',
            offset = 0x038,
            bitOffset = 17,
            bitSize = 1,
            base = pr.Bool,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'TcpChecksumEnable',
            offset = 0x038,
            bitOffset = 18,
            bitSize = 1,
            base = pr.Bool
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'UdpChecksumEnable',
            offset = 0x038,
            bitOffset = 19,
            bitSize = 1,
            base = pr.Bool,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'DropOnPause',
            offset = 0x038,
            bitOffset = 20,
            bitSize = 1,
            base = pr.Bool,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'EthHeaderSize',
            offset = 0x03C,
            bitOffset = 0,
            bitSize = 16,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'RxEnCount',
            offset = 0x100,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'R0'))
        
        self.add(pr.RemoteVariable(
            name = 'TxEnCount',
            offset = 0x104,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))

        self.add(pr.RemoteVariable(
            name = 'RxPauseCount',
            offset = 0x108,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'TxPauseCount',
            offset = 0x10C,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'RxOverflowCount',
            offset = 0x110,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'RxCrcErrorCount',
            offset = 0x114,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'TxUnderRunCount',
            offset = 0x118,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'TxNotReadyCount',
            offset = 0x11C,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'TxLocalFaultCount',
            offset = 0x120,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'RxLocalFaultCount',
            offset = 0x124,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'SyncStatus0Count',
            offset = 0x128,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'SyncStatus1Count',
            offset = 0x12C,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'SyncStatus2Count',
            offset = 0x130,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'SyncStatus3Count',
            offset = 0x134,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'AlignmentCount',
            offset = 0x138,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'RxLinkStatusCount',
            offset = 0x13C,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))
        
        self.add(pr.RemoteVariable(
            name = 'RxFifoDropCount',
            offset = 0x140,
            bitOffset = 0,
            bitSize = 32,
            base = pr.UInt,
            mode = 'RO'))
        
