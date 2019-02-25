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

import datetime
import parse
import pyrogue as pr

class RceVersion(pr.Device):
    def __init__(
            self,
            description = 'Container for RceVersion Module',
            offset      = 0x00000000,
            **kwargs):
    
        super().__init__(
            description = description,
            offset      = 0x00000000, #This module using absolute address (not offsets)
            **kwargs)

        self.add(pr.RemoteVariable(
            name        = 'FpgaVersion', 
            description = 'Fpga firmware version number',
            offset      = 0x80000000, 
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'ScratchPad', 
            description = 'Scratchpad Register',
            offset      = 0x80000004, 
            mode        = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name        = 'RceVersion', 
            description = 'RCE registers version number',
            offset      = 0x80000008, 
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'DeviceDna', 
            description = 'Xilinx Device DNA Value',
            offset      = 0x80000020, 
            bitSize     = 64, 
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'EFuseValue', 
            description = 'Xilinx E-Fuse Value',
            offset      = 0x80000030, 
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'EthMode', 
            description = 'Ethernet Mode',
            offset      = 0x80000034, 
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'HeartBeat', 
            description = 'A constantly incrementing value',
            offset      = 0x80000038, 
            mode        = 'RO',
            pollInterval= 1, 
        ))
        
        self.add(pr.RemoteVariable(   
            name         = 'GitHash',
            description  = 'GIT SHA-1 Hash',
            offset       = 0x80000040,
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
            disp         = '{:07x}',
            linkedGet    = lambda: self.GitHash.value() >> 132
        ))        
        
        self.add(pr.RemoteVariable(   
            name         = 'BuildStamp',
            description  = 'Firmware Build String',
            offset       = 0x80001000,
            bitSize      = 8*256,
            base         = pr.String,
            mode         = 'RO',
            hidden       = True,
        ))        

        self.add(pr.RemoteVariable(
            name        = 'SerialNumber', 
            description = 'Serial Number',
            offset      = 0x84000140, 
            bitSize     = 64, 
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'AtcaSlot', 
            description = 'ATCA Slot',
            offset      = 0x84000148, 
            bitSize     = 8, 
            bitOffset   = 16, 
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CobBay', 
            description = 'COB Bay',
            offset      = 0x84000148, 
            bitSize     = 8, 
            bitOffset   = 8, 
            mode        = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name        = 'CobElement', 
            description = 'COB Element',
            offset      = 0x84000148, 
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
        
