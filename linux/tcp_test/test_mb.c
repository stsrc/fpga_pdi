#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>
#include <stdlib.h>

#define SERVER "10.0.0.2"
#define CLIENT "10.0.0.3"
#define BUFLEN 1024
#define PORT_TCP 8889
#define PACKET_CNT 1000

int generate_msg(char *buf, int buf_siz, int it)
{
	if (it >= buf_siz)
		return -1;

	for (int i = 0; i < it; i++)
		buf[i] = (char)i;

	return 0;
}


int check_msg(char *buf, int buf_siz, int it)
{
	if (it >= buf_siz)
		return -1;
		
	for (int i = 0; i < it; i++) {
		if (buf[i] != i)
			return -2;
	}

	return 0;
}

int main(void) {
	unsigned char buf[BUFLEN];
	int tcp_sock;
	struct sockaddr_in srv_tcp;
	struct ifreq ifr;

	memset((char *)&srv_tcp, 0, sizeof(struct sockaddr_in));

	memset(buf, 0, sizeof(buf));	

	tcp_sock = socket(PF_INET, SOCK_STREAM, 0);
	if (tcp_sock < 0) {
		perror("socket");
		return -1;
	}
	
	srv_tcp.sin_family = AF_INET;
	srv_tcp.sin_port = htons(PORT_TCP);
	srv_tcp.sin_addr.s_addr = inet_addr(SERVER);

	int rt;

	snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "eth0");

	if (setsockopt(tcp_sock, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr)) < 0) {
		perror("setsockopt");
		return -1;
	}

	printf("tcp_sock binded to eth0.\n");
	rt = connect(tcp_sock, (struct sockaddr*)&srv_tcp, sizeof(srv_tcp));
	if (rt == -1) {
		perror("connect");
		return -1;
	}
	printf("tcp_sock connected to server.\n");

	for (int i = 1; i < PACKET_CNT + 1; i++) {
		generate_msg(buf, BUFLEN, i);
		rt = send(tcp_sock, buf, i, 0);
		if (rt < 0) {
			perror("send");
			close(tcp_sock);
			return -1;
		}
		printf("Client sent %d packet.\n", i + 1);
		sleep(1);
	}
	printf("Packets were sent.\n");
	printf("Receiving %d packets.\n", PACKET_CNT);
	for (int i = 0; i < PACKET_CNT; i++) {
		rt = recv(tcp_sock, buf, i, 0);
		if (rt < 0) {
			perror("send");
			close(tcp_sock);
			return -1;
		}
		printf("Client received %d packet.\n", i + 1);
		rt = check_msg(buf, BUFLEN, i);
		if (rt < 0) {
			printf("Error occured on packet %d, programs" 
				" aborts.\n", i);
			return -1;
		}	
	}
	close(tcp_sock);
	return 0;
}
