\************************************************************************
\   main.asm
\
\   Main BeebSCSI_ROM functions
\   BeebSCSI_ROM - BeebSCSI Utility ROM
\   Copyright (C) 2017 Simon Inns
\
\   This file is part of BeebSCSI_ROM.
\
\   BeebSCSI_ROM is free software: you can redistribute it and/or modify
\   it under the terms of the GNU General Public License as published by
\   the Free Software Foundation, either version 3 of the License, or
\   (at your option) any later version.
\
\   This program is distributed in the hope that it will be useful,
\   but WITHOUT ANY WARRANTY; without even the implied warranty of
\   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
\   GNU General Public License for more details.
\
\   You should have received a copy of the GNU General Public License
\   along with this program.  If not, see <http://www.gnu.org/licenses/>.
\
\   Email: simon.inns@gmail.com
\
\************************************************************************

\\ Note: Contains code enhancements and suggestions by J.G. Harston
\\       http://mdfs.net/

\\ Global constants (OS calls)
osasci = &FFE3                              ; OS call to print an ASCII character
osargs = &FFDA                              ; OS call to read or write information on open objects or the filing system
osword = &FFF1                              ; OS call, general purpose (used to send custom SCSI commands to ADFS and VFS)
osbyte = &FFF4                              ; OS call, general purpose
osfile = &FFDD                              ; OS call, file system

\\ romFlags points to the base of the ROM flag byte (needs to be offset by the ROM number)
romFlags = &DF0                             ; The base of the ROM workspace (&DF0 + ROM number <0-15>)

\\ OS temp zero page allocations (uses ZP &A8 to &AF)
workspaceAddress = &A8                      ; Zero page storage location for 16-bit workspace address
workspaceAddressHi = &A9                    ; &A8-&A9 should not be used for anything else

\\ Used by the parameter parsing function
iIntegerLo = &AA                            ; Parameter parsing integer low byte
iIntegerHi = &AB                            ; Parameter parsing integer high byte
iCounter = &AC                              ; Parameter parsing counter

\\ Used by decimal number print function
iNumber = &AA
iStore = &AB

\\ Used by the string display function
stringTableAddr = &AA                       ; String table pointer (low byte)
stringTableAddrHi = &AB                     ; String table pointer (high byte)
stringNumber = &AC                          ; String number for text display function

bitmaskPattern = &AD                        ; Bit mask used by * command processing

\\ String identification constants
stringStarHelp                  = 00
stringStarHelpExtended          = 01
stringLun                       = 02
stringIsStopped                 = 03
stringIsStarted                 = 04
stringCurrentJuke               = 05
stringFixedEmulationMode        = 06
stringLvdosEmulationMode        = 07
stringDscTitle                  = 08
stringDscHeads                  = 09
stringDscCylinders              = 10
stringDscStep                   = 11
stringDscRwcc                   = 12
stringDscLandingZone            = 13
stringFirmwareVersion           = 14

\\ Constants (other)
EOL = &0D                                   ; Parameter parsing EOL character (&0D is ASCII CR)
SPACE = &20                                 ; Parameter parsing SPACE character (&20 is ASCII space)

\\ Rom type byte:
\\
\\ Bit 7 - Service entry present bit - 6502 BASIC doesn't have one
\\ Bit 6 - Language entry point present bit - languages only
\\ Bit 5 - Set if got a 2nd processor relocation address
\\ Bit 4 - Set if ROM supports Electron firmkeys (KEY+FUNC/KEY+CAPS LK)
\\
\\ Bits 3, 2, 1 and 0
\\ 0000 - 6502 (or 65C12) 6502 BASIC ROM
\\ 0001 - Reserved
\\ 0010 - 6502 (or 65C12) code but not the 6502 BASIC ROM
\\ 0011 - 68000 code
\\ 1000 - Z80 code
\\ 1001 - 32016 code
\\ 1010 - Reserved
\\ 1011 - 80186 code
\\ 1100 - 80286 code
\\ 1101 - ARM code

\\ Set bits 7 and 1 = %1000 0010 = &82
romTypeByte = &82

\\ ROM version number
romVersion = &01

\\ Start of the actual code
ORG &8000                                   ; Assemble at &8000
GUARD &C000                                 ; Do not exceed 16 Kbytes
.codeStart

\\ The ROM header information
.romHeader
    BRK : BRK : BRK                         ; Not a language = NULL
    JMP serviceEntryPoint                   ; Jump to service entry point
    EQUB romTypeByte                        ; ROM type (see above for details)
    EQUB copyright MOD 256                  ; Offset pointer to copyright string
    EQUB romVersion                         ; Version number
    EQUS "BeebSCSI Utilities", 0            ; Title string (null terminated)
    EQUS "1.03"                             ; Version string (terminated by 0 before (c))

    .copyright
        EQUS 0, "(C)"                       ; Mandatory start of title string
        EQUS "2018 Simon Inns", 0           ; Title string (null terminated)

\\ ------------------------------------------------------------------------------------------------
\\ Function: serviceEntryPoint
\\ Purpose: The service entry handler
\\
\\ A = service call number
\\ X = number of current ROM socket
\\ Y = any other parameters (if applicable)
.serviceEntryPoint
    \\ Get workspace flags

    \\ Both bit 7 and bit 6 are used, with %00xxxxxx and %11xxxxxx indiating the ROM is enabled with
    \\ workspace at &0000 or &C000, and %01xxxxxx and %10xxxxxx indicating the ROM is disabled
    PHA                                     ; Preserve A
    LDA romFlags, X                         ; Get workspace flags
    BMI checkRomDisabled
    EOR #&40                                ; Toggle bit 6 if bit 7 is zero

    .checkRomDisabled
        ASL A
        BPL romDisabled                     ; Exit if bit 6 is clear
        PLA                                 ; Restore A

        \\ Service event &01 - Shared low RAM space claim
        CMP #&01                            ; if A == 01 then
        BEQ serviceCall01                   ; Branch to serviceCall01

        \\ Service event &04 - Star command not recognised
        CMP #&04                            ; if A == &04 then
        BEQ serviceCall04                   ; Branch to serviceCall04

        \\ Service event &09 - *HELP issued
        CMP #&09                            ; if A == &09 then
        BEQ serviceCall09                   ; Branch to serviceCall09

        \\ Service event &22 - HAZEL high RAM private space claim
        CMP #&22                            ; if A == &22 then
        BEQ serviceCall22                   ; Branch to serviceCall22

        \\ Service event &24 - State how much HAZEL high RAM private space is needed
        CMP #&24                            ; if A == &24 then
        BEQ serviceCall24                   ; Branch to serviceCall24

        \\ End of handled service events.  Return control to OS
        RTS

    .romDisabled
        PLA                                 ; ROM disabled, restore A
        RTS                                 ; Exit

