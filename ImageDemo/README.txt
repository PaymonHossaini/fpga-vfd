****************************************************************
                        GU-7000 IMAGE DEMO
****************************************************************
YOU MUST AGREE THIS TERMS AND CONDITIONS. THIS SOFTWARE IS
PROVIDED BY NORITAKE CO., INC "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR SORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

----------------------------------------------------------------
ABOUT THIS DEMO
This project demonstrates how to use the Noritake_VFD_GU7000
code library to display bitmap images on the Noritake GU-7000
Vacuum Fluorescent Display (VFD) modules. You MUST download and
install the Noritake_VFD_GU7000 code library before running the
demo.

    http://www.noritake-elec.com

Please refer to the instructions on the download page and
"README" included with the Noritake_VFD_GU7000 code library for
information on how to install the Noritake_VFD_GU7000 code
library and demos.  This document assumes that you have already
configured the "config.h" file in the Noritake_VFD_GU7000 code
library as described in those documents.

For more information on the methods used in this document,
please refer to the method documentation in the
Noritake_VFD_GU7000 code library.

----------------------------------------------------------------
BEHAVIOR
This project displays an antenna icon on the screen. Since the
Atmel AVRs do not have very much memory, this image will be
stored in the FlashROM of the module so a GU-7900 module is
required to run this demo.

----------------------------------------------------------------
KEY POINTS
1) The image must be loaded into the FlashROM of the module
   before the demo is run. Follow the on-screen instructions on
   the Noritake GU-7000 Image Loader program to load the images
   into the FlashROM.
2) Reset and initialize the module with GU7000_reset() and
   GU7000_init().
3) Use GU7000_drawFROMImage() to draw an image from the module's
   FlashROM onto the screen. If you used the Noritake GU-7000
   Image Loader program to load the image, this code will be
   written for you. The parameter 1 is the FlashROM address of
   the image. The parameter 2 is how tall the image was when
   it was written to the FlashROM. Parameters 3 and 4 are how
   much of the image will be displayed.   

----------------------------------------------------------------
LISTING
#include "../src/config.h"
#include "../src/Noritake_VFD_GU7000.h"
Noritake_VFD_GU7000 vfd;
int main() {
    vfd.GU7000_reset();
    vfd.GU7000_init();
    vfd.GU7000_drawFROMImage(0x0, 16, 16, 16); // Display the image antenna 16X16
}

----------------------------------------------------------------
E-M-0087-00 12/06/2011
----------------------------------------------------------------
SUPPORT

For further support, please contact:
    Noritake Co., Inc.
    2635 Clearbrook Dr 
    Arlington Heights, IL 60005 
    800-779-5846 
    847-439-9020
    support.ele@noritake.com

All rights reserved. © Noritake Co., Inc.