#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>
#include <time.h>
#include <stdlib.h>

#define SERVER "10.0.0.2"
#define PORT_TCP 8889
#define BUFSIZE 1024
#define PACKET_CNT 1000
void generate_msg(char *buf, int buf_siz) {
	for (int i = 0; i < buf_siz; i++)
		buf[i] = (char)i + (char)rand();
}

int main(void)
{
	unsigned char buf[BUFSIZE];
	int tcp_sock, tcp_c_sock;
	struct sockaddr_in srv_tcp;
	struct ifreq ifr;
	
	srand(time(0));
	memset((char *)&srv_tcp, 0, sizeof(struct sockaddr_in));
	memset(buf, 0, sizeof(buf));	

	tcp_sock = socket(PF_INET, SOCK_STREAM, 0);
	if (tcp_sock < 0) {
		perror("socket");
		return -1;
	}
	printf("created tcp_sock.\n");
	srv_tcp.sin_family = AF_INET;
	srv_tcp.sin_port = htons(PORT_TCP);
	srv_tcp.sin_addr.s_addr = inet_addr(SERVER);

	int rt;

	if (setsockopt(tcp_sock, SOL_SOCKET, SO_REUSEADDR, &(int){1}, sizeof(int)) < 0) {
		perror("setsockopt");
		return -1;
	}


	rt = bind(tcp_sock, (struct sockaddr*)&srv_tcp, sizeof(srv_tcp));
	if (rt == -1) {
		perror("bind");
		return -1;
	}
	printf("tcp_sock was binded.\n");
	snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "enp36s0f1");


	if (setsockopt(tcp_sock, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr)) < 0) {
		perror("setsockopt");
		return -1;
	}
	printf("tcp_sock binded to enp36s0f1.\n");
	
	rt = listen(tcp_sock, 2);
	if (rt < 0) {
		perror("listen");
		return -1;
	}
	printf("tcp_sock as listening socket.\n");
	while(1) {
		tcp_c_sock = accept(tcp_sock, NULL, NULL);
		if (tcp_c_sock < 0) {
			perror("accept");
			return -1;
		}
		printf("tcp_sock accepted connection\n");
		printf("Server receives %d packets.\n", PACKET_CNT);
		for (int i = 0; i < PACKET_CNT; i++) {
			rt = recv(tcp_c_sock, buf, BUFSIZE, 0);

			if (rt < 0) {
				perror("recv");
				close(tcp_c_sock);
				close(tcp_sock);
				return -1;
			}
			printf("Server received %d packet.\n", i + 1);

		}
		printf("Server received %d messages with 1024 bytes each.\n"
		       "Server now sends %d messages with 1024 bytes each.\n",
			PACKET_CNT, PACKET_CNT);
		for (int i = 0; i < PACKET_CNT; i++) {
			generate_msg(buf, BUFSIZE);
			rt = send(tcp_c_sock, buf, BUFSIZE, 0); 
			if (rt < 0) {
				perror("send");
				close(tcp_c_sock);
				close(tcp_sock);
				return -1;
			}
			printf("Server send %d packet.\n", i + 1);
		}
		sleep(10);
		close(tcp_c_sock);
	}
	close(tcp_sock);
}
