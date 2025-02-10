# ConvCoTM_Inference_Accelerator

------------------------------------------------------------------------------------------------

## Convolutional Coalesced Tsetlin Machine (ConvCoTM) Inference Image Classification Accelerator

------------------------------------------------------------------------------------------------

This repository includes VHDL source code for an FPGA implementation of a Convolutional Coalesced Tsetlin Machine (ConvCoTM)-based image classification accelerator. The ConvCoTM configuration is as follows: 

Image size: 28 x 28 pixels (booleanized)

Number of clauses: 128

Number of classes:  10 

Convolution window: 10 x 10

Convolution window step size in X-direction: 1

Convolution window step size in Y-direction: 1

Clause integer weights per class: 8 bits (two's-complement representation)

------------------------------------------------------------------------------------------------

The solution is for inference operation, and the model for the given ConvCoTM configuration is fully programmable. The VHDL design is the exact basis for the implementation of the application-specific integrated circuit (ASIC) reported in the paper <i>"An All-digital 65-nm Tsetlin Machine Image Classification Accelerator with 8.6 nJ per MNIST Frame at 60.3k Frames per Second"</i>. (The only exception is that the clause switching reduction feedback is not included.) A preprint of the paper can be found at: https://arxiv.org/abs/2501.19347.

The coding style applied for the VHDL designs is based on Appendix A in <i>"Digital Design Using VHDL: A Systems Approach"</i>, Dally William J. Harting R. Curtis Aamodt Tor M., Cambrige University Press, 2016. In particular, the principle that <i>"All state should be in explicitly declared registers"</i> has been carefully followed.

The design has been implemented and verified on an AMD/Xilinx ZCU104 FPGA development board. The Design tools used are AMD/Xilinx Vivado 2022.2 and Vitis 2022.2. Use of the FPGA's DMA functionality and AXI stream interfacing was highly inspired by Youtube videos provided by Vipin Kizheppatt: https://www.youtube.com/@Vipinkmenon/videos.

FPGA block diagram, FPGA IP module configuration settings and C-program for operating the accelerator are included in the repository. 

In https://doi.org/10.48550/arXiv.2108.07594 the Coalesced Tsetlin Machine (CoTM) is presented.

The MNIST data samples included in this repository, are booleanized by simple thresholding. I.e., pixel values above 75 are set to 1 and to 0 otherwise. The original MNIST dataset is found at https://yann.lecun.com/exdb/mnist/. Each booleanized MNIST image requires 98 bytes plus one byte for the label. In addition, 29 bytes of value 0 have been added to each sample, totalling 128 bytes per image, which is necessary for the reading of image data via the DMA for this FPGA solution.