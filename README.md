# TsetlinMachine_accelerator_image_classification
This repository includes VHDL source code for an FPGA implementation of a Convolutional Coalesced Tsetlin Machine-based Image Classification Accelerator. The solution is for inference-only and the model is fully programmable, for the given Tsetlin Machine configuration.

The design represents the exact functionality of the ASIC reported in the paper  <i>"An All-digital 65-nm Tsetlin Machine Image Classification Accelerator with 8.6 nJ per MNIST Frame at 60.3k Frames per Second" </i>.

A preprint of the paper can be found at: https://arxiv.org/abs/2501.19347

The accelerator is implemented on a Xilinx/AMD ZCU104 development board. The design has been implemented and verified on an AMD/Xilinx ZCU104 FPGA development board, The Design tools used are AMD Vivado 2022.2 and Vitis 2022.2. The FPGA block diagram, some FPGA IP module configuration specifications and a C-program for operating the accelerator are also included.

