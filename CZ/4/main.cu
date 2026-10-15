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
        inputVector[index] += value;
    }
}


int main(){
    int vectorSize = 100000;
    
    //int *vector = (int*)malloc(sizeof(int) * vectorSize);
    
    //int *vector_d = NULL;
    //CUDA_CHECK_RETURN(cudaMalloc(&vector_d, sizeof(int) * vectorSize));

    int *vector = NULL;
    CUDA_CHECK_RETURN(cudaMallocManaged(&vector, sizeof(int) * vectorSize));

    for (int i = 0; i < vectorSize; i++) {
        vector[i] = i;
    }

    //CUDA_CHECK_RETURN(cudaMemcpy(vector_d, vector, vectorSize * sizeof(int), cudaMemcpyHostToDevice));

    int blockSize = 128;
    int gridSize = (vectorSize + blockSize - 1) / blockSize;

    addToVector<<<gridSize, blockSize>>>(vector, vectorSize, 1000);
    cudaDeviceSynchronize();

    //CUDA_CHECK_RETURN(cudaMemcpy(vector, vector_d, vectorSize * sizeof(int), cudaMemcpyDeviceToHost));    

    for (int i = 0; i < vectorSize; i++) {
        std::cout << vector[i] << ", ";
    }
}
