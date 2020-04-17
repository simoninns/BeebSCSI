# Introduction
This repository contains a 3D printable case design for BeebSCSI.

The case is designed using OpenSCAD and full source code is included.  There are also ready-made STL files for the various parts and materials if you don't want to build them yourself in OpenSCAD.

The case design contains multiple materials however you can easily remix the design using OpenSCAD customization GUI if you wish to print in a single material only.  Ready-made single material STL files are also included.

The case is designed for BeebSCSI boards fitted with a right-angle 1 MHz bus connector.  The power connector must be straight (rather than angled) and the power cable runs along-side the 1 MHz bus connector from the rear of the case.

<img src="/images/multi_material_withpcb.png" width="800">

# Printing instructions

## Overview

The model has been printed and tested on the Prusa MK3S/MMU2S printer. All parts fit on a 20x20 printing bed.

The OpenSCAD source files provide a parameter interface that allows you to render either the whole model or the individual parts (ready for STL (or other 3D format) export).  This requires OpenSCAD 2019.05 or later.

## Recommended print settings
* Material: PLA Blue and PLA White
* Layer: 0.20mm (Quality)
* Infill: 15%
* Supports: None
* Notes: The upper case slides into the lower case.  No screws are required for assembly.

# Author

The BeebSCSI case is designed and maintained by Simon Inns.

# Licensing

## OpenSCAD source files - software license (GPLv3)

    This is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

## 3D model files - Creative Commons license (Creative Commons BY-SA 4.0)

Please see the following link for details: https://creativecommons.org/licenses/by-sa/4.0/

You are free to:

Share - copy and redistribute the material in any medium or format
Adapt - remix, transform, and build upon the material
for any purpose, even commercially.

This license is acceptable for Free Cultural Works.

The licensor cannot revoke these freedoms as long as you follow the license terms.

Under the following terms:

Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.

ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.

No additional restrictions - You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.
