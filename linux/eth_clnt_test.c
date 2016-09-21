#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>

#define SERVER "192.168.0.0"
#define CLIENT "192.168.0.1"
#define BUFLEN 512
#define PORT 8888


void generate_msg(char *buf) {
	for (int i = 0; i < 65; i++)
		buf[i] = i;
}

int main(void) {
	struct sockaddr_in srv_sock, clnt_sock;
	char buf[BUFLEN];
	int slen = sizeof(srv_sock);
	int sockfd, rt;

	generate_msg(buf);

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
	snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "eth1");
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
	rt = send(sockfd, buf, 65, 0);
	
	if (rt < 0) 
		perror("send");
	else
		printf("Client sent %d bytes.\n", rt);

	close(sockfd);
	return 0;
}
