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
#define BUFSIZE 2000
#define PACKET_CNT 2000

int generate_msg(unsigned char *buf, int buf_siz, int it)
{
	unsigned char val = 0;
	if (it > buf_siz)
		return -1;

	for (int i = 0; i < it; i++) {
		buf[i] = val;
		val++;
	}

	return 0;
}


int check_msg(unsigned char *buf, int buf_siz, int it)
{
	unsigned char test = 0;
	if (it > buf_siz)
		return -1;
		
	for (int i = 0; i < it; i++) {
		if (buf[i] != test) {
			printf("buf[%d] = %u, test = %u\n", i, 
				(unsigned int)buf[i], (unsigned int)test);
			return -2;
		}
		test++;
	}

	return 0;
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

		for (int i = 1; i < PACKET_CNT + 1; i++) {
			int cnt = i;
			int tmp = 0;
			do {
			 	rt = recv(tcp_c_sock, buf + tmp, i, 0);
				
				if (rt < 0) {
					perror("recv");
					close(tcp_c_sock);
					close(tcp_sock);
					return -1;
				}
				cnt -= rt;
				tmp += rt;
			} while (cnt);

			printf("Server received %d packet.\n", i);
			rt = check_msg(buf, BUFSIZE, i);
			if (rt < 0) {
				printf("Error occured on packet %d, program" 
					" aborts.\n", i);
				return -1;
			}	
		}

		for (int i = 1; i < PACKET_CNT + 1; i++) {
			generate_msg(buf, BUFSIZE, i);
			rt = send(tcp_c_sock, buf, i, 0); 
			if (rt < 0) {
				perror("send");
				close(tcp_c_sock);
				close(tcp_sock);
				return -1;
			}
			printf("Server send %d packet.\n", i);
		}
		sleep(10);
		close(tcp_c_sock);
	}
	close(tcp_sock);
}
