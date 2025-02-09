#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xil_printf.h"
#include "limits.h"
#include "sleep.h"
#include <stdlib.h>
#include "xil_io.h"
#include "xaxidma.h"
#include<math.h>
 
 
#include "model_MNIST_128_TA_actions_and_weights.h" 
#include "MNIST_test_charfile_128bytes_per_sample.h"
 
#include "xgpio.h"
 
u32 checkHalted(u32 baseAddress, u32 offset);
u32 checkIdle(u32 baseAddress, u32 offset);
 
#define imageSize 99
// 28*28=784 = 98 bytes
// The extra byte is for the label.
// So imageSize=99 bytes
 
long int TESTSAMPLES;
long int sample;
 
int ActualAndPredicted, Actual, Predicted;
long int errors;
float accuracyTest;
float accuracyTestAverage;
float accuracyTestArray[100]={ 0.0 };
 
int ActualClass;
 
int CoTMstatus;
int dummy1;
int ia;
 
int testloops_cont;
 
int MenuSelect;
int clause;
int sampleno;
 
int intrstatus;
 
int testruns;
int tr;
int result;
int actual;
int predicted;
int ab;
int test0;
int en_cg0;
int tics;
int dataindex;
int ibyteno;
 
long int imagebyteindex;
 
int verbose;
 
u32 statusZ;
 
u32 statusDMA;
u32 statusHalted;
u32 statusIdle;
 
/////////////////////////////////////////////////////////////////////////////////////////////////////////
 
XGpio o_rst;
XGpio o_rst_imbuf;
XGpio o_en_image;
XGpio o_start;
XGpio o_load;
XGpio o_single;
XGpio o_test;
XGpio o_en_cg;
 
XGpio o_LED0;
XGpio o_tready;
 
XGpio i_intrS;
XGpio i_intrL;
XGpio i_result;
 
