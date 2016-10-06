#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>

#define SERVER "127.0.0.1"
#define CLIENT "10.0.0.3"
#define BUFLEN 512
#define PORT_UDP 8888
#define PORT_TCP 8889



int main(void) {
	unsigned char buf[512];
	int udp_sock, tcp_sock;
	struct sockaddr_in srv_tcp;
	struct ifreq ifr;

	memset((char *)&srv_tcp, 0, sizeof(struct sockaddr_in));

	memset(buf, 0, sizeof(buf));	

	tcp_sock = socket(PF_INET, SOCK_STREAM, 0);
	if (tcp_sock < 0) {
		perror("socket");
		close(udp_sock);
		return -1;
	}
	
	srv_tcp.sin_family = AF_INET;
	srv_tcp.sin_port = htons(PORT_TCP);
	srv_tcp.sin_addr.s_addr = inet_addr(SERVER);

	int rt;

	rt = connect(tcp_sock, (struct sockaddr*)&srv_tcp, sizeof(srv_tcp));
	if (rt == -1) {
		perror("connect");
		return -1;
	}
	printf("tcp_sock connected to server.\n");

	rt = recv(tcp_sock, buf, 1, 0);
	if (rt == -1) {
		perror("recv");
		return -1;
	}		

	printf("received %d bytes\n", rt);
	printf("First byte received: %d\n", (int)buf[0]);

	if (buf[0] != 0xba) {
		printf("Dell sent wrong input command!\n");
		return -1;
	}
	printf("tcp_sock received 0xba (start command).\n");
	close(tcp_sock);
	return 0;
}
