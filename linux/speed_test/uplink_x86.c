#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>
#include <time.h>

#define SERVER "10.0.0.2"
#define CLIENT "10.0.0.3"
#define BUFLEN 512
#define PORT_UDP 8888
#define PORT_TCP 8889

int main(void) {
	const unsigned char test = 0xfa;
	unsigned char buf[512];
	int udp_sock, tcp_sock, tcp_c_sock;
	struct sockaddr_in srv_udp, srv_tcp, clnt_udp;
	struct ifreq ifr;
	struct timespec t1, t2;

	memset((char *)&srv_udp, 0, sizeof(struct sockaddr_in));
	memset((char *)&srv_tcp, 0, sizeof(struct sockaddr_in));
	memset(buf, 0, sizeof(buf));	

	udp_sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (udp_sock < 0) {
		perror("socket");
		return -1;
	}
	printf("created udp_sock.\n");
	tcp_sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (tcp_sock < 0) {
		perror("socket");
		close(udp_sock);
		return -1;
	}
	printf("created tcp_sock.\n");

	if (setsockopt(tcp_sock, SOL_SOCKET, SO_REUSEADDR, &(int){1}, sizeof(int)) < 0) {
		perror("setsockopt");
		return -1;
	}

	srv_udp.sin_family = AF_INET;
	srv_udp.sin_port = htons(PORT_UDP);
	srv_udp.sin_addr.s_addr = inet_addr(SERVER);

	clnt_udp.sin_family = AF_INET;
	clnt_udp.sin_port = htons(PORT_UDP);
	clnt_udp.sin_addr.s_addr = inet_addr(CLIENT);

	srv_tcp.sin_family = AF_INET;
	srv_tcp.sin_port = htons(PORT_TCP);
	srv_tcp.sin_addr.s_addr = inet_addr(SERVER);

	int rt;
	rt = bind(udp_sock, (struct sockaddr*)&srv_udp, sizeof(srv_udp));
	if (rt == -1) {
		perror("bind");
		return -1;
	}
	printf("udp_sock was binded.\n");
	rt = bind(tcp_sock, (struct sockaddr*)&srv_tcp, sizeof(srv_tcp));
	if (rt == -1) {
		perror("bind");
		return -1;
	}
	printf("tcp_sock was binded.\n");
	snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "enp36s0f1");
	if (setsockopt(udp_sock, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr)) < 0) {
		perror("setsockopt");
		return -1;
	}
	printf("udp_sock binded to enp36s0f1.\n");
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

	tcp_c_sock = accept(tcp_sock, NULL, NULL);
	if (tcp_c_sock < 0) {
		perror("accept");
		return -1;
	}
	printf("tcp_sock accepted connection\n");
	rt = send(tcp_c_sock, &test, 1, 0);
	if (rt < 0) {
		perror("write");
		return -1;
	}
	printf("test command was sent.\n");
	sleep(1);

	unsigned int cnt = 0;
	unsigned int bytes_cnt = 0;
	socklen_t addrlen;
	
	clock_gettime(CLOCK_MONOTONIC, &t1);
	while (1) {
		rt = recvfrom(udp_sock, buf, sizeof(buf), 0, (struct sockaddr *)&srv_udp, 
			      &addrlen);
		bytes_cnt += rt;
		if ((*buf == 0xff) ||((*(buf + sizeof(buf)/2)) == 0xff) || (rt < 0))
			break;
	}
	clock_gettime(CLOCK_MONOTONIC, &t2);

	printf("Received %d bytes.\n", bytes_cnt);
	printf("Transmission of test data was stopped.\n");


	rt = recv(tcp_c_sock, buf, sizeof(buf), 0);
	if (rt < 0) {
		printf("problem occured on receiving bytes count from mb.\n");
		perror("recv");
		return rt;
	}
	printf("\nReceived result from MB.\n");
	cnt = buf[0] | buf[1] << 8 | buf[2] << 16 | buf[3] << 24;
	
	printf("\nDELL received %d of %d bytes ", bytes_cnt, cnt);
	long time = t2.tv_sec * 10e9 + t2.tv_nsec - (t1.tv_sec * 10e9 + t1.tv_nsec);
	printf("in time %ld nsec\n", time);
	double speed = bytes_cnt / ((double)time * 10.0e-9);
	printf("Overall uplink speed is: %.2f B/s = %.2f kB/s = %.2f MB/s.\n",
		speed, speed/1024.0, speed/(1024.0*1024.0));

	printf("Percent of lost packets: %.2f%%;\n", (double)(cnt - bytes_cnt) 
		/ (double)cnt * 100.0);
	printf("\n");	
	close(udp_sock);
	close(tcp_sock);
	close(tcp_c_sock);
}
