   10REM ** BeebSCSI FAT file transfer utility
   20REM ** Copyright (C) 2018 Simon Inns
   30REM **
   40REM ** GPLv3 Open-source
   50REM ** See http://www.gnu.org/licenses
   60REM **
   70REM ** Application Version 1.0
   80REM ** BeebSCSI Firmware Version 002.003
   90:
  100REM Determine the best screen mode to use based
  110REM on the available RAM/Shadow-RAM
  120MODE &87 : REM Mode 7 with or without shadow...
  130os% = 0
  140REM If the current mode uses no RAM, then we have shadow RAM
  150IF HIMEM > &7C00 THEN MODE 128 : os% = 1
  160:
  170REM Global OS call block declarations
  180DIM oswordBlk% 16
  190DIM osgbpbBlk% 32
  200:
  210REM Global data buffer declarations
  220IF os% = 0 THEN dataBufSize% = 48 : REM Requires 12Kbytes 
  230IF os% = 1 THEN dataBufSize% = 64 : REM Requires 16Kbytes
  240DIM dataBuf% 256 * dataBufSize%
  250:
  260REM Check communication with BeebSCSI and the
  270REM firmware version
  280PROCcheckBeebSCSI
  290:
  300REM Configuration globals
  310listSize% = 15
  320:
  330REM Select FAT transfer directory
  340PROCselectTransferDir("/Transfer")
  350:
  360REM Start of main loop
  370quit% = 0
  380listPos% = 0
  390REPEAT
  400  CLS
  410  PRINTTAB(0,0); "BeebSCSI FAT transfer utility";
  420  PRINTTAB(0,1); "(c)2018 Simon Inns - GPLv3"
  430  PRINTTAB(0,3); "BeebSCSI FAT Files:"
  440  PRINT
  450  :
  460  REM Display a list of the available files
  470  listEnd% = FNlistFatDir(listPos%, listPos% + listSize%)
  480  :
  490  REM Prompt the user for command
  500  PRINT
  510  IF listPos% <> 0 THEN PRINT "(P)revious ";
  520  IF listEnd% <> 1 THEN PRINT "(N)ext ";
  530  PRINT "(T)ransfer (Q)uit:";
  540  :
  550  REM Get a valid command from the user
  560  validCommand% = 0
  570  REPEAT
  580    key$ = GET$
  590    IF (key$ = "Q" OR key$ = "q") THEN validCommand% = 1 : quit% = 1
  600    IF (key$ = "T" OR key$ = "t") THEN validCommand% = 1 : PROCtransferScreen
  610    IF (key$ = "P" OR key$ = "p") AND listPos% <> 0 THEN validCommand% = 1 : listPos% = listPos% - listSize% : IF listPos% < 0 THEN listPos% = 0
  620    IF (key$ = "N" OR key$ = "n") AND listEnd% <> 1 THEN validCommand% = 1 : listPos% = listPos% + listSize%
  630  UNTIL validCommand% = 1
  640UNTIL quit% = 1
  650:
  660REM All done; time to quit
  670CLS
  680PRINT
  690PRINT "Thanks for using the open-source,"
  700PRINT "open-hardware BeebSCSI! To support"
  710PRINT "development, please consider donating"
  720PRINT
  730PRINT "https://www.domesday86.com :-)"
  740PRINT
  750END
  760:
  770REM ** Function to display a list of available FAT files
  780DEF FNlistFatDir(fileId%, listEnd%)
  790LOCAL endOfList%
  800endOfList% = 0
  810REPEAT
  820  PROCgetBSInfo(fileId%)
  830  IF os% <> 0 THEN fileType% = FNdisplayBSInfo(fileId%, 40) ELSE fileType% = FNdisplayBSInfo(fileId%, 20)
  840  fileId% = fileId% + 1
  850UNTIL fileType% = 0 OR fileId% = listEnd%
  860IF fileType% = 0 THEN endOfList% = 1
  870=endOfList%
  880:
  890REM ** Function to get FAT file information
  900DEF PROCgetBSInfo(fileId%)
  910A% = &72
  920X% = oswordBlk%
  930Y% = X% DIV 256
  940REM Send BSFATINFO command G6 0x13
  950oswordBlk%?0 = 0
  960oswordBlk%!1 = dataBuf% : REM Store response in dataBuf%
  970oswordBlk%?5 = &D3 : REM BSFATINFO
  980oswordBlk%?6 = 0
  990oswordBlk%?7 = 0
 1000oswordBlk%?8 = 0
 1010oswordBlk%?9 = 1 : REM Request 1 block
 1020oswordBlk%?10 = fileId% : REM FAT file ID
 1030oswordBlk%?11 = 0
 1040CALL &FFF1
 1050ENDPROC
 1060:
 1070REM ** Function to display FAT file information
 1080REM ** Requires valid file data in dataBuf% global
 1090DEF FNdisplayBSInfo(fileId%, fileNameLength%)
 1100REM If the fileID isn't valid, just return
 1110IF dataBuf%?0 = 0 THEN = 0
 1120:
 1130REM Display the file ID number
 1140PRINT ""; fileId%; ":";
 1150:
 1160REM Display the file type
 1170IF dataBuf%?0 = 1 THEN PRINT "(F) "; : REM File
 1180IF dataBuf%?0 = 2 THEN PRINT "(D) "; : REM Directory
 1190IF dataBuf%?0 > 2 THEN PROCcommError; : REM Out of range!
 1200:
 1210REM Display the file name (as a fixed length)
 1220pointer% = 127
 1230REPEAT
 1240  IF dataBuf%?pointer% <> 0 THEN PRINT CHR$(dataBuf%?pointer%);
 1250  pointer% = pointer% + 1
 1260UNTIL pointer% = (128 + fileNameLength%) OR dataBuf%?pointer%-1 = 0
 1270:
 1280REM Display the file size
 1290PRINT TAB(fileNameLength% + 9); FNfatFileSize;
 1300IF os% <> 0 THEN PRINT " bytes" ELSE PRINT "b"
 1310:
 1320REM Return the file type
 1330= dataBuf%?0
 1340:
 1350REM ** Function to calculate the FAT file size
 1360REM ** Requires valid file data in dataBuf% global
 1370DEF FNfatFileSize
 1380LOCAL size%
 1390REM File size is a 32 bit number MSB->LSB
 1400size% = dataBuf%?1 * 16777216
 1410size% = size% + (dataBuf%?2 * 65536)
 1420size% = size% + (dataBuf%?3 * 256)
 1430= size% + dataBuf%?4
 1440:
 1450REM ** Function to display the transfer dialogue
 1460DEF PROCtransferScreen
 1470PRINT
 1480PRINT "Please enter the file ID number: ";
 1490INPUT fileId%
 1500:
 1510REM Put the file data in dataBuf%
 1520PROCgetBSInfo(fileId%)
 1530:
 1540REM Is the file valid (i.e. not directory or unknown)?
 1550IF dataBuf%?0 <> 1 THEN PRINT "Error: Not a valid file!": a$=INKEY$(200) : ENDPROC
 1560:
 1570REM Does the file have more than 0 bytes?
 1580IF FNfatFileSize = 0 THEN PRINT "Error: File has 0 length!" : a$=INKEY$(200) : ENDPROC
 1590:
 1600REM Display the transfer screen
 1610CLS
 1620PRINT TAB(0,0); "BeebSCSI FAT File transfer ("; dataBufSize% / 4; "K buffer)"
 1630PRINT TAB(0,2); "Selected file details:"
 1640PRINT
 1650IF os% <> 0 THEN fileType% = FNdisplayBSInfo(fileId%, 40) ELSE fileType% = FNdisplayBSInfo(fileId%, 20)
 1660PRINT
 1670PRINT "Please enter a valid ADFS path and"
 1680PRINT "filename such as :0.$.dir.file or hit"
 1690PRINT "RETURN to go back to the file list"
 1700INPUT destFile$
 1710IF destFile$ = "" THEN ENDPROC
 1720:
 1730REM Perform the transfer
 1740PROCtransferFile(fileId%, destFile$)
 1750:
 1760a$=INKEY$(200)
 1770ENDPROC
 1780:
 1790REM ** Function to transfer a file from FAT to ADFS
 1800REM ** Requires valid file data in dataBuf%
 1810DEF PROCtransferFile(fileId%, destFile$)
 1820:
 1830REM Open the destination file
 1840fileHandle% = OPENOUT(destFile$)
 1850:
 1860REM Set up ready for transfer
 1870currentBlock% = 0
 1880remainingBytes% = FNfatFileSize
 1890transferSize% = 256 * dataBufSize%
 1900:
 1910REM Transfer the file
 1920PRINT TAB(0,12); "Bytes remaining: "; remainingBytes%
 1930REPEAT
 1940  REM Read the data from the FAT file
 1950  IF remainingBytes% < transferSize% THEN transferSize% = remainingBytes%
                                                                                                   1960  reqBlocks% = (transferSize% / 256) + 1
 1980  PRINT TAB(0,11);"Reading from FAT"
 1990  PROCgetFatData(fileId%, currentBlock%, reqBlocks%)
 2000  currentBlock% = currentBlock% + reqBlocks%
 2010  :
 2020  REM Write the data to the ADFS file
 2030  IF remainingBytes% > transferSize% THEN bytesToWrite% = transferSize% ELSE bytesToWrite% = remainingBytes%
 2040  PRINT TAB(0,11);"Writing to ADFS "
 2050  PROCwriteDataToAdfs(fileHandle%, bytesToWrite%)
 2060  :
 2070  remainingBytes% = remainingBytes% - (reqBlocks% * 256)
 2080  IF remainingBytes% < 0 THEN remainingBytes% = 0
 2090  PRINT TAB(0,12); "Bytes remaining: "; remainingBytes%; "           ";
 2100  :
 2110UNTIL remainingBytes% = 0
 2120:
 2130CLOSE #fileHandle%
 2140PRINT TAB(0,11); "                    "
 2150PRINT TAB(0,14); "FAT File transfer complete!"
 2160ENDPROC
 2170:
 2180REM ** Function to get FAT file data
 2190DEF PROCgetFatData(fileId%, startBlock%, numberOfBlocks%)
 2200A% = &72
 2210X% = oswordBlk%
 2220Y% = X% DIV 256
 2230:
 2240oswordBlk%?0 = 0
 2250oswordBlk%!1 = dataBuf%
 2260oswordBlk%?5 = &D4 : REM BSFATREAD G6 0x14
 2270oswordBlk%?6 = (startBlock% AND &1F0000) DIV 65536
 2280oswordBlk%?7 = (startBlock% AND &FF00) DIV 256
 2290oswordBlk%?8 = startBlock%
 2300oswordBlk%?9 = numberOfBlocks%
 2310oswordBlk%?10 = fileId%
 2320oswordBlk%!11 = 0
 2330:
 2340CALL &FFF1
 2350ENDPROC
 2360:
 2370REM ** Function to set the transfer directory that
 2380REM ** is used by the BSFATINFO and BSFATREAD commands
 2390REM ** Note: Path should be "/Transfer" or "/dir/dir" etc.
 2400REM ** If the specified directory doesn't exist, BeebSCSI
 2410REM ** will create it automatically.
 2420DEF PROCselectTransferDir(pathname$)
 2430REM Clear the data buffer (256 bytes)
 2440FOR byte% = 0 TO 255
 2450  dataBuf%?byte% = 0
 2460NEXT
 2470:
 2480REM Copy the path string into the data buffer
 2490FOR byte% = 0 TO LEN(pathname$)-1
 2500  dataBuf%?byte% = ASC(MID$(pathname$, byte%+1, 1))
 2510NEXT
 2520:
 2530A% = &72
 2540X% = oswordBlk%
 2550Y% = X% DIV 256
 2560:
 2570REM Send BSFATPATH command G6 0x12
 2580oswordBlk%?0 = 0
 2590oswordBlk%!1 = dataBuf% : REM Store response in dataBuf%
 2600oswordBlk%?5 = &D2 : REM BSFATPATH
 2610oswordBlk%?6 = 0
 2620oswordBlk%?7 = 0
 2630oswordBlk%?8 = 0
 2640oswordBlk%?9 = 1 : REM Send 1 block
 2650oswordBlk%?10 = 0
 2660oswordBlk%?11 = 0
 2670CALL &FFF1
 2680ENDPROC
 2690:
 2700REM ** Function to write data to ADFS
 2710DEF PROCwriteDataToAdfs(fileHandle%, bytesToWrite%)
 2720A% = 2
 2730X% = osgbpbBlk%
 2740Y% = X% DIV 256
 2750:
 2760osgbpbBlk%?0 = fileHandle%
 2770osgbpbBlk%!1 = dataBuf%
 2780osgbpbBlk%!5 = bytesToWrite%
 2790:
 2800CALL &FFD1
 2810ENDPROC
 2820:
 2830DEF PROCcommError
 2840CLS
 2850PRINT "Error communicating with BeebSCSI"
 2860PRINT
 2870PRINT "Ensure that ADFS is selected and"
 2880PRINT "a SCSI drive is mounted."
 2890PRINT
 2900PRINT "i.e. *ADFS<CR> *MOUNT 0<CR> RUN<CR>"
 2910END
 2920ENDPROC
 2930:
 2940REM ** This function checks communication with the
 2950REM ** BeebSCSI and verifies the firmware version
 2960DEF PROCcheckBeebSCSI
 2970A% = &72
 2980X% = oswordBlk%
 2990Y% = X% DIV 256
 3000REM Send BSSENSE command G6 0x10
 3010oswordBlk%?0 = 0
 3020oswordBlk%!1 = dataBuf% : REM Store response in dataBuf%
 3030oswordBlk%?5 = &D0 : REM BSSENSE
 3040oswordBlk%?6 = 0
 3050oswordBlk%?7 = 0
 3060oswordBlk%?8 = 0
 3070oswordBlk%?9 = 8
 3080oswordBlk%?10 = 0
 3090oswordBlk%?11 = 0
 3100CALL &FFF1
 3110:
 3120REM Check if the SCSI command was successful
 3130IF oswordBlk%?0 <> 0 THEN PROCcommError
 3140:
 3150REM Check the firmware version
 3160IF dataBuf%?3 < 2 THEN PROCerrFw(dataBuf%?3, dataBuf%?4)
 3170IF dataBuf%?4 < 3 THEN PROCerrFw(dataBuf%?3, dataBuf%?4)
 3180ENDPROC
 3190:
 3200REM ** Function to display firmware revision error
 3210DEF PROCerrFw(major%, minor%)
 3220CLS
 3230PRINT "BeebSCSI reports firmware version "; major%; "."; minor%
 3240PRINT
 3250PRINT "This application is designed for"
 3260PRINT "version 2.3. If your firmware is"
 3270PRINT "<2.3 please upgrade your BeebSCSI"
 3280PRINT "firmware."
 3290PRINT
 3300PRINT "If your firmware is >2.3 please"
 3310PRINT "upgrade this application."
 3320END
 3330ENDPROC
