#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <chrono>
#include <fstream>

#include "cuda_runtime.h"


#define CUDA_CHECK_RETURN( value ) {    \
    cudaError_t err = value;            \
    if (err != cudaSuccess ){           \
        fprintf( stderr, "Error %s at line %d in file %s\n",  \
            cudaGetErrorString(err), __LINE__, __FILE__);    \
            exit(-1);                                          \
    }}

__global__ void getIndex(int* outputData) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    outputData[index] = index;
}

__global__ void addToVector(int* inputData, int* outputData, int constant) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    outputData[index] = inputData[index] + constant;
}

int main(){
    /*printf("Hello world!\n");

    int deviceCount = 0;
    CUDA_CHECK_RETURN(cudaGetDeviceCount(&deviceCount))

    std::cout << deviceCount << std::endl;

    cudaDeviceProp deviceProperties;
    CUDA_CHECK_RETURN(cudaGetDeviceProperties(&deviceProperties, 0))

    std::cout << deviceProperties.name << std::endl;
    std::cout << deviceProperties.major << std::endl;

    std::cout << "Max block size " << deviceProperties.maxThreadsDim[0] << " X," << std::endl
                                   << deviceProperties.maxThreadsDim[1] << " Y," << std::endl
                                   << deviceProperties.maxThreadsDim[2] << " Z" << std::endl;

    std::cout << "Max grid size " << deviceProperties.maxGridSize[0] << " X," << std::endl
                                   << deviceProperties.maxGridSize[1] << " Y," << std::endl
                                   << deviceProperties.maxGridSize[2] << " Z" << std::endl;*/

    std::ofstream outputStream("results.csv");
    outputStream << "Block size;Time ms\n";
    
    int threadCount = 10000;
    int* inputData_h = (int*) malloc(threadCount * sizeof(int));
    int* outputData_h = (int*) malloc(threadCount * sizeof(int));

    int* inputData_d = NULL;
    int* outputData_d = NULL;

    CUDA_CHECK_RETURN(cudaMalloc(&inputData_d, threadCount * sizeof(int)))
    CUDA_CHECK_RETURN(cudaMalloc(&outputData_d, threadCount * sizeof(int)))

    for (int blockSize = 1; blockSize <= 1024; blockSize++) {
        int gridSize = (threadCount + blockSize - 1) / blockSize;

        int runCount = 100;
        auto startTime = std::chrono::high_resolution_clock::now();

        for (int i = 0; i < runCount; i++) {
            getIndex<<<gridSize, blockSize>>>(inputData_d);
            cudaDeviceSynchronize();
            addToVector<<<gridSize, blockSize>>>(inputData_d, outputData_d, 100);
            cudaDeviceSynchronize();
        }

        auto endTime = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::microseconds>(endTime - startTime) / runCount;
        auto durationMs = duration.count() / 1000.0;

        std::cout << "Execution time: " << durationMs << " ms" << std::endl;
        outputStream << blockSize << ";" << (int)(durationMs) << "," << (int)((durationMs - (int)(durationMs)) * 1000) << "\n";
    }

    outputStream.close();


    //cudaDeviceSynchronize();

    /*CUDA_CHECK_RETURN(cudaMemcpy(inputData_h, inputData_d, threadCount * sizeof(int), cudaMemcpyDeviceToHost))

    for (int i = 0; i < threadCount; i++) {
        std::cout << inputData_h[i] << ", ";
    }
    std::cout << std::endl << std::endl;

    addToVector<<<gridSize, blockSize>>>(inputData_d, outputData_d, 10);
    //cudaDeviceSynchronize();

    CUDA_CHECK_RETURN(cudaMemcpy(outputData_h, outputData_d, threadCount * sizeof(int), cudaMemcpyDeviceToHost))

    for (int i = 0; i < threadCount; i++) {
        std::cout << outputData_h[i] << ", ";
    }*/

}