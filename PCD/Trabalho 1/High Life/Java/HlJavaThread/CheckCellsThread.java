package HlJavaThread;

public class CheckCellsThread implements Runnable{
	
	private int [][] grid;
	private int [][] newGrid;
	private static int SIZE;
	private int THREADS;
	private int threadID;
	private int i, j, total_n;
	
	public CheckCellsThread(int [][] grid, int [][] newGrid, int threadID, int SIZE, int THREADS) {
		
		this.grid = grid;
		this.newGrid = newGrid;
		this.threadID = threadID;
		this.SIZE = SIZE;
		
		if(SIZE < THREADS)
			this.THREADS = SIZE;
		else
			this.THREADS = THREADS;
	}
	
	public void run() {
		for(i = threadID; i < SIZE; i ++) {
			for(j = 0; j < SIZE; j++) {
				
				total_n = getNeighbors(grid, i, j);
				
				if(grid[i][j] == 1){

	                if(total_n < 2){   //Celula morre por abandono
	                    newGrid[i][j] = 0;

	                }else if(total_n == 2 || total_n == 3){     //Celula continua viva
	                    newGrid[i][j] = 1;

	                }else if(total_n >= 4){     //Celula morre por superpopulação
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
	
	private static int getNeighbors(int [][] grid, int i, int j) {
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
	
	public int[][] getNewGrid(){
		return newGrid;
	}
}