/////////////////////////////////////////////////////////////////////////
XAxiDma_Config *myDmaConfig;
XAxiDma myDma;
//////////////////////////////////////////////////////////////////////////
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int main(){
 
                 init_platform();
 
    printf("\n");
    printf("//////////////////////////////////////////////////////////////////////////// \n");
    printf("// CONTROL MODULE for Convolutional Coalesced Tsetlin Machine (ConvCoTM)  //\n");
    printf("// image classification accelerator for 28x28 Boolean images.             //\n");
    printf("// -- Xilinx ZCE104 FPGA Development Board ------------------------------ // \n");
    printf("// ---------------- READY ----------------------------------------------- // \n");
    printf("//////////////////////////////////////////////////////////////////////////// \n");
    printf("\n");
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
    // Inputs:
    XGpio_Initialize(&i_intrS, XPAR_AXI_GPIO_8_DEVICE_ID);
    XGpio_Initialize(&i_intrL, XPAR_AXI_GPIO_9_DEVICE_ID);
    XGpio_Initialize(&i_result, XPAR_AXI_GPIO_1_DEVICE_ID);

    // Outputs:
    XGpio_Initialize(&o_rst, XPAR_AXI_GPIO_0_DEVICE_ID);
    XGpio_Initialize(&o_rst_imbuf, XPAR_AXI_GPIO_2_DEVICE_ID);
    XGpio_Initialize(&o_en_image, XPAR_AXI_GPIO_3_DEVICE_ID);
    XGpio_Initialize(&o_start, XPAR_AXI_GPIO_4_DEVICE_ID);
    XGpio_Initialize(&o_load, XPAR_AXI_GPIO_5_DEVICE_ID);
    XGpio_Initialize(&o_single, XPAR_AXI_GPIO_6_DEVICE_ID);
    XGpio_Initialize(&o_test, XPAR_AXI_GPIO_7_DEVICE_ID);
    XGpio_Initialize(&o_en_cg, XPAR_AXI_GPIO_12_DEVICE_ID);

    XGpio_Initialize(&o_LED0, XPAR_AXI_GPIO_10_DEVICE_ID);
    XGpio_Initialize(&o_tready, XPAR_AXI_GPIO_11_DEVICE_ID);
 
//////////////////////////////////////////////////////////////////////////////
    XGpio_SetDataDirection(&i_intrS,1,0xF);
    XGpio_SetDataDirection(&i_intrL,1,0xF);
    XGpio_SetDataDirection(&i_result,1,0xFF);

    XGpio_SetDataDirection(&o_rst,1,0x0);
    XGpio_SetDataDirection(&o_rst_imbuf,1,0x0);
    XGpio_SetDataDirection(&o_en_image,1,0x0);
    XGpio_SetDataDirection(&o_start,1,0x0);
    XGpio_SetDataDirection(&o_load,1,0x0);
    XGpio_SetDataDirection(&o_single,1,0x0);
    XGpio_SetDataDirection(&o_test,1,0x0);
    XGpio_SetDataDirection(&o_en_cg,1,0x0);

    XGpio_SetDataDirection(&o_LED0,1,0x0);
    XGpio_SetDataDirection(&o_tready,1,0x0);
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //DMA Controller Configuration

    myDmaConfig = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);

    statusDMA = XAxiDma_CfgInitialize(&myDma, myDmaConfig);
    if(statusDMA != XST_SUCCESS){
                    printf("DMA initialization failed\n");
    }
    else {
                    printf("DMA initialization succeeded\n");
    }
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
 
    while(1){

    // Perform reset (including reset of image buffers):

    XGpio_DiscreteWrite(&o_rst,1,1);
    XGpio_DiscreteWrite(&o_rst_imbuf,1,1);
    XGpio_DiscreteWrite(&o_en_image,1,0);
    XGpio_DiscreteWrite(&o_start,1,0);
    XGpio_DiscreteWrite(&o_load,1,0);
    XGpio_DiscreteWrite(&o_single,1,0);
    XGpio_DiscreteWrite(&o_test,1,0);
    XGpio_DiscreteWrite(&o_en_cg,1,0);
    XGpio_DiscreteWrite(&o_LED0,1,0);
    XGpio_DiscreteWrite(&o_tready,1,1); // Just need a fixed logical high for this signal.

    XGpio_DiscreteWrite(&o_rst,1,0);
    XGpio_DiscreteWrite(&o_rst_imbuf,1,0);

    // MAIN Menu://///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    errors=0;
    MenuSelect = 0;
    verbose=0;
    TESTSAMPLES=10000;
 
                                  while (MenuSelect !=1 && MenuSelect !=2 && MenuSelect !=3
                                                                   && MenuSelect !=4 && MenuSelect !=5
                                                                   && MenuSelect !=6 && MenuSelect !=7
                                                                   && MenuSelect !=8
                                                                   && MenuSelect !=9)
                                  {
                                                  printf(" \n");
                                                  printf("----------------\n");
                                                  printf("Main Menu:\n");
                                                  printf("----------------\n");
                                                  printf("1.  Load model \n");
                                                  printf("2.  TEST (10 k samples) in continuous mode\n");
                                                  printf("3.  TEST (single sample) \n");
                                                  printf("4.  TEST (long loop, for power measurement) \n");
                                                  printf("5.  Reset image buffer \n");
                                                  printf("6.  Reset FPGA accelerator \n");
                                                  printf("7.  TEST (10 k samples) with singlemode operation\n");
                                                  printf("8.  Set verbose \n");
                                                  printf("9.  Enable or disable clock gating \n");
                                                  printf(" \n");
                                                  printf("Enter main menu selection: \n");
                                                  scanf("%d", &MenuSelect);
 
                                                  if (MenuSelect==1) {
                                                                   LoadConvCoTMmodel();
                                                  }
 
                                                  else if (MenuSelect==2) {
                                                                   XGpio_DiscreteWrite(&o_single,1,0);
                                                                   TestConvCoTM10k();
                                                                   printf("------------------------------------------------\n");
                                                                   printf("Test samples: %ld\n", TESTSAMPLES);
                                                                   printf("TEST errors : %ld\n", errors);
                                                                   printf("TEST accuracy : %.2f\n", accuracyTest);
                                                                   printf("------------------------------------------------\n");
                                                  }
 
                                                  else if (MenuSelect==3) {
                                                                   TestConvCoTMsingleSample();
                                                  }
 
                                                  else if (MenuSelect==4) {
                                                                   // Perform many tests in a loop, for power measurement during this mode:
                                                                   XGpio_DiscreteWrite(&o_single,1,0);
                                                                   printf("Number of test loops ?\n");
                                                                   scanf("%d", &testloops_cont);
 
                                                                   for(int i=0; i<testloops_cont; i++)
                                                                                    {
                                                                                    TestConvCoTM10k();
                                                                                    }
                                                                   printf("Finished with test loops! \n");
                                                  }
 
                                                  else if (MenuSelect==5) {
 
                                                                   XGpio_DiscreteWrite(&o_rst_imbuf,1,1);
                                                                   XGpio_DiscreteWrite(&o_rst_imbuf,1,0);
                                                      printf("Image buffer reset performed! \n");
                                                  }
 
                                                  else if (MenuSelect==6) {
                                                                   XGpio_DiscreteWrite(&o_rst,1,1);
                                                                   XGpio_DiscreteWrite(&o_rst,1,0);
                                                      printf("FPGA accelerator reset performed! \n");
                                                  }
 
                                                  else if (MenuSelect==7) {
                                                                   XGpio_DiscreteWrite(&o_single,1,1);
                                                                   TestConvCoTM10ksinglemode();
                                                                   XGpio_DiscreteWrite(&o_single,1,0);
                                                  }
 
                                                  else if (MenuSelect==8) {
                                                                   printf("Verbose (0 or 1) ?\n");
                                                                   scanf("%d", &verbose);
                                                      printf("verbose = %d\n", verbose);
                                                  }
 
                                                  else if (MenuSelect==9) {
                                                                   printf("Set en_cg bit (0=0, otherwise=1) ?\n");
                                                                   scanf("%d", &en_cg0);
                                                                   if (en_cg0==0){
                                                                                    en_cg0=0;
                                                                   }
                                                                   else {
                                                                                    en_cg0=1;
                                                                   }
                                                                   XGpio_DiscreteWrite(&o_en_cg,1, en_cg0);
                                                      printf("en_cg bit = %d\n", en_cg0);
                                                  }
 
                                                  else{
                                                                   MenuSelect = 0; // Do nothing - bring up main menu again.
                                                  }
 
                                  MenuSelect = 0; // reset menu choice
                                  }               // belongs to while(MenuSelect)
    }           // belongs to while(1)
    cleanup_platform();
    return 0;
} // End of main
 
 
//////////////////////////////////////////////////////////////////////////
void TestConvCoTM10k(void)
{
                 //printf("Start testing!! \n");
 
                 // Reset image buffer:
                 XGpio_DiscreteWrite(&o_rst_imbuf,1,1);
                 //wait_a_bit();
                 XGpio_DiscreteWrite(&o_rst_imbuf,1,0);
                 //wait_a_bit();
 
                 errors=0;
 
                 //Transfer the first image:
                 XGpio_DiscreteWrite(&o_en_image,1,1);
                 //XGpio_DiscreteWrite(&o_en_image,1,1); // wait command (write same)
                 wait_a_bit();
 
                 // Send first image test sample to the Accelerator:
    statusDMA = XAxiDma_SimpleTransfer(&myDma, (u32)&MNISTtestData[0], 99, XAXIDMA_DMA_TO_DEVICE);
                 if(statusDMA != XST_SUCCESS){
                                  printf("DMA transfer failed first sample test\n");
                 }
 
                 statusIdle = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
                                  while(statusIdle == 0){
                                                  statusIdle = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
                                  }
 
                 XGpio_DiscreteWrite(&o_en_image,1,0);
                 //wait_a_bit();
 
                 for(sample=1; sample<TESTSAMPLES-1; sample++) {  //FOR TESTSAMPLES
 
                     XGpio_DiscreteWrite(&o_start,1,1);
                     //wait_a_bit();
 
                                  XGpio_DiscreteWrite(&o_en_image,1,1);
                                  //XGpio_DiscreteWrite(&o_en_image,1,1); // wait command (write same)
                                  wait_a_bit();
 
                     statusDMA = XAxiDma_SimpleTransfer(&myDma, (u32)&MNISTtestData[sample*128], 99, XAXIDMA_DMA_TO_DEVICE);
                                  if(statusDMA != XST_SUCCESS){
                                                  printf("DMA transfer failed, test sample in for loop\n");
                                  }
 
                                  statusIdle = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
                                                  while(statusIdle == 0){
                                                                   statusIdle = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
                                                  }
 
                                  XGpio_DiscreteWrite(&o_en_image,1,0);
                                  //wait_a_bit();
 
                                  intrstatus = XGpio_DiscreteRead(&i_intrS,1);
                                  while(intrstatus != 1){
                                                  intrstatus = XGpio_DiscreteRead(&i_intrS,1);
                                                  //wait_a_bit();
                                  }
 
                                  result = XGpio_DiscreteRead(&i_result,1);
                                  actual    = result >> 4;
                                  predicted = result & 0x0F;
 
//                              if (verbose==1){
//                                               printf("\n");
//                                               printf("Test sample no.                          : %d\n", sample);
//                                               printf("Sample label                             : %d\n", actual);
//                                               printf("Predicted result                         : %d\n", predicted);
//                                               printf("\n");
//                              }
 
                                  if (actual != predicted) {
                                                                   errors = errors+1;
                                  }
                                  XGpio_DiscreteWrite(&o_start,1,0);
                                  //wait_a_bit();
 
                 } // FOR TESTSAMPLES
 
                 ////////////////////////////////////////////
                 // Processing the last test sample:
                 XGpio_DiscreteWrite(&o_start,1,1);
 
                 intrstatus = XGpio_DiscreteRead(&i_intrS,1);
                 while(intrstatus != 1){
                                  intrstatus = XGpio_DiscreteRead(&i_intrS,1);
                 }
 
                 result = XGpio_DiscreteRead(&i_result,1);
                 actual    = result >> 4;
    predicted = result & 0x0F;
 
                 XGpio_DiscreteWrite(&o_start,1,0); // Go to initialstate
 
//    if (verbose==1){
//             printf("\n");
//             printf("Test sample no.                          : %d\n", sample);
//             printf("Sample label                             : %d\n", actual);
//             printf("Predicted result                         : %d\n", predicted);
//             printf("\n");
//    }
 
                 if (actual != predicted) {
                                                  errors = errors+1;
                 }
 
                 accuracyTest=(float)(TESTSAMPLES-errors)*100.00/(float)TESTSAMPLES;
 
//             if (MenuSelect!=4) {
//                              printf("------------------------------------------------\n");
//                              printf("Test samples: %ld\n", TESTSAMPLES);
//                              printf("TEST errors : %ld\n", errors);
//                              printf("TEST accuracy : %.2f\n", accuracyTest);
//                              printf("------------------------------------------------\n");
//             }
}
 
