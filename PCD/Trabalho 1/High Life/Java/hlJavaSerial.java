import java.security.GeneralSecurityException;

public class hlJavaSerial {

	static final int SIZE = 50;
	static final int GEN = 5;
	
	
	private static int getNeighbors(int grid[][], int i, int j) {
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
	        jj = jj % SIZE;
	    }
	    if(ji == SIZE){
	        ji = ji % SIZE;
	    }

	    total_n = grid[ii][ij] + grid[ii][j] + grid[ii][jj] +
	              grid [i][ij]       +         grid [i][jj] +
	              grid[ji][ij] + grid[ji][j] + grid[ji][jj];

	    return total_n;
	}
	
	private static int totalCells(int grid[][]){
	    int total = 0, i, j;

	    for(i=0; i<SIZE; i++){
	        for(j=0; j<SIZE; j++){
	            if(grid[i][j] == 1){
	                total++;
	            }
	        }
	    }
	    return total;
	}
	
	private static void checkCells(int grid[][], int newGrid[][]){
	    int i, j, total_n;

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

	    for(i=0; i<SIZE; i++){
	        for(j=0; j<SIZE; j++){

	            grid[i][j] = newGrid[i][j];

	        }
	    }
	}
	
	public static void main(String [] args) {

		long start = System.nanoTime();
		
		int lin = 1, col = 1, i, j;
		
		int[][] grid = new int[SIZE][SIZE];
		int[][] newGrid = new int[SIZE][SIZE];
		
		//Inicializando com 0 a matriz grid
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
	    
	    for(i=0; i<GEN; i++){
	        
            //Condicao Inicial
	        if(i == 0){
	        	
                System.out.println("Condicao Inicial: " + totalCells(grid));
	            
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
	            System.out.println("Geracao " + i + ": " + totalCells(grid));
	        }
	    }

		long stop = System.nanoTime();
        long dif = (stop - start) / 1000000;
        
		System.out.println("Tempo: " + dif + "ms");

	}
}
