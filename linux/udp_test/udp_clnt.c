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

#define BUFLEN 10000
#define SERVER_PORT 8889

void generate_msg(char *buf, int msg_size) {
	for (int i = 0; i < msg_size; i++)
		buf[i] = (char)i + (char)rand();
}

int arg_parse(int argc, char *argv[], int *transm_time, char *Int, 
	      char *server_ip) 
{
	if (argc != 4) {
		printf("Wrong input args. First arg: buffer length, second:"
			" transmission count.\n");
		return -EINVAL;
	}
	sscanf(argv[1], "%d", transm_time);	
	sscanf(argv[2], "%s", Int);
	sscanf(argv[3], "%s", server_ip);
	return 0;
}

int main(int argc, char *argv[]) {
	struct sockaddr_in srv_sock;
	char buf[BUFLEN];
	int slen = sizeof(srv_sock);
	int sockfd, rt;
	struct timespec t1, t2;
	struct ifreq ifr;

	char Int[20];
	char server_ip[20];
	int transm_time;
	int actual_time;
	
	rt = arg_parse(argc, argv, &transm_time, Int, server_ip);
	if (rt < 0)
		return rt;

	sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (sockfd == -1) {
		perror("socket");
		return -1;
	}
	memset((char *) &srv_sock, 0, sizeof(struct sockaddr_in));

	snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "%s", Int);
	if (setsockopt(sockfd, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr)) < 0) {
		perror("setsockopt");
		return -1;
	}

	srv_sock.sin_family = AF_INET;
	srv_sock.sin_port = htons(SERVER_PORT);
	srv_sock.sin_addr.s_addr = inet_addr(server_ip);
	
	rt = connect(sockfd, (struct sockaddr*)&srv_sock, sizeof(struct sockaddr));
	if (rt == -1) {
		perror("connect");
		return rt;
	}
	printf("client has connected socket to server.\n");
	clock_gettime(CLOCK_MONOTONIC, &t1);

	while(actual_time < transm_time) {
		int packet_size = rand() % BUFLEN;
		generate_msg(buf, packet_size);
		rt = send(sockfd, buf, packet_size, 0);
		if (rt < 0)
			break;
		printf("Sent packet with %d bytes.\n", packet_size);

		rt = recv(sockfd, buf, BUFLEN, 0);
		if (rt < 0)
			break;
		printf("Received packet with %d bytes.\n", rt);
		clock_gettime(CLOCK_MONOTONIC, &t2);
		actual_time = t2.tv_sec - t1.tv_sec;
	}

	printf("Time exceeded. Connection ends.\n");	
	close(sockfd);

	return 0;
}