\\ ------------------------------------------------------------------------------------------------
\\ Function: serviceCall09
\\ Purpose: The service "*HELP issued" handler
\\
\\ The location (&F2),Y points to any text supplied with
\\ the *HELP or ASCII 13 if only *HELP was issued.
.serviceCall09
    PHA                                     ; Preserve A
    TYA : PHA                               ; Preserve Y

    \\ Check if there are additional characters after *HELP
    LDA (&F2), Y                            ; Get the next character byte
    CMP #13                                 ; is it ASCII 13?
    BNE checkAdditionalHelpText             ; Yes, so go to the additional help text check
    
    \\ Print the ROM name (non-extended help)
    .displayHelp
        LDA #stringStarHelp                 ; Specify the string to display
        JSR displayText                     ; Display the text

        \\ Exit from the help service
        JMP exitHelp

    \\ Check the additional help text to see if we should respond
    .checkAdditionalHelpText
        LDX #&FF                            ; Set X to &FF so first loop will increment counter to zero
        DEY                                 ; Decrement character pointer by 1

    .compareHelpText
        INX                                 ; Increment loop counter
        INY                                 ; Increment character pointer
        LDA (&F2), Y                        ; Get the current character
        AND #&DF                            ; Force the character to upper case
        CMP helpTable, X                    ; Compare the character against our help table
        BEQ compareHelpText                 ; If it matches, loop again for the next character

        LDA helpTable, X                    ; Mismatch occurred, get next character from help table
        CMP #&FF                            ; If the next character is a terminator then we matched
        BNE exitHelp                        ; If it wasn't a match, just exit

        \\ Print out the extended help
        LDA #stringStarHelpExtended         ; Specify the string to display
        JSR displayText                     ; Display the text

    \\ Return from serviceStarHelpIssued
    .exitHelp
        PLA : TAY                           ; Restore Y
        PLA                                 ; Restore A
        RTS                                 ; Return

    \\ The help table contains the extended help string to match on
    .helpTable
        EQUS "BEEBSCSI", &FF

\\ ------------------------------------------------------------------------------------------------
\\ Function: serviceCall01
\\ Purpose: Shared low RAM space claim
\\
\\ Y contains the current upper limit of the absolute workspace
.serviceCall01
    \\ Check if we are running on a BBC Micro or a Master
    LDA osfile                              ; Check filing system entry point
    CMP #&6C                                ; If FileSwitch RAM exists, it will be a JMP abs
    BCS serviceCall01BBC                    ; It's a JMP (vector), so always use low workspace on BBC Micro

    \\ This is a Master - check if HAZEL allocation was successful
    LDA romFlags, X                         ; Get the romFlags for our ROM number
    CMP #&DC                                ; Is romFlags pointing at the top of HAZEL?
    BCC serviceCall01Exit                   ; HAZEL is available, so we will use it
    
    .serviceCall01BBC
        LDA #&0E                                ; &0E00 is the workspace location for shared low memory
        STA romFlags, X
        CPY #&0E + 1                            ; Check if one page of shared low memory is available
        BCS serviceCall01Exit                   ; There is already enough shared low memory available, just quit

        LDY #&0E + 1                            ; Request a page of shared low memory (as none was available)

    .serviceCall01Exit
        LDA #&01                                ; Restore service event in A
        RTS                                     ; Exit

\\ ------------------------------------------------------------------------------------------------
\\ Function: serviceCall22
\\ Purpose: HAZEL high RAM private space claim - Master only
\\
\\ Y contains the first available HAZEL page
.serviceCall22
    CPY #&DC                            ; &DC is the top of HAZEL and Y contains the first available page
    BCC hazelWorkspaceRemaining         ; Branch if there is HAZEL RAM remaining (Y < &DC)
    LDY #&DC                            ; No HAZEL left... point to the top of HAZEL

    .hazelWorkspaceRemaining
        TYA                                 ; Copy HAZEL start address to A
        STA romFlags, X                     ; Store the location of our workspace

        INY                                 ; Claim a page

        \\ At this point romFlags is either not &DC (pointing at our shared workspace) or
        \\ equal to &DC (there is no shared workspace available).

        LDA #&22                            ; Restore service event in A
        RTS                                 ; Exit

\\ ------------------------------------------------------------------------------------------------
\\ Function: serviceCall24 (event &24)
\\ Purpose: State how much HAZEL high RAM private space is needed - Master only
.serviceCall24
    \\ Claim 1 page (256 bytes) of HAZEL
    DEY                                 ; Claim a page

    LDA #&24                            ; Restore service event in A
    RTS                                 ; Exit

