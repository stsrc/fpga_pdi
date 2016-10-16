#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>

#define SERVER "10.0.0.3"
#define CLIENT "10.0.0.2"
#define PORT 8888

void generate_msg(char *buf, int buf_siz) 
{
	for (int i = 0; i < buf_siz; i++)
		buf[i] = (char)i;
}

int arg_parse(int argc, char *argv[], int *buf_len, int *transm_cnt) 
{
	if (argc <= 1) {
		printf("Wrong input args. First arg: buffer length, second:"
			" transmission count.\n");
		return -EINVAL;
	}
	sscanf(argv[1], "%d", buf_len);
	sscanf(argv[2], "%d", transm_cnt);	
	return 0;
}

int main(int argc, char *argv[]) {
	struct sockaddr_in srv_sock, clnt_sock;
	char* buf;
	int slen = sizeof(srv_sock);
	int sockfd, rt;
//	struct timespec t1, t2;	
	struct ifreq ifr;

	int buf_len;
	int transm_cnt;

	srand(time(0));
	rt = arg_parse(argc, argv, &buf_len, &transm_cnt);
	if (rt < 0)
		return rt;

	buf = malloc(buf_len);
	if (!buf)
		return -ENOMEM;

	memset(buf, 0, buf_len);
	
	sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (sockfd == -1) {
		perror("socket");
		return -1;
	}
	memset((char *) &srv_sock, 0, sizeof(struct sockaddr_in));
	memset((char *) &clnt_sock, 0, sizeof(struct sockaddr_in));

	clnt_sock.sin_family = AF_INET;
	clnt_sock.sin_port = 0;
	clnt_sock.sin_addr.s_addr = inet_addr(CLIENT);
	rt = bind(sockfd, (struct sockaddr*)&clnt_sock, sizeof(clnt_sock));

	if (rt == -1) {
		perror("bind");
		free(buf);
		return -1;
	}

	snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "enp36s0f1");
	if (setsockopt(sockfd, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr)) < 0) {
		perror("setsockopt");
		free(buf);
		return -1;
	}


	srv_sock.sin_family = AF_INET;
	srv_sock.sin_port = htons(PORT);
	srv_sock.sin_addr.s_addr = inet_addr(SERVER);
	
	rt = connect(sockfd, (struct sockaddr*)&srv_sock, sizeof(struct sockaddr));
	if (rt == -1) {
		perror("connect");
		free(buf);
		return rt;
	}

	printf("client has connected socket to server.\n");

	for (int i = 0; i < transm_cnt; i++) { 
		generate_msg(buf, buf_len);
		rt = send(sockfd, buf, buf_len, 0);
		if (rt < 0)
			break;
	}
	free(buf);
	printf("Client exits.\n");
	close(sockfd);
	return 0;
}
