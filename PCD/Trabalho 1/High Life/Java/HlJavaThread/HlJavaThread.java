package HlJavaThread;

import java.lang.Thread;

public class HlJavaThread {
	
	static int SIZE = 2048;
	static int GEN = 2000;
	static int THREADS = 8;
	
	static Thread [] td = new Thread[THREADS*2];
	static TotalCellsThread [] tct = new TotalCellsThread[THREADS];
	static CheckCellsThread [] cct = new CheckCellsThread[THREADS];
	
	private static int totalCells(int[][] grid) {
		
		int total = 0;
		int i;
		
		for(i = 0; i < THREADS; i++) {
			
			tct[i] = new TotalCellsThread(grid, i, SIZE, THREADS);
			
			td[i] = new Thread(tct[i]);
			td[i].start();
		}
		
		for(i = 0; i < THREADS; i++) {
			try {
				td[i].join();
				total += tct[i].getCont();
				
			}catch(InterruptedException e){
				System.out.println(e.getMessage());
			}
		}
		
		return total;
	}

	private static int[][] checkCells(int[][] grid, int[][] newGrid) {
		int i, j, k;
		
		for(i = 0; i < THREADS; i++) {
			
			cct[i] = new CheckCellsThread(grid, newGrid, i, SIZE, THREADS);
			
			td[i*2] = new Thread(cct[i]);
			td[i*2].start();
		}
		
		for(i = 0; i < THREADS; i++) {
			try {
				td[i*2].join();
				for(j = i; j < SIZE; j++) {
					for(k = 0; k < SIZE; k++) {
						newGrid[i][j] = cct[i].getNewGrid()[i][j];
					}
				}
				
			}catch(InterruptedException e){
				System.out.println(e.getMessage());
			}
		}
		
		
		return newGrid;
	}
	
	public static void main(String [] args) {

		long start = System.nanoTime();
		
		int lin = 1, col = 1, i, j;
		
		int[][] grid = new int[SIZE][SIZE];
		int[][] newGrid = new int[SIZE][SIZE];
		
		//Inicializando com 0 a matriz grid
		for(i = 0; i < SIZE; i++){
	        for(j = 0; j < SIZE; j++){
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
	            grid = checkCells(grid, newGrid).clone();
	            System.out.println("Geracao " + i + ": " + totalCells(grid));
	        }
	    }

		long stop = System.nanoTime();
        long dif = (stop - start) / 1000000;
        
		System.out.println("Tempo: " + dif + "ms");

	}
}
