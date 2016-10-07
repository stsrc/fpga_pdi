#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>

#define SERVER "10.0.0.2"
#define CLIENT "10.0.0.3"
#define BUFLEN 512
#define PORT_UDP 8888
#define PORT_TCP 8889



int main(void) {
	unsigned char buf[512];
	int udp_sock, tcp_sock;
	struct sockaddr_in srv_udp, srv_tcp, clnt_udp;
	struct ifreq ifr;

	memset((char *)&srv_udp, 0, sizeof(struct sockaddr_in));
	memset((char *)&srv_tcp, 0, sizeof(struct sockaddr_in));
	memset(buf, 0, sizeof(buf));	

	udp_sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (udp_sock < 0) {
		perror("socket");
		return -1;
	}

	tcp_sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (tcp_sock < 0) {
		perror("socket");
		close(udp_sock);
		return -1;
	}
	
	srv_udp.sin_family = AF_INET;
	srv_udp.sin_port = htons(PORT_UDP);
	srv_udp.sin_addr.s_addr = inet_addr(SERVER);

	srv_tcp.sin_family = AF_INET;
	srv_tcp.sin_port = htons(PORT_TCP);
	srv_tcp.sin_addr.s_addr = inet_addr(SERVER);

	clnt_udp.sin_family = AF_INET;
	clnt_udp.sin_port = htons(PORT_UDP);
	clnt_udp.sin_addr.s_addr = inet_addr(CLIENT);

	int rt;
	rt = bind(udp_sock, (struct sockaddr*)&clnt_udp, sizeof(clnt_udp));
	if (rt == -1) {
		perror("bind");
		return -1;
	}
	printf("udp_sock was binded.\n");
	
	snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "eth0");
	if (setsockopt(udp_sock, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr)) < 0) {
		perror("setsockopt");
		return -1;
	}
	printf("udp_sock binded to eth0.\n");
	if (setsockopt(tcp_sock, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr)) < 0) {
		perror("setsockopt");
		return -1;
	}
	printf("tcp_sock binded to eth0.\n");
	rt = connect(tcp_sock, (struct sockaddr*)&srv_tcp, sizeof(struct sockaddr));
	if (rt == -1) {
		perror("connect");
		return -1;
	}
	printf("tcp_sock connected to server.\n");
	rt = connect(udp_sock, (struct sockaddr*)&srv_udp, sizeof(struct sockaddr));
	if (rt == -1 ){
		perror("connect");
		return -1;
	}
	printf("udp_sock connected to server.\n");
	rt = recv(tcp_sock, buf, 1, 0);
	if (rt == -1) {
		perror("recv");
		return -1;
	}		
	
	if (buf[0] != 0xfa) {
		printf("Dell sent wrong start command!\n");
		return -1;
	}
	printf("tcp_sock received 0xfa (start command).\n");

	unsigned char temp = 0;
	unsigned int cnt = 0;
	socklen_t addrlen;

	while(cnt < 6000) {

		memset(buf, temp, sizeof(buf));

		rt = sendto(udp_sock, buf, sizeof(buf), 0, 
			    (struct sockaddr *)&clnt_udp, sizeof(clnt_udp));
		if (rt < 0) {
			perror("sendto");
			return rt;
		}
		cnt += rt;
		temp++;
		if (temp == 0xff)
			temp = 0;
	}
	memset(buf, 0xff, sizeof(buf));	
	rt = sendto(udp_sock, buf, sizeof(buf), 0, (struct sockaddr *)&clnt_udp, sizeof(clnt_udp));
	if (rt < 0) {
		perror("sendto");
		return rt;
	}
	cnt += rt;
	printf("0xff end byte was sent.\n");

	rt = send(tcp_sock, (char *)&cnt, sizeof(int), 0);
	if (rt < 0) {
		perror("send");
		return rt;
	}

	close(tcp_sock);
	close(udp_sock);
	return 0;
}
