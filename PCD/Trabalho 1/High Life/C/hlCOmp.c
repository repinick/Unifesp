#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <omp.h>

#define SIZE 2048
#define GEN 2000
#define THREADS 2

//Retorna o numero de vizinhos vivos de cada celula na posicao i,j
int getNeighbors(int** grid, int i, int j) {

    int total_n = 0;

    int ii = i - 1;
    int ij = j - 1;
    int ji = i + 1;
    int jj = j + 1;

    if(ii % SIZE < 0){
        ii = SIZE - 1;
    }
    if(ij % SIZE < 0){
        ij = SIZE - 1;
    }
    if(jj == SIZE){
        jj = jj%SIZE;
    }
    if(ji == SIZE){
        ji = ji%SIZE;
    }

    total_n = grid[ii][ij] + grid[ii][j] + grid[ii][jj] +
              grid [i][ij]       +         grid [i][jj] +
              grid[ji][ij] + grid[ji][j] + grid[ji][jj];

    return total_n;
}

int totalCells(int **grid){
    int total = 0, i, j;
    #pragma omp parallel shared (grid) private(i,j) reduction(+:total) num_threads(THREADS)
    {
        #pragma omp for
        for(i=0; i<SIZE; i++){
            for(j=0; j<SIZE; j++){
                if(grid[i][j] == 1) total++;
            }
        }
    }
    return total;
}

int checkCells(int **grid, int **newGrid){
    int i, j, total_n;

    #pragma omp parallel shared (grid, newGrid) private(i,j) num_threads(THREADS)
    {
        #pragma omp for
        for(i=0; i<SIZE; i++){
            for(j=0; j<SIZE; j++){

                total_n = getNeighbors(grid, i, j);

                if(grid[i][j] == 1){

                    if(total_n < 2){   //Celula morre por abandono
                        newGrid[i][j] = 0;

                    }else if(total_n == 2 || total_n == 3){     //Celula continua viva
                        newGrid[i][j] = 1;

                    }else if(total_n >= 4){     //Celula morre por superpopulacao
                        newGrid[i][j] = 0;

                    }
                    
                }else if(total_n == 3 || total_n == 6){
                    newGrid[i][j] = 1;

                }else{
                    newGrid[i][j] = 0;
                }
            }
        }
    }

    for(i=0; i<SIZE; i++){
        for(j=0; j<SIZE; j++){
            grid[i][j] = newGrid[i][j];
        }
    }
}

int main(){

    struct timeval start, stop;
    gettimeofday(&start,0);

    int lin = 1, col = 1, i, j;
    int **grid, **newGrid;

    //Definindo as matrizes
    grid = (int**)malloc(sizeof(int*) * SIZE);
    newGrid = (int**)malloc(sizeof(int*) * SIZE);

    for(int i=0; i<SIZE; i++){
        grid[i] = (int*)malloc(sizeof(int) * SIZE);
        newGrid[i] = (int*)malloc(sizeof(int) * SIZE);
    }

    for(i=0; i<SIZE; i++){
        for(j=0; j<SIZE; j++){
            grid[i][j] = 0;
        }
    }

    //Inicializacao
    //GLIDER
    grid[lin  ][col+1] = 1;
    grid[lin+1][col+2] = 1;
    grid[lin+2][col  ] = 1;
    grid[lin+2][col+1] = 1;
    grid[lin+2][col+2] = 1;

    //R-pentomino
    lin =10; col = 30;
    grid[lin  ][col+1] = 1;
    grid[lin  ][col+2] = 1;
    grid[lin+1][col  ] = 1;
    grid[lin+1][col+1] = 1;
    grid[lin+2][col+1] = 1;

    for(int i=0; i<GEN; i++){
        
        //Condicao Inicial
        if(i == 0){
            
            printf("Condicao Inicial: %d \n", totalCells(grid));

            /*printf("\n");
            for(int k = 0; k < SIZE; k++){
                for(j = 0; j < SIZE; j++){
                     printf("%d ", grid[k][j]);
                }
                printf("\n");
            }*/

        }else{  

            //Demais geracoes
            checkCells(grid, newGrid);
            printf("Geracao %d: %d\n", i, totalCells(grid));
        
        }
    }

    // Tempo
    gettimeofday(&stop,0);

    long sec, mic; 
    double dif;
    
    sec = stop.tv_sec - start.tv_sec;
    mic = stop.tv_usec - start.tv_usec;
    
    dif = sec - mic * 1e-6;

    printf("\nTempo (segundos): %.4f", dif);
    printf("\nTempo (minutos): %.4f", dif/60);

    return 0;
}
