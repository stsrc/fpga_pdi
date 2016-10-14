#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>
#include <time.h>
#include <stdlib.h>

#define SERVER "10.0.0.3"
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
	snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "eth0");


	if (setsockopt(tcp_sock, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr)) < 0) {
		perror("setsockopt");
		return -1;
	}
	printf("tcp_sock binded to eth0.\n");
	
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
		rt = 1;
		while(rt > 0) {
		rt = recv(tcp_c_sock, buf, BUFSIZE, 0);

		if (rt < 0) {
				perror("recv");
				close(tcp_c_sock);
				continue;
			}
			printf("Server received packet.\n");


			generate_msg(buf, BUFSIZE);
			rt = send(tcp_c_sock, buf, BUFSIZE, 0); 
			if (rt < 0) {
				perror("send");
				close(tcp_c_sock);
				continue;
			}
			printf("Server send packet.\n");
		}
	}
	close(tcp_sock);
}
