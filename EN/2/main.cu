#include <stdio.h>
#include <stdlib.h>
#include <iostream>

#include "cuda_runtime.h"


#define CUDA_CHECK_RETURN( value ) {    \
    cudaError_t err = value;            \
    if (err != cudaSuccess ){           \
        fprintf( stderr, "Error %s at line %d in file %s\n",  \
            cudaGetErrorString(err), __LINE__, __FILE__);    \
            exit(-1);                                          \
    }}

__global__ void getIndex(int *outputData) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;

    outputData[index] = index;
}

__global__ void addToVector(int *inputData, int *outputData, int constant) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;

    outputData[index] = inputData[index] + constant;    
}


int main(){
    /*printf("Hello world!\n");

    int deviceCount = 0;

    cudaGetDeviceCount(&deviceCount);

    std::cout << "Device count: " << deviceCount << std::endl;

    cudaDeviceProp deviceProperties;
    CUDA_CHECK_RETURN(cudaGetDeviceProperties(&deviceProperties, 0))

    std::cout << "Device name: " << deviceProperties.name << std::endl;
    std::cout << "Compute compatibility: " << deviceProperties.major << std::endl;

    std::cout << "Max block size: " << deviceProperties.maxThreadsDim[0] << " X" << std::endl
                                    << deviceProperties.maxThreadsDim[1] << " Y" << std::endl
                                    << deviceProperties.maxThreadsDim[2] << " Z" << std::endl;

    std::cout << "Max grid size: "  << deviceProperties.maxGridSize[0] << " X" << std::endl
                                    << deviceProperties.maxGridSize[1] << " Y" << std::endl
                                    << deviceProperties.maxGridSize[2] << " Z" << std::endl;*/


    int threadCount = 200;

    int *inputData_h = (int*) malloc(threadCount * sizeof(int));
    
    int *inputData_d = NULL;
    CUDA_CHECK_RETURN(cudaMalloc(&inputData_d, threadCount * sizeof(int)))

    int blockSize = 128;
    int gridSize = (threadCount + blockSize - 1) / blockSize;

    getIndex<<<blockSize, gridSize>>>(inputData_d);
    cudaDeviceSynchronize();

    cudaMemcpy(inputData_h, inputData_d, threadCount * sizeof(int), cudaMemcpyDeviceToHost);

    for(int i = 0; i < threadCount; i++){
        std::cout << inputData_h[i] << ", ";
    }
    std::cout << std::endl << std::endl;

    int *outputData_h = (int*) malloc(threadCount * sizeof(int));
    
    int *outputData_d = NULL;
    CUDA_CHECK_RETURN(cudaMalloc(&outputData_d, threadCount * sizeof(int)))

    addToVector<<<blockSize, gridSize>>>(inputData_d, outputData_d, 100);
    cudaDeviceSynchronize();

    cudaMemcpy(outputData_h, outputData_d, threadCount * sizeof(int), cudaMemcpyDeviceToHost);

    for(int i = 0; i < threadCount; i++){
        std::cout << outputData_h[i] << ", ";
    }
    std::cout << std::endl << std::endl;

    CUDA_CHECK_RETURN(cudaFree(inputData_d));
    CUDA_CHECK_RETURN(cudaFree(outputData_d));

    free(inputData_h);
    free(outputData_h);
}
