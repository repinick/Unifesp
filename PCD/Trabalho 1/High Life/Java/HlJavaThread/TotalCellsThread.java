package HlJavaThread;

public class TotalCellsThread implements Runnable{
	
	private int[][] grid;
	private int threadID, SIZE, THREADS, i, j, cont = 0;
	
	public TotalCellsThread(int[][] grid, int threadID, int SIZE, int THREADS) {
		
		this.grid = grid;
		this.threadID = threadID;
		this.SIZE = SIZE;
		
		if(SIZE < THREADS)
			this.THREADS = SIZE;
		else
			this.THREADS = THREADS;
	}
	
	@Override
	public void run() {
		for(i = threadID; i < SIZE; i++) {
			for(j = 0; j < SIZE; j ++) {
				if(grid[i][j] == 1) 
					cont++;
			}
		}
	}
	
	public int getCont() {
		return cont;
	}
}