\\ ------------------------------------------------------------------------------------------------
\\ Function: serviceCall04
\\ Purpose: Service an unrecognised star command
\\
\\ The location ((?&F3*256)+?&F2)+Y points to the first character of the command
\\ If the command is not ours then preserve A and Y and pass it on
\\ If the command is accepted clear A and return (LDA#0:RTS)
.serviceCall04
    TYA : PHA                           ; Preserve Y (A contained service call number - overwritten)
    LDX #&FF                            ; Set X to &FF so first loop will increment counter to zero
    DEY                                 ; Decrement character pointer by 1

    .compareCommandText
        INY
        INX
        LDA (&F2), Y                        ; Pointer to unrecognised star command
        AND #&DF                            ; Force character to uppercase
        CMP commandTable, X                 ; Check against command table
        BEQ compareCommandText              ; If it matches, continue with the next character

        \\ Last character didn't match
        LDA commandTable, X                 ; Get the byte from the table that didn't match
        BMI invokeCommand                   ; Branch is byte is > &80

        \\ Command didn't match; move to the next command and try again
    .findNextCommand
        INX                                 ; Move to the next byte in the command table
        LDA commandTable, X
        BPL findNextCommand                 ; Skip over the address (>&80) to the next command
        INX                                 ; Found the end of the address, move to the first character 
                                            ; of the next command
        PLA : PHA : TAY                     ; Retrieve the original Y into A and preserve it again
        JMP compareCommandText              ; Start the command comparison again for the next command

    .commandTable
        EQUS "SCSISTATUS"                   ; Command text to match on
        EQUB HI(scsiStatusCommand)          ; High byte of 16-bit vector address
        EQUB LO(scsiStatusCommand)          ; Low byte of 16-bit vector address
        EQUS "SCSITRACE"
        EQUB HI(scsiTraceCommand)
        EQUB LO(scsiTraceCommand)
        EQUS "SCSIJUKE"
        EQUB HI(scsiJukeCommand)
        EQUB LO(scsiJukeCommand)
        EQUS "SCSIDSC"
        EQUB HI(scsiDscCommand)
        EQUB LO(scsiDscCommand)
        EQUS "FCODER"
        EQUB HI(fcoderCommand)
        EQUB LO(fcoderCommand)
        EQUB &FF                            ; End of table marker

    .invokeCommand
        CMP #&FF                            ; Check for end of table marker
        BEQ passCommandOn                   ; No commands matched, pass on to next ROM
        STA workspaceAddressHi              ; A contains the high byte of the command vector
        INX                                 ; Point X at the low byte of the command vector
        LDA commandTable, X                 ; Get the low byte of the command vector
        STA workspaceAddress                ; A contains the low byte of the command vector
        PLA                                 ; Pull the stack - A now contains the original Y (command pointer)
        JMP (workspaceAddress)              ; Jump to the command processing vector

    \\ Pass the command on to the next ROM for processing
    .passCommandOn
        PLA                                 ; Pull the stack - A now contains the original Y (command pointer)
        TAY                                 ; Retore Y
        LDA #&04                            ; Restore A to &04 (star command not recognised service call)
        RTS                                 ; All done - return

\\ ------------------------------------------------------------------------------------------------
\\ Function: claimSharedWorkspace
\\ Purpose: Claims shared workspace ready for use (if required)
.claimSharedWorkspace
    JSR findSharedWorkspace             ; Get the workspace address
    LDA workspaceAddressHi              ; A = workspace address high byte
    BMI claimSharedWorkspaceExit        ; The Workspace is in private high memory, exit
    LDA #&8F                            ; OSBYTE &8F = Generate paged ROM service call
    LDX #&0A                            ; service &0A - Claim absolute workspace
    JSR osbyte                          ; Claim the low shared workspace
    JSR findSharedWorkspace             ; Find the shared workspace address

    .claimSharedWorkspaceExit
        RTS                             ; Exit

\\ ------------------------------------------------------------------------------------------------
\\ Function: findSharedWorkspace
\\ Purpose: Places the address of shared workspace in ZP workspaceAddress
.findSharedWorkspace
    LDX &F4
    LDA romFlags, X
    STA workspaceAddressHi              ; Get high byte of workspace pointer
    LDA #0
    STA workspaceAddress                ; Set workspace address low byte to &00

    .findSharedWorkspaceExit
        RTS                             ; Exit

\\ ------------------------------------------------------------------------------------------------
\\ Function: checkFilingSsystemType
\\ Purpose: Checks which filing system is currently selected
\\          On exit,    A = Filing system number
\\                      NE = not a supported filing system
\\                      EQ = supported filing system (ADFS or VFS) + CS = ADFS
\\                      EQ = supported filing system (ADFS or VFS) + CC = VFS                      
.checkFilingSystemType
    LDA #&00                            ; Function &00,&00 - return filing system number
    TAY
    JSR osargs
    CMP #&08
    BEQ checkFilingSystemTypeDone       ; Return with EQ+CS for ADFS
    CMP #&0A
    CLC                                 ; Return with EQ+CC for VDFS
                                        ; Return with NE for not ADFS/LVFS
    .checkFilingSystemTypeDone
        RTS

\\ ------------------------------------------------------------------------------------------------
\\ Function: scsiDscCommand
\\ Purpose: Process the *scsiDsc command - Displays the geometry descriptor for the current LUN
\\          as 22 bytes (stored in the LUN DSC file).  A SCSI MODESENSE command is used to collect
\\          the required information
.scsiDscCommand
    \\ Determine the current filing system type (ADFS, VFS, unknown)
    JSR checkFilingSystemType
    BNE scsiDscUnsupportedFs                    ; FS is not VFS or ADFS
    PHA                                         ; Push the filing system number to the stack
    JMP processscsiDscCommand

    .scsiDscUnsupportedFs
        \\ Unsupported file system selected... Generate error condition
        JMP errorOnlyAdfsVfsSupported

    .processscsiDscCommand
        \\ This command requires shared workspace, claim it if necessary
        \\ Note: This also sets workspaceAddress to point at our workspace
        JSR claimSharedWorkspace

        \\ Here we send a MODESENSE SCSI command and receive a 22 byte descriptor
        \\ for the current LUN (Drive number)
        LDX #&00                                ; X is index to the control block data
        LDY #&00                                ; Y is index to the control block
        .scsiDscControlBlockLoop
            LDA scsiModeSenseCommandBlock, X    ; Get a byte from the control block data
            STA (workspaceAddress), Y           ; Store the byte in the control block
            INX
            INY
            CPY #16                             ; End of control block data?
            BNE scsiDscControlBlockLoop

            \\ Copy the returned data address into the control block
            LDY #&01                            ; Byte pointer
            LDA #&0F                            ; LSB of returned data block
            STA (workspaceAddress), Y
            INY
            LDA workspaceAddressHi              ; MSB of returned data block
            STA (workspaceAddress), Y

        \\ Point X and Y to the command block
        LDA workspaceAddress                    ; Get low byte of address
        TAX
        LDA workspaceAddressHi                  ; Get high byte of address
        TAY

        PLA                                     ; Get the current filing system number from the stack
        CMP #&0A                                ; Is the current file system VFS?
        BEQ scsiDscSendToVFS                    ; Send OSWORD to VFS

        \\ File system is ADFS.  Use OSWORD &72
        LDA #&72                                ; Execute OSWORD &72 (ADFS)
        JSR osword
        JSR claimSharedWorkspace                ; Reclaim workspace after OSWORD call
        JMP scsiDscCheckResult

        .scsiDscSendToVFS
            \\ File system is VFS.  Use OSWORD &62
            LDA #&62                                ; Execute OSWORD &62 (VFS)
            JSR osword

        \\ Ensure the SCSI command successfully executed
        .scsiDscCheckResult
            LDY #&00
            LDA (workspaceAddress), Y               ; Get byte 0 of the command block
            \\CMP #0                                ; Is it 0? (ok)
            BEQ scsiDscPrettyPrint

            \\ Show SCSI error
            JMP errorScsi

        \\ Pretty print the DSC values for the user (using the same
        \\ field order as SuperForm)
        .scsiDscPrettyPrint
            LDA #stringDscTitle
            JSR displayText

            LDA #stringDscHeads
            JSR displayText
            LDY #15+&0F                             ; Byte 15 = number of heads
            LDA (workspaceAddress), Y
            JSR printHexNumber

            LDA #stringDscCylinders
            JSR displayText
            LDY #13+&0F                             ; Byte 13 = cylinders (MSB)
            LDA (workspaceAddress), Y
            JSR printHexNumber
            LDY #14+&0F                             ; Byte 14 = cylinders (LSB)
            LDA (workspaceAddress), Y
            JSR printHexNumber

            LDA #stringDscStep
            JSR displayText
            LDY #21+&0F                             ; Byte 21 = number of steps
            LDA (workspaceAddress), Y
            JSR printHexNumber

            LDA #stringDscRwcc
            JSR displayText
            LDY #16+&0F                             ; Byte 16 = rwcc (MSB)
            LDA (workspaceAddress), Y
            JSR printHexNumber
            LDY #17+&0F                             ; Byte 17 = rwcc (LSB)
            LDA (workspaceAddress), Y
            JSR printHexNumber

            LDA #stringDscLandingZone
            JSR displayText
            LDY #20+&0F                             ; Byte 20 = landing zone
            LDA (workspaceAddress), Y
            JSR printHexNumber

            LDA #&0D
            JSR osasci                              ; Print CR

        .scsiDscQuit
            LDA #0                                  ; Tell the MOS that the command has been serviced
            RTS                                     ; All done - return

        .scsiModeSenseCommandBlock
            \\ 15 byte control block for OSWORD &72 - SCSI MODE SENSE command
            EQUB &00            ; Controller number
            EQUD &FFFF0000      ; Transfer address
            EQUB &1A            ; SCSI command group and command
            EQUW &0000          ; LBA (LSB, 2nd byte)
            EQUB &00            ; LBA (MSB)
            EQUB &16            ; Sector count/bytes requested (22 bytes)
            EQUB &00            ; Always 0
            EQUD &00000000      ; Data length

\\ ------------------------------------------------------------------------------------------------
\\ Function: scsiStatusCommand
\\ Purpose: Process the *scsiStatus command - Gets 8 bytes of status data from BeebSCSI that
\\          indicate the current LUN status, the current LUN directory number (jukebox) and 
\\          the current emulation mode (fixed hard drive or LV-DOS laser video disc player)
.scsiStatusCommand
    \\ Determine the current filing system type (ADFS, VFS, unknown)
    JSR checkFilingSystemType
    BNE scsiStatusUnsupportedFs                 ; FS is not VFS or ADFS
    PHA                                         ; Push the filing system number to the stack
    JMP processscsiStatusCommand

    .scsiStatusUnsupportedFs
        \\ Unsupported file system selected... Generate error condition
        JMP errorOnlyAdfsVfsSupported

    .processscsiStatusCommand
        \\ This command requires shared workspace, claim it if necessary
        \\ Note: This also sets workspaceAddress to point at our workspace
        JSR claimSharedWorkspace

        \\ Here we send a BSSENSE SCSI command and receive a 8 byte status descriptor
        \\ for the current LUN (Drive number)
        LDX #&00                                ; X is index to the control block data
        LDY #&00                                ; Y is index to the control block
        .scsiStatusControlBlockLoop
            LDA scsiBSSenseCommandBlock, X      ; Get a byte from the control block data
            STA (workspaceAddress), Y           ; Store the byte in the control block
            INX
            INY
            CPY #16                             ; End of control block data?
            BNE scsiStatusControlBlockLoop

            \\ Copy the returned data address into the control block
            LDY #&01                            ; Byte pointer
            LDA #&0F                            ; LSB of returned data block
            STA (workspaceAddress), Y
            INY
            LDA workspaceAddressHi              ; MSB of returned data block
            STA (workspaceAddress), Y

        \\ Point to the command block
        LDA workspaceAddress                    ; Get low byte of address
        TAX
        LDA workspaceAddressHi                  ; Get high byte of address
        TAY
        
        PLA                                     ; Get the current filing system number from the stack
        CMP #&0A                                ; Is the current file system VFS?
        BEQ scsiStatusSendToVFS                 ; Send OSWORD to VFS

        \\ File system is ADFS.  Use OSWORD &72
        LDA #&72                                ; Execute OSWORD &72 (ADFS)
        JSR osword
        JSR claimSharedWorkspace                ; Reclaim workspace after OSWORD call
        JMP scsiStatusCheckResult

        .scsiStatusSendToVFS
            \\ File system is VFS.  Use OSWORD &62
            LDA #&62                                ; Execute OSWORD &62 (VFS)
            JSR osword

        \\ Ensure the SCSI command successfully executed
        .scsiStatusCheckResult
            LDY #&00
            LDA (workspaceAddress), Y               ; Get byte 0 of the command block
            \\CMP #0                                ; Is it 0? (ok)
            BEQ scsiStatusDisplayResult

            \\ Show SCSI error
            JMP errorScsi

        \\ Display the results to the user
        .scsiStatusDisplayResult
            \\ Pretty print the LUN status results to the user
            LDX #&00                                ; Reset X - use as LUN number pointer
            LDA #&01
            STA bitmaskPattern                      ; This is our bitmask for testing bits

            .scsiStatusPrettyPrintLoop
                LDA #stringLun                          ; Specify the string to display
                JSR displayText                         ; Display the text

                TXA
                JSR printHexNumber                      ; Output the LUN number

                LDY #&0F                                ; Point to the result block
                LDA (workspaceAddress), Y               ; Get the LUN status byte
                AND bitmaskPattern                      ; Test drive status (AND with bitmask)
                BEQ scsiStatusPrettyPrintStopped
                LDA #stringIsStarted                    ; Specify the string to display
                JSR displayText                         ; Display the text
                JMP scsiStatusPrettyPrintNext

            .scsiStatusPrettyPrintStopped
                LDA #stringIsStopped                    ; Specify the string to display
                JSR displayText                         ; Display the text

            .scsiStatusPrettyPrintNext
                INX                                     ; Next LUN
                TXA
                ASL bitmaskPattern                      ; Shift bit mask left one bit (for next LUN)
                CMP #&08                                ; Last LUN?
                BNE scsiStatusPrettyPrintLoop

                \\ Show the current jukebox number
                LDA #stringCurrentJuke                  ; Specify the string to display
                JSR displayText                         ; Display the text
                LDY #&10                                ; Point to the result block
                LDA (workspaceAddress), Y               ; Get the LUN status byte
                JSR printDecNumber                      ; Output the jukebox number (as decimal)
                LDA #&0D
                JSR osasci                              ; Print a CR

                \\ Show the current emulation mode
                LDY #&11                                ; Point to the result block
                LDA (workspaceAddress), Y               ; Get the LUN status byte
                BNE scsiStatusLvdosMode
                LDA #stringFixedEmulationMode
                JMP outputEmulationMode

            .scsiStatusLvdosMode
                LDA #stringLvdosEmulationMode           ; Specify the string to display

            .outputEmulationMode
                JSR displayText                         ; Display the text

                \\ Show the BeebSCSI firmware version major and minor
                LDA #stringFirmwareVersion
                JSR displayText
                LDY #&12                                ; Major revision number
                LDA (workspaceAddress), Y 
                JSR printDecNumber
                LDA #'.'
                JSR osasci
                LDY #&13                                ; Major revision number
                LDA (workspaceAddress), Y 
                JSR printDecNumber
                LDA #&0D
                JSR osasci

    .scsiStatusQuit
        LDA #0                              ; Tell the MOS that the command has been serviced
        RTS                                 ; All done - return

    .scsiBSSenseCommandBlock
        \\ 15 byte control block for OSWORD &72 - SCSI BSSENSE command
        EQUB &00            ; Controller number
        EQUD &FFFF0000      ; Transfer address
        EQUB &D0            ; SCSI command group and command
        EQUW &0000          ; LBA (LSB, 2nd byte)
        EQUB &00            ; LBA (MSB)
        EQUB &08            ; Sector count/bytes requested (8 bytes)
        EQUB &00            ; Always 0
        EQUD &00000000      ; Data length

\\ ------------------------------------------------------------------------------------------------
\\ Function: printHexNumber
\\ Purpose: Prints A as a 2 digit hex number using OSASCI
.printHexNumber
    PHA                                     ; Save original A
    LSR A                                   ; Shift right 4 times, padding top 4 bits with 0
    LSR A                                   ; i.e. Demoting top 4 bits, or dividing by 16
    LSR A
    LSR A
    JSR hpConvert
    PLA                                     ; Restore A
    PHA
    AND #15                                 ; Remove upper
    JSR hpConvert
    PLA
    RTS                                     ; Exit. A preserved

.hpConvert
    SED                                     ; Perform in binary coded decimal from now on
    CMP #10
    ADC #48                                 ; Add on ASCii code for the number 0
    CLD                                     ; Work in pure binary again
    JSR osasci                              ; Call osasci
    RTS

\\ ------------------------------------------------------------------------------------------------
\\ Function: printDecNumber
\\ Purpose: Prints A as a decimal number using OSASCI
.printDecNumber
    STA iNumber
    LDA #48                                 ; ASCII for '0'
    STA iStore                              ; Save in ZP
    LDA iNumber
    BEQ printDecNumberfirst                 ; If the number is 0 then just print 000
    LDA #0                                  ; Otherwise initialise A
    SED
    CLC                                     ; Operations in BCD and carry ready for ADC
    
    .printDecNumberback
        ADC #1
        BCC printDecNumbernocarry
        INC iStore
        CLC

    .printDecNumbernocarry
        DEC iNumber
        BNE printDecNumberback
        CLD                                 ; Work in binary again

    .printDecNumberfirst
        PHA                                 ; Preserve A
        LDA iStore
        JSR osasci                          ; Print the character produced by the above

    .printDecNumbersecond
        PLA                                 ; Restore A
        PHA                                 ; Preserve A
        LSR A
        LSR A
        LSR A
        LSR A                               ; Demote 4 bytes (divide by 16 in binary)
        CLC                                 ; Clear carry ready for ADC
        ADC #48                             ; Add ASC("0")
        JSR osasci                          ; Print to screen

    .printDecNumberthird
        PLA                                 ; Restore A 
        AND #15                             ; Mask off bottom 4 bits
        ADC #48
        JSR osasci                          ; Print number + ASCII 48

        RTS                                 ; Exit

\\ ------------------------------------------------------------------------------------------------
\\ Function: scsiTraceCommand
\\ Purpose: Process the *scsiTrace command
\\          This command sends a FC44WR or MODEM04WR command to BeebSCSI to 
\\          set the current trace and debug level
.scsiTraceCommand
    INY                                 ; Point to next character in command string
    JSR str2intValid                    ; Check for a valid numeric parameter
    BCS scsiTraceCommandParamError      ; Invalid parameter - Generate error condition

    JSR str2int                         ; Convert the parameter to an integer

    \\ Range check the parameter (0-255)
    LDA #0
    CMP iIntegerHi                      ; If the high byte is set, the parameter is out of Range
    BNE scsiTraceCommandParamRangeError ; Generate error condition

    \\ Determine the current filing system type (ADFS, VFS, unknown)
    JSR checkFilingSystemType
    BNE scsiTraceUnsupportedFs          ; FS is not VFS or ADFS
    BCS scsiTraceSetExternal            ; Branch if FS is ADFS
    JMP scsiTraceSetInternal            ; Jump if FS is VFS

    .scsiTraceUnsupportedFs
        \\ Unsupported file system selected... Generate error condition
        JMP errorOnlyAdfsVfsSupported

    \\ OSBYTE &97 (151) writes to SHIELA (internal 1 MHz bus)
    .scsiTraceSetInternal
        LDA #&97                            ; OSBYTE &97 - Write to SHEILA
        LDX #&84                            ; offset within page (FD84WR command-NMODEM04WR)
        LDY iIntegerLo                      ; Value to be written
        JSR osbyte
        JMP scsiTraceQuit                   ; Done

    \\ OSBYTE &93 (147) writes to FRED (external 1 MHz bus)
    .scsiTraceSetExternal
        LDA #&93                            ; OSBYTE &93 - Write to FRED
        LDX #&44                            ; offset within page (NFC44WR command)
        LDY iIntegerLo                      ; Value to be written
        JSR osbyte
        JMP scsiTraceQuit                   ; Done

    .scsiTraceCommandParamError
        JMP errorMissingOrInvalidParameter

    .scsiTraceCommandParamRangeError
        JMP errorParameterOutOfRange

    .scsiTraceQuit
        LDA #0                              ; Tell the MOS that the command has been serviced
        RTS                                 ; All done - return

\\ ------------------------------------------------------------------------------------------------
\\ Function: scsiJukeCommand
\\ Purpose: Process the *JUKE command
.scsiJukeCommand
    \\ Check the parameter for validity
    INY                                 ; Point to next character in command string
    JSR str2intValid                    ; Check for a valid numeric parameter
    BCS scsiJukeCommandParamError       ; Invalid parameter - Generate error condition

    JSR str2int                         ; Convert the parameter to an integer

    \\ Range check the parameter (0-255)
    LDA #0
    CMP iIntegerHi                      ; If the high byte is set, the parameter is out of Range
    BNE scsiJukeCommandParamRangeError  ; Generate error condition
    JMP scsiJukeDetermineFileSystem     ; All ok, continue

    .scsiJukeCommandParamError
        JMP errorMissingOrInvalidParameter

    .scsiJukeCommandParamRangeError
        JMP errorParameterOutOfRange

    \\ Parameter is stored in iIntegerLo

    \\ Determine the current filing system type (ADFS, VFS, unknown)
    .scsiJukeDetermineFileSystem
        JSR checkFilingSystemType
        BNE scsiJukeUnsupportedFs               ; FS is not VFS or ADFS
        PHA                                     ; Push the filing system number to the stack
        JMP processscsiJukeCommand

    .scsiJukeUnsupportedFs
        \\ Unsupported file system selected... Generate error condition
        JMP errorOnlyAdfsVfsSupported

    .processscsiJukeCommand
        \\ This command requires shared workspace, claim it if necessary
        \\ Note: This also sets workspaceAddress to point at our workspace
        JSR claimSharedWorkspace

        \\ Here we send a BSSELECT SCSI command and send a 8 byte select descriptor
        \\ for the current LUN (Drive number)
        LDX #&00                                ; X is index to the control block data
        LDY #&00                                ; Y is index to the control block
        .scsiJukeControlBlockLoop
            LDA scsiBSSelectCommandBlock, X     ; Get a byte from the control block data
            STA (workspaceAddress), Y           ; Store the byte in the control block
            INX
            INY
            CPY #16                             ; End of control block data?
            BNE scsiJukeControlBlockLoop

            \\ Copy the data (to send) address into the control block
            LDY #&01                            ; Byte pointer
            LDA #&0F                            ; LSB of data block
            STA (workspaceAddress), Y
            INY
            LDA workspaceAddressHi              ; MSB of data block
            STA (workspaceAddress), Y

        \\ Set up the descriptor block
        LDY #&0F                                ; Start of the data block
        LDA iIntegerLo                          ; The requested jukebox number
        STA (workspaceAddress), Y : INY         ; Byte &00
        LDA #&00                                ; Send &00 for the next 7 bytes
        STA (workspaceAddress), Y : INY
        STA (workspaceAddress), Y : INY
        STA (workspaceAddress), Y : INY
        STA (workspaceAddress), Y : INY
        STA (workspaceAddress), Y : INY
        STA (workspaceAddress), Y : INY
        STA (workspaceAddress), Y : INY

        \\ Point to the command block
        LDA workspaceAddress                    ; Get low byte of address
        TAX
        LDA workspaceAddressHi                  ; Get high byte of address
        TAY
        
        PLA                                     ; Get the current filing system number from the stack
        CMP #&0A                                ; Is the current file system VFS?
        BEQ scsiJukeSendToVFS                   ; Send OSWORD to VFS

        \\ File system is ADFS.  Use OSWORD &72
        LDA #&72                                ; Execute OSWORD &72 (ADFS)
        JSR osword
        JSR claimSharedWorkspace                ; Reclaim workspace after OSWORD call
        JMP scsiJukeCheckResult

        .scsiJukeSendToVFS
            \\ File system is VFS.  Use OSWORD &62
            LDA #&62                                ; Execute OSWORD &62 (VFS)
            JSR osword
            JSR claimSharedWorkspace                ; Reclaim workspace after OSWORD call

        \\ Ensure the SCSI command successfully executed
        .scsiJukeCheckResult
            LDY #&00
            LDA (workspaceAddress), Y               ; Get byte 0 of the command block
            \\CMP #0                                ; Is it 0? (ok)
            BEQ scsiJukeQuit

            \\ Show SCSI error
            JMP errorCouldNotJuke

    .scsiJukeQuit
        LDA #0                              ; Tell the MOS that the command has been serviced
        RTS                                 ; All done - return

    .scsiBSSelectCommandBlock
        \\ 15 byte control block for OSWORD &72 - SCSI BSSELECT command
        EQUB &00            ; Controller number
        EQUD &FFFF0000      ; Transfer address
        EQUB &D1            ; SCSI command group and command
        EQUW &0000          ; LBA (LSB, 2nd byte)
        EQUB &00            ; LBA (MSB)
        EQUB &08            ; Sector count/bytes to send (8 bytes)
        EQUB &00            ; Always 0
        EQUD &00000000      ; Data length

\\ ------------------------------------------------------------------------------------------------
\\ Function: fcoderCommand
\\ Purpose: Process the *FCODER command
\\
\\          Collects any waiting FCODE response text from VFS and displays it to the user
.fcoderCommand
    \\ Determine the current filing system type (ADFS, VFS, unknown)
    JSR checkFilingSystemType
    BNE scsifcoderUnsupportedFs             ; FS not ADFS or VFS
    BCC processfcoderCommand                ; Branch if FS is VFS, continue if ADFS

    .scsifcoderUnsupportedFs
        \\ Unsupported file system selected... Generate error condition
        JMP errorOnlyVfs

    .processfcoderCommand
        \\ This command requires shared workspace, claim it if necessary
        \\ Note: This also sets workspaceAddress to point at our workspace
        JSR claimSharedWorkspace

        LDA workspaceAddress
        TAX
        LDA workspaceAddressHi
        TAY
        LDA #&64
        JSR osword                          ; Get F-Code response
        JSR claimSharedWorkspace            ; Reclaim workspace after OSWORD call

    \\ Show the returned 16 bytes of ASCII
    .showfcodeoutput
        LDY #&00                            ; Y is our byte index = 0

        .showfcodeoutputLoop
            LDA (workspaceAddress), Y       ; Get a byte of the response
            JSR osasci                      ; Display the byte
            CMP #&0D                        ; CR?
            BEQ fcoderQuit
            INY                             ; Next byte
            TYA
            CMP #16                         ; 16 bytes?
            BNE showfcodeoutputLoop

    .fcoderQuit
        LDA #0                              ; Tell the MOS that the command has been serviced
        RTS                                 ; All done - return

\\ ------------------------------------------------------------------------------------------------
\\ Function: str2intValid
\\ Purpose: Ensures a string is a valid integer (ignores leading spaces) and converts
\\          each valid character to its numeric equivalent.  Both EOL and SPACE counter
\\          as the 'end of number' terminator.
\\          
\\          String address should be stored at &F2 (ZP)
\\          Y points to the current character of the string (and is preserved)
.str2intValid
    TYA : PHA                   ; Preserve Y

\\ Skip leading white-space
.str2intSkipSpace
    LDA (&F2),Y                 ; Load the accumulator with the character at the Y offset of the string address
    CMP #EOL                    ; Compare the accumulator with EOL
    BEQ str2intInvalid          ; Parameter is nothing but spaces until EOL!  Invalid
    CMP #SPACE                  ; Compare the accumulator with SPACE
    BNE str2intValidLoop        ; If it is not a SPACE, branch to str2intValidLoop
    LDA #0                      ; Load accumulator with 0
    STA (&F2),Y                 ; Write 0 to the current character
    INY                         ; Increment the Y register by 1
    JMP str2intSkipSpace        ; Look for the next character

.str2intValidLoop
    LDA (&F2),Y                 ; Load the accumulator with the character at the X offset of the string address

    CMP #SPACE                  ; Compare the accumulator with SPACE
    BEQ str2intValidEol         ; If it is SPACE, branch to str2intValidEol
    CMP #EOL                    ; Compare the accumulator with EOL
    BNE str2intValidCheck       ; If it is not EOL, branch to str2intValidCheck (check if ascii)

.str2intValidEol
    CPY #0                      ; Compare Y register with 0 (It is EOL, is this first character?)
    BEQ str2intInvalid          ; If Y is 0, branch to str2intInvalid (It is the first character and EOL, it is invalid)
    CLC                         ; If Y is not 0, clear carry
    PLA : TAY                   ; Restore Y
    RTS                         ; Return from str2intValid (exit)

.str2intValidCheck
    CMP #&30                    ; Compare accumulator with &30 (is it less than ‘0’, ascii 48)
    BCC str2intInvalid          ; If it’s less than 0 branch to str2intInvalid (it is an invalid character)
    CMP #&3A                    ; Compare accumulator with &3A (is it greater than ‘9’, ascii 58)
    BCS str2intInvalid          ; If it’s greater than 9 branch to str2intInvalid (it is an invalid character)
    AND #&0F                    ; Clear the 4 high bits
    STA (&F2),Y                 ; Save the low 4 bits to the Y offset of the string address
    INY                         ; Increment the Y register by 1
    BCC str2intValidLoop        ; Branch to the start of the string check loop (str2intValidLoop)

.str2intInvalid
    SEC                         ; Set carry flag to indicate error
    PLA : TAY                   ; Restore Y
    RTS                         ; Return from str2intValid (exit)

\\ ------------------------------------------------------------------------------------------------
\\ Function: multiplyBy10
\\ Purpose: Multiply Integer by 10
\\
\\          String address should be stored at &F2 (ZP)
\\          Y points to the current character of the string
.multiplyBy10
    LDA iIntegerHi              ; Load the accumulator with the high byte of the integer address
    PHA                         ; Push the accumulator onto the stack (saving the byte)

    LDA iIntegerLo              ; Load the accumulator with the low byte of the integer address

    ASL iIntegerLo              ; Multiply the accumulator by 2
    ROL iIntegerHi

    ASL iIntegerLo              ; Multiply the accumulator by 2
    ROL iIntegerHi                
    
    ADC iIntegerLo              ; Add to self  (effectively multiplying by 5 now)  
    STA iIntegerLo

    PLA 
    ADC iIntegerHi
    STA iIntegerHi
    ASL iIntegerLo                  
    ROL iIntegerHi              ; Multiply the accumulator by 2 (effectively multiplied by 10 now)

    LDA (&F2),Y                 ; Load accumulator with next character from string          
    ADC iIntegerLo              ; Add the accumulator to the integer low byte address value
    STA iIntegerLo              ; Store the accumulator  at the integer low byte address

    LDA #0                      ; Load the accumulator with 0
    ADC iIntegerHi              ; Add accumulator to high byte address (pulls in the carry value) value
    STA iIntegerHi              ; Store the accumulator at the integer high byte address
    RTS                         ; Return from multiplyBy10 (exit)

\\ ------------------------------------------------------------------------------------------------
\\ Function: str2int
\\ Purpose: Convert a string to integer (both SPACE and EOL count as terminators).
\\          You must call str2intValid before using this function
\\
\\          String address should be stored at &F2 (ZP)
\\          Y points to the current character of the string
.str2int
    LDA #0                      ; Load the accumulator with 0
    STA iIntegerHi              ; Store the accumulator at the integer high byte address (zero out high byte)
    LDA (&F2),Y                 ; Load the accumulator with the first character of the string
    STA iIntegerLo              ; Store the accumulator at the integer low byte address
    INY                         ; Y = Y + 1 (point at the next character)
    LDA (&F2),Y                 ; Load the accumulator with the Y offset of the string address

    CMP #SPACE                  ; Compare accumulator with SPACE
    BEQ str2intCont             ; If SPACE, branch to str2intCont
    CMP #EOL                    ; Compare accumulator with EOL
    BNE str2intNext             ; Branch if Not equal to EOL to str2intNext

.str2intCont
    CLC                         ; If EOL, clear carry flag
    RTS                         ; Return from str2int (exit)

.str2intNext
    JSR multiplyBy10            ; Jump to SubRoutine multiplyBy10 (to multiply by 10)
    BCS str2intCancel           ; Branch if carry set to str2intCancel (error, so cancel)
    INY                         ; Increment the Y register by 1
    LDA (&F2),Y                 ; Load the accumulator with the Y offset of the string address (next character)

    CMP #SPACE                  ; Compare accumulator with SPACE
    BEQ str2intNextCont         ; if SPACE, branch to str2intNextCont
    CMP #EOL                    ; Compare the accumulator with EOL
    BNE str2intNext             ; Branch if Not Equal to EOL to str2intNext

.str2intNextCont
    CLC                         ; Clear the carry flag

.str2intCancel
    RTS                         ; Return from str2int (exit)

\\ ------------------------------------------------------------------------------------------------
\\ Function: displayText
\\ Purpose: Prints a string of text from a look-up table
\\
\\          A indicates the required string number (0-255)
.displayText
    \\ Copy the requested string number to ZP memory and preserve X and Y
    STA stringNumber
    TXA : PHA                               ; Preserve X
    TYA : PHA                               ; Preserve Y

    \\ Put the pointer to the table in our zero page pointer variables
    LDA #LO(displayTextTable)
    STA stringTableAddr                     ; Store table low byte
    LDA #HI(displayTextTable)
    STA stringTableAddrHi                   ; Store table high byte

    LDX #0                                  ; X = Current string number
    LDY #0                                  ; Set our table offset pointer (Y) to zero
    CPX stringNumber                        ; Is the requested string number 0?
    BEQ displayTextOutputString             ; If so print the string

    .displayTextNextStringLoop
        LDA (stringTableAddr), Y                ; Get the current byte from the table
        \\CMP #0                                ; Is the byte a string terminator?
        BNE continueLooking                     ; if terminator branch to displayTextIncString

    .nextString
        INX                                     ; Current string number + 1
        CPX stringNumber                        ; Is this the requested string number?
        BEQ incYThenPrint                       ; If so, branch to incYThenPrint

    .continueLooking
        INY                                     ; Y = Y + 1
        BNE displayTextNextStringLoop           ; If Y didn't overflow to zero, branch to displayTextNextStringLoop
        INC stringTableAddrHi                   ; Add 1 to stringAddrHi
        JMP displayTextNextStringLoop           ; Jump to displayTextNextStringLoop

    .incYThenPrint                              
        INY                                     ; Increment Y by 1 (point to start of string) before printing
        BNE displayTextOutputString             ; If Y didn't overflow to zero, branch to displayTextOutputString
        INC stringTableAddrHi                   ; Add 1 to stringAddrHi

    .displayTextOutputString
        LDA (stringTableAddr), Y                ; Get the character to print
        \\CMP #0                                ; Is it a terminator character?
        BEQ displayTextExit                     ; If so, we are done - exit
        JSR osasci                              ; Print the character
        INY                                     ; Increment the character pointer
        BNE displayTextOutputString             ; If Y didn't overflow to zero, branch to displayTextOutputString
        INC stringTableAddrHi                   ; Increment the pointer high-byte
        JMP displayTextOutputString             ; Jump back to outputting text

    .displayTextExit
        PLA : TAY                               ; Restore Y
        PLA : TAX                               ; Restore X
        RTS                                     ; All done, exit

    .displayTextTable
        ; 0 - stringStarHelp
        EQUB &0D
        EQUS "BeebSCSI Utilities 1.03", &0D
        EQUS "  BeebSCSI", &0D
        EQUB 0
        ; 1 - stringStarHelpExtended
        EQUB &0D
        EQUS "BeebSCSI Utilities 1.03", &0D
        EQUS "  SCSIDSC", &0D
        EQUS "  SCSISTATUS", &0D
        EQUS "  SCSITRACE  <0-255>", &0D
        EQUS "  SCSIJUKE   <0-255>", &0D
        EQUS "  FCODER", &0D
        EQUB 0
        ; 2 - stringLun
        EQUS "LUN ", 0
        ; 3 - stringIsStopped
        EQUS " is not mounted", &0D, 0
        ; 4 - stringIsStarted
        EQUS " is mounted", &0D, 0
        ; 5 - stringCurrentJuke
        EQUS "Current jukebox number is ", 0
        ; 6 - stringFixedEmulationMode
        EQUS "Emulation mode is Winchester", &0D, 0
        ; 7 - stringLvdosEmulationMode
        EQUS "Emulation mode is Philips VP415", &0D, 0
        ; 8 - stringDscTitle
        EQUS "SCSI Geometry descriptor:", &0D, 0
        ; 9 - stringDscHeads
        EQUS "  Heads = &", 0
        ; 10 - stringDscCylinders
        EQUS &0D, "  Cylinders = &", 0
        ; 11 - stringDscStep
        EQUS &0D, "  Step = &", 0
        ; 12 - stringDscRwcc
        EQUS &0D, "  RWCC = &", 0
        ; 13 - stringDscLandingZone
        EQUS &0D, "  Landing Zone = &", 0
        ; 14 - stringFirmwareVersion
        EQUS "BeebSCSI firmware is v", 0

\\ ------------------------------------------------------------------------------------------------
\\ Function: errorHandler
\\ Purpose: Handlers for the various possible error conditions
.errorHandlers
    .errorOnlyAdfsVfsSupported
        LDX #&FF
        .errorOnlyAdfsVfsSupportedLoop
        INX                                     ; Next byte
        LDA errorOnlyAdfsVfsSupportedText, X    ; Fetch a byte of data
        STA &100, X                             ; Store at the bottom of the stack
        CMP #&FF                                ; Terminator byte?
        BNE errorOnlyAdfsVfsSupportedLoop       ; No, loop again
        JMP &100                                ; Execute BRK (outside of ROM)
        BRK 
        .errorOnlyAdfsVfsSupportedText
            EQUB 0                      ; BRK instruction
            EQUB &F8                    ; Error Number &F8 (Bad filing system)
            EQUS "Unsupported filing system in use - Only VFS and ADFS are allowed", 0
            EQUB &FF

    .errorMissingOrInvalidParameter
        LDX #&FF
        .errorMissingOrInvalidParameterLoop
        INX                                     ; Next byte
        LDA errorMissingOrInvalidParameterText, X    ; Fetch a byte of data
        STA &100, X                             ; Store at the bottom of the stack
        CMP #&FF                                ; Terminator byte?
        BNE errorMissingOrInvalidParameterLoop  ; No, loop again
        JMP &100                                ; Execute BRK (outside of ROM)
        BRK 
        .errorMissingOrInvalidParameterText
            EQUB 0                      ; BRK instruction
            EQUB &FC                    ; Error Number &FC (Bad number/Bad address)
            EQUS "Missing or invalid parameter", 0
            EQUB &FF

    .errorParameterOutOfRange
        LDX #&FF
        .errorParameterOutOfRangeLoop
        INX                                     ; Next byte
        LDA errorParameterOutOfRangeText, X     ; Fetch a byte of data
        STA &100, X                             ; Store at the bottom of the stack
        CMP #&FF                                ; Terminator byte?
        BNE errorParameterOutOfRangeLoop        ; No, loop again
        JMP &100                                ; Execute BRK (outside of ROM)
        BRK 
        .errorParameterOutOfRangeText
            EQUB 0                      ; BRK instruction
            EQUB &FC                    ; Error Number &FC (Bad number/Bad address)
            EQUS "Supplied parameter is out of range", 0
            EQUB &FF

    .errorScsi
        LDX #&FF
        .errorScsiLoop
        INX                                     ; Next byte
        LDA errorScsiText, X                    ; Fetch a byte of data
        STA &100, X                             ; Store at the bottom of the stack
        CMP #&FF                                ; Terminator byte?
        BNE errorScsiLoop                       ; No, loop again
        JMP &100                                ; Execute BRK (outside of ROM)
        BRK 
        .errorScsiText
            EQUB 0                      ; BRK instruction
            EQUB &C7                    ; Error Number &C7 (Disc error)
            EQUS "Filing system reported SCSI error", 0
            EQUB &FF

    .errorOnlyVfs
        LDX #&FF
        .errorOnlyVfsLoop
        INX                                     ; Next byte
        LDA errorOnlyVfsText, X                 ; Fetch a byte of data
        STA &100, X                             ; Store at the bottom of the stack
        CMP #&FF                                ; Terminator byte?
        BNE errorOnlyVfsLoop                    ; No, loop again
        JMP &100                                ; Execute BRK (outside of ROM)
        BRK 
        .errorOnlyVfsText
            EQUB 0                      ; BRK instruction
            EQUB &F8                    ; Error Number &F8 (Bad filing system)
            EQUS "Filing system must be VFS", 0
            EQUB &FF

    .errorCouldNotJuke
        LDX #&FF
        .errorCouldNotJukeLoop
        INX                                     ; Next byte
        LDA errorCouldNotJukeText, X            ; Fetch a byte of data
        STA &100, X                             ; Store at the bottom of the stack
        CMP #&FF                                ; Terminator byte?
        BNE errorCouldNotJukeLoop               ; No, loop again
        JMP &100                                ; Execute BRK (outside of ROM)
        BRK 
        .errorCouldNotJukeText
            EQUB 0                      ; BRK instruction
            EQUB &C7                    ; Error Number &C7 (Disc error)
            EQUS "Juke failed - did you *BYE?", 0
            EQUB &FF

\\ End of the actual code
.codeEnd

\\ Save the assembled code to disc
SAVE "BSRom", codeStart, codeEnd