//////////////////////////////////////////////////////////////////////////
void TestConvCoTM10ksinglemode(void)
{
                 //printf("Start testing! \n");
 
                 // Reset image buffer:
                 XGpio_DiscreteWrite(&o_rst_imbuf,1,1);
    XGpio_DiscreteWrite(&o_rst_imbuf,1,0);
 
                 errors=0;
 
                 for(sample=0; sample<TESTSAMPLES-1; sample++) {
 
                                  XGpio_DiscreteWrite(&o_en_image,1,1);
                                  wait_a_bit();
 
                                  statusDMA = XAxiDma_SimpleTransfer(&myDma, (u32)&MNISTtestData[sample*128], 99, XAXIDMA_DMA_TO_DEVICE);
                                  if(statusDMA != XST_SUCCESS){
                                                  printf("DMA transfer failed, test sample in for loop\n");
                                  }
 
                                  statusIdle = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
                                                  while(statusIdle == 0){
                                                                   statusIdle = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
                                                  }
 
                                  XGpio_DiscreteWrite(&o_en_image,1,0);
                                  wait_a_bit();
 
                                  XGpio_DiscreteWrite(&o_start,1,1);
                                  wait_a_bit();
 
                                  intrstatus = XGpio_DiscreteRead(&i_intrS,1);
                                  while(intrstatus != 1){
                                                  intrstatus = XGpio_DiscreteRead(&i_intrS,1);
                                                  wait_a_bit();
                                  }
 
                                  result = XGpio_DiscreteRead(&i_result,1);
                                  actual    = result >> 4;
                                  predicted = result & 0x0F;
 
                                  if (verbose==1 && TESTSAMPLES<500){
                                                  printf("\n");
                                                  printf("Test sample no.                          : %d\n", sample);
                                                  printf("Sample label                             : %d\n", actual);
                                                  printf("Predicted result                         : %d\n", predicted);
                                                  printf("\n");
                                  }
 
                                  if (actual != predicted) {
                                                                   errors = errors+1;
                                  }
 
                                  XGpio_DiscreteWrite(&o_start,1,0); // Go to initialstate
 
                 } // TESTSAMPLES
 
                 accuracyTest=(float)(TESTSAMPLES-errors)*100.00/(float)TESTSAMPLES;
 
                 if (MenuSelect!=4) {
                                  printf("------------------------------------------------\n");
                                  printf("Test samples: %ld\n", TESTSAMPLES);
                                  printf("TEST errors : %ld\n", errors);
                                  printf("TEST accuracy : %.2f\n", accuracyTest);
                                  printf("------------------------------------------------\n");
                 }
 
}
 
