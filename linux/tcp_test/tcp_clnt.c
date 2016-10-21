#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>
#include <stdlib.h>
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
		printf("Wrong input args.\n"
			"First arg: transmission time in seconds.\n"
			"Second arg: Interface to bound.\n"
			"Third arg: server ip.\n");

		return -EINVAL;
	}

	sscanf(argv[1], "%d", transm_time);
	sscanf(argv[2], "%s", Int);
	sscanf(argv[3], "%s", server_ip);
	return 0;
}

int main(int argc, char *argv[]) {
	unsigned char buf[BUFLEN];
	char Int[20];
	char server_ip[20];

	int tcp_sock;
	int rt;
	int transm_time, actual_time;
	struct sockaddr_in srv_tcp;
	struct ifreq ifr;
	struct timespec t1, t2;

	memset((char *)&srv_tcp, 0, sizeof(struct sockaddr_in));

	rt = arg_parse(argc, argv, &transm_time, Int, server_ip);

	if (rt < 0)
		return rt;

	tcp_sock = socket(PF_INET, SOCK_STREAM, 0);
	if (tcp_sock < 0) {
		perror("socket");
		return -1;
	}
	
	srv_tcp.sin_family = AF_INET;
	srv_tcp.sin_port = htons(SERVER_PORT);
	srv_tcp.sin_addr.s_addr = inet_addr(server_ip);

	snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "%s", Int);

	if (setsockopt(tcp_sock, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr)) < 0) {
		perror("setsockopt");
		return -1;
	}

	rt = connect(tcp_sock, (struct sockaddr*)&srv_tcp, sizeof(srv_tcp));
	if (rt == -1) {
		perror("connect");
		return -1;
	}
	printf("tcp_sock connected to server.\n");

	clock_gettime(CLOCK_MONOTONIC, &t1);
	while(actual_time < transm_time) { 
		int packet_size = rand() % BUFLEN;
		generate_msg(buf, packet_size);
		rt = send(tcp_sock, buf, packet_size, 0);
		if (rt < 0) {
			perror("send");
			close(tcp_sock);
			return -1;
		}	
		printf("Sent packet of %d size.\n", packet_size);
		rt = recv(tcp_sock, buf, BUFLEN, 0);
		if (rt < 0) {
			perror("send");
			close(tcp_sock);
			return -1;
		}
		printf("Received packet of %d size.\n", rt);
		clock_gettime(CLOCK_MONOTONIC, &t2);
		actual_time = t2.tv_sec - t1.tv_sec;
	}
	printf("Time exceeded. Connection ends.\n");
	close(tcp_sock);
	return 0;
}
