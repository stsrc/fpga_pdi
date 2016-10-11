#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>

#define SERVER "10.0.0.3"
#define CLIENT "10.0.0.2"
#define BUFLEN 1024
#define PORT 8888


void generate_msg(char *buf, int buf_siz) {
	for (int i = 0; i < buf_siz; i++)
		buf[i] = (char)i + (char)rand();
}

int main(void) {
	struct sockaddr_in srv_sock, clnt_sock;
	char buf[BUFLEN];
	int slen = sizeof(srv_sock);
	int sockfd, rt;
	srand(time(0));
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
		return -1;
	}

	struct ifreq ifr;
	snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "enp36s0f1");
	if (setsockopt(sockfd, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr)) < 0) {
		perror("setsockopt");
		return -1;
	}


	srv_sock.sin_family = AF_INET;
	srv_sock.sin_port = htons(PORT);
	srv_sock.sin_addr.s_addr = inet_addr(SERVER);
	
	rt = connect(sockfd, (struct sockaddr*)&srv_sock, sizeof(struct sockaddr));
	if (rt == -1) {
		perror("connect");
		return rt;
	}
	printf("client has connected socket to server.\n");

	for (int i = 0; i < 1; i++) {
		generate_msg(buf, BUFLEN);
		rt = send(sockfd, buf, BUFLEN, 0);
	}
	printf("Client sent 1 packets with 1024 bytes.\n");
	
	close(sockfd);
	return 0;
}
