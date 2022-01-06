#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>

#include <mpi.h>

#define SIZE 2048
#define GEN 2000

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

int totalCells(int **grid, int gen){
    int total = 0, totloc = 0, i, j, noProcesses, processId;

    MPI_Comm_size(MPI_COMM_WORLD, &noProcesses);
    MPI_Comm_rank(MPI_COMM_WORLD, &processId);

    for(i=processId; i<SIZE; i+=noProcesses){
        for(j=0; j<SIZE; j++){
            if(grid[i][j] == 1){
                totloc++;
            }
        }
    }

    MPI_Reduce(&totloc, &total, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD); //Soma totais locais no total do proc pai (0)
    
    if(processId==0){

        printf("Geracao %d: %d\n", gen, total);
    }
}

int checkCells(int **grid, int *newGrid){
    
    int i, j, aux, total_n, noProcesses, processId;

	for(i=0; i<SIZE*SIZE; i++){
            auxiliar[i] = 0;
            auxiliarGrid[i] = 0;
        }	
        */
	
    MPI_Comm_size(MPI_COMM_WORLD, &noProcesses);
    MPI_Comm_rank(MPI_COMM_WORLD, &processId);

    for(i=processId; i<SIZE; i+=noProcesses){

        for(j=0; j<SIZE; j++){

            total_n = getNeighbors(grid, i, j);

            if(grid[i][j] == 1){

                if(total_n < 2){   //Celula morre por abandono
                    newGrid[i * SIZE + j] = 0;

                }else if(total_n == 2 || total_n == 3){     //Celula continua viva
                    newGrid[i * SIZE + j] = 1;

                }else if(total_n >= 4){     //Celula morre por superpopulacao
                    newGrid[i * SIZE + j] = 0;

                }
            }else if(total_n == 3){
                newGrid[i * SIZE + j] = 1;

            }else{
                newGrid[i * SIZE + j] = 0;
            }
        }
    }

    if(processId!=0){ 
        MPI_Send(newGrid, (SIZE*SIZE), MPI_INT, 0, 1, MPI_COMM_WORLD); //Proc filhos enviam seu array[newGrid] para o proc pai (0)
    }

    if(processId==0){
        
        for(i=0; i<SIZE; i+=noProcesses){ //Atualiza grid processado pelo proc pai
            for(j=0; j<SIZE; j++){
                grid[i][j] = newGrid[i * SIZE + j];
            }
        }
         
        for(aux=1; aux<noProcesses; aux++){

            MPI_Recv(newGrid, (SIZE*SIZE), MPI_INT, aux, 1, MPI_COMM_WORLD, NULL); //Proc pai recebe array[newgrid] de cada filho
            
            for(i=aux; i<SIZE; i+=noProcesses){ //Atualiza grid com cada array[newGrid] vindo dos filhos
                for (j=0; j<SIZE; j++){
                    grid[i][j] = newGrid[i * SIZE + j];
                }
            }
        }
    }
    
    //Transformando matriz em array para usar em MPI_Bcast
    for(i=0; i<SIZE; i++){
	    for(j=0; j<SIZE; j++){
		    newGrid[i * SIZE + j] = grid[i][j];
		}
	}

    MPI_Bcast(newGrid, (SIZE*SIZE), MPI_INT, 0, MPI_COMM_WORLD); //Compartilha o estado do array[grid] com todos os procs
    
    //Retornando para matriz atualizada
    for(i=0; i<SIZE; i++){
	    for(j=0; j<SIZE; j++){
		    grid[i][j] = newGrid[i * SIZE + j];
		}
	}
}

int main(int argc, char* argv[]){
	
    //Must be called before most other MPI routines are called
    MPI_Init(&argc, &argv);
        
    int lin = 1, col = 1, i, j;
    int **grid;
    
	int *newGrid = (int*)malloc(sizeof(int)*SIZE*SIZE);
	
    //Definindo a matriz
    grid = (int**)malloc(sizeof(int*) * SIZE);

    for(int i=0; i<SIZE; i++){
        grid[i] = (int*)malloc(sizeof(int) * SIZE);
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

    totalCells(grid, 0); //Primeira geracao

    for(int i=1; i<GEN; i++){
        checkCells(grid, newGrid);
        totalCells(grid, i);
    }
    
    MPI_Finalize();

    return 0;
}