//////////////////////////////////////////////////////////////////////////
 
void TestConvCoTMsingleSample(void)
{
                 XGpio_DiscreteWrite(&o_single,1,1);
 
                 printf(" \n");
                 printf("TEST SINGLE SAMPLE \n");
                 printf("Enter sample number ( 0-9999): \n");
                 scanf("%d", &sampleno);
 
                 // Reset image buffer:
                 XGpio_DiscreteWrite(&o_rst_imbuf,1,1);
 
    XGpio_DiscreteWrite(&o_rst_imbuf,1,0);
 
                 XGpio_DiscreteWrite(&o_en_image,1,1);
 
    statusDMA = XAxiDma_SimpleTransfer(&myDma, (u32)&MNISTtestData[sampleno*128], 99, XAXIDMA_DMA_TO_DEVICE);
                 if(statusDMA != XST_SUCCESS){
                                  printf("DMA transfer failed, test sample in for loop\n");
                 }
 
                 statusIdle = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
                                  while(statusIdle == 0){
                                                  statusIdle = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
                                  }
 
                 XGpio_DiscreteWrite(&o_en_image,1,0);
 
    XGpio_DiscreteWrite(&o_start,1,1); // Set i_start=1 (and single mode operation)
 
                 intrstatus = XGpio_DiscreteRead(&i_intrS,1);
                 while(intrstatus != 1){
                                  intrstatus = XGpio_DiscreteRead(&i_intrS,1);
                 }
 
                 result = XGpio_DiscreteRead(&i_result,1);
 
                 actual    = result >> 4;
                 actual    = actual & 0x0F;
 
    predicted = result & 0x0F;
 
                 printf("\n");
                 printf("Test sample no.                          : %d\n", sampleno);
                 printf("Sample label                             : %d\n", actual);
                 printf("Predicted result                         : %d\n", predicted);
                 printf("\n");
 
                 XGpio_DiscreteWrite(&o_start,1,0); // Go to initialstate
 
}
 
