/*
-- Programacao Concorrente e Distribuida
-- Atividade 1 - Mecanismos de controle da secao critica
--
-- Autores: Julia Noriko Ohashi (133712)
            Nicoli Castro Ferreira (133776)
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

#define THREADS 2

//Globals
int respond = 0;
int request = 0;
int SOMA = 0;

void *client_process(void* i){

    while(1){

        int j = (int) i;
        
        //while(respond != j){
            request = j;
        //}

        //Critical section
        
        int local = SOMA;
        sleep(rand()%2);
        SOMA = local + 1;
        respond = 0;
        
        printf("Thread: %d: %d \n", j, SOMA);
    }
}

void *server_process(void* i){

    while(1){

        while(request == 0){}

        respond = request;

        while(respond != 0){}

        request = 0;
    }
}

int main(int argc, char *argv[]){

    pthread_t th_server;
    pthread_t th_cli[THREADS];

    int i;

    //Criando a thread do server
    pthread_create(&th_server, NULL, server_process, NULL);

    //Criando as threads dos clients
    for(i = 0; i < THREADS; i++)
        pthread_create(&th_cli[i], NULL, client_process, (void* ) (i+1));
    

    pthread_exit(NULL);

    return 0;
}