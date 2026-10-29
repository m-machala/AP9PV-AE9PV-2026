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

// Graphics courtesy of Ing. Petr Špaňhel
//
//           O
//      | 0  0  0 |
//      | 0  0  0 |
//    M | 0  0  0 |
//      | 0  0  0 |
//      | 0  0  0 |
//
//            N
//      | 0  0  0  0 |
//   O  | 0  0  0  0 |
//      | 0  0  0  0 |

__global__ void multiplyMatrices(float *matrixA, float *matrixB, float *outputMatrix, int m, int n, int o) {
    int columnIndex = blockIdx.x * blockDim.x + threadIdx.x;
    int rowIndex = blockIdx.y * blockDim.y + threadIdx.y;

    if (rowIndex < m && columnIndex < n) {
        float output = 0.0f;

        for (int i = 0; i < o; i++) {
            output += matrixA[rowIndex * o + i] * matrixB[i * n + columnIndex];
        }

        outputMatrix[rowIndex * n + columnIndex] = output;
    }
}

int main(){
    int M = 10;
    int N = 4;
    int O = 3;

    float *matrixA, *matrixB, *outputMatrix;
    
    CUDA_CHECK_RETURN(cudaMallocManaged(&matrixA, M * O * sizeof(float)));
    CUDA_CHECK_RETURN(cudaMallocManaged(&matrixB, O * N * sizeof(float)));
    CUDA_CHECK_RETURN(cudaMallocManaged(&outputMatrix, M * N * sizeof(float)));

    for (int i = 0; i < M * O; i++) {
        matrixA[i] = i;
    }

    for (int i = 0; i < O * N; i++) {
        matrixB[i] = i;
    }
    
    int blockSizeSingle = 16;
    
    dim3 blockSize(blockSizeSingle, blockSizeSingle);
    dim3 gridSize((N + blockSizeSingle - 1) / blockSizeSingle, (M + blockSizeSingle - 1) / blockSizeSingle);
    
    multiplyMatrices<<<gridSize, blockSize>>>(matrixA, matrixB, outputMatrix, M, N, O);
    cudaDeviceSynchronize();

    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            std::cout << outputMatrix[i * N + j] << " ";
        }
        std::cout << std::endl;
    }
}
