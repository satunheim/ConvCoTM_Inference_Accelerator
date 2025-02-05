# TsetlinMachine_accelerator_image_classification
This repository includes VHDL source code for an FPGA implementation of a Convolutional Coalesced Tsetlin Machine (ConvCoTM) based image classification accelerator. The solution is for inference-only, and the model for the given ConvCoTM configuration is fully programmable.

The design represents the exact functionality of the ASIC reported in the paper  <i>"An All-digital 65-nm Tsetlin Machine Image Classification Accelerator with 8.6 nJ per MNIST Frame at 60.3k Frames per Second" </i>.

A preprint of the paper can be found at: https://arxiv.org/abs/2501.19347.

The design has been implemented and verified on an AMD/Xilinx ZCU104 FPGA development board. The Design tools used are AMD Vivado 2022.2 and Vitis 2022.2. The FPGA block diagram, some FPGA IP module configuration specifications and a C-program for operating the accelerator are also included.

In https://doi.org/10.48550/arXiv.2108.07594 the Coalesced Tsetlin Machine (CoTM) is presented.

The MNIST data samples included in this repository, are booleanized by simple thresholding. I.e., pixel values above 75 are set to 1 and to 0 otherwise. The original MNIST dataset is found at https://yann.lecun.com/exdb/mnist/.

The coding style applied for the VHDL designs is based on Appendix A in <i>Digital Design Using VHDL: A Systems Approach</i>, Dally William J. Harting R. Curtis Aamodt Tor M., Cambrige University Press, 2016. In particular, the principle that <i>"All state should be in explicitly declared registers"</i> has been carefully followed.