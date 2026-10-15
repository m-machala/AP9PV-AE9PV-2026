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

__global__ void addToVector(int *inputVector, int vectorSize, int value) {
    int index = blockDim.x * blockIdx.x + threadIdx.x;
    
    if (index < vectorSize) {
        inputVector[index] = inputVector[index] + value;
    }   
}

int main(){
    int vectorSize = 1000;

    //int *inputVector = (int*)malloc(vectorSize * sizeof(int));
    
    //int *inputVector_d = NULL;
    //CUDA_CHECK_RETURN(cudaMalloc(&inputVector_d, vectorSize * sizeof(int)));

    int *inputVector = NULL;
    CUDA_CHECK_RETURN(cudaMallocManaged(&inputVector, vectorSize * sizeof(int)));
    
    
    for (int i = 0; i < vectorSize; i++) {
        inputVector[i] = i;
    }

    //CUDA_CHECK_RETURN(cudaMemcpy(inputVector_d, inputVector, vectorSize * sizeof(int), cudaMemcpyHostToDevice));
    int blockSize = 128;
    int gridSize = (vectorSize + blockSize - 1) / blockSize;

    //addToVector<<<gridSize, blockSize>>>(inputVector_d, vectorSize, 10000);
    addToVector<<<gridSize, blockSize>>>(inputVector, vectorSize, 10000);
    cudaDeviceSynchronize();

    //CUDA_CHECK_RETURN(cudaMemcpy(inputVector, inputVector_d, vectorSize * sizeof(int), cudaMemcpyDeviceToHost));

    for (int i = 0; i < vectorSize; i++) {
        std::cout << inputVector[i] << " ";
    }
    
}