////////////////////////////////////////////////////////////////////////////////////
void LoadConvCoTMmodel(void)
{
                 printf("Start loading model! \n");
 
                 XGpio_DiscreteWrite(&o_load,1,1);
 
                 statusDMA = XAxiDma_SimpleTransfer(&myDma, (u32)&ConvCoTMmodel, 5632, XAXIDMA_DMA_TO_DEVICE);
                 if(statusDMA != XST_SUCCESS){
                                  printf("DMA transfer failed, test sample in for loop\n");
                 }
 
                 statusIdle = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
                                  while(statusIdle == 0){
                                                  statusIdle = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
                                  }
 
                 intrstatus = XGpio_DiscreteRead(&i_intrL,1);
                 while(intrstatus != 1){
                                  intrstatus = XGpio_DiscreteRead(&i_intrL,1);
                 }
 
                 printf("ConvCoTM model loaded! : \n");
                 printf("* 272 TA action signals per clause (the configuration has 128 clauses).\n");
                 printf("* 10 sets of clause weights (one for each of the 10 classes).\n");
                 printf("* Each weight is 8 bits (two's complement format).\n");
                 printf("\n");
 
                 XGpio_DiscreteWrite(&o_load,1,0);
}
 
////////////////////////////////////////////////////////////////////////////////////////////
 
u32 checkHalted(u32 baseAddress,u32 offset){
                 u32 status1;
                 status1 = (XAxiDma_ReadReg(baseAddress,offset))&XAXIDMA_HALTED_MASK;
                 return status1;
}
 
////////////////////////////////////////////////////////////////////////////////////////////
 
u32 checkIdle(u32 baseAddress,u32 offset){
                 u32 status2;
                 status2 = (XAxiDma_ReadReg(baseAddress,offset))&XAXIDMA_IDLE_MASK;
                 return status2;
}
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
void wait_a_bit(void)
                 {
                 for(int k=0; k<1000; k++){
                 }
                 }
////////////////////////////////////////////////////////////////////////////////////////////