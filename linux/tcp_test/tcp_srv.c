#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>
#include <time.h>
#include <stdlib.h>
#include <errno.h>

#define BUFLEN 10000
#define SERVER_PORT 8889

void generate_msg(char *buf, int msg_size) {
	for (int i = 0; i < msg_size; i++)
		buf[i] = (char)i + (char)rand();
}

int arg_parse(int argc, char *argv[], char *Int, char *server_ip, 
	      int *max_packet) 
{
	if (argc != 4) {
		printf("Wrong input args.\n"
			"First arg: Interface to bound.\n"
			"Second arg: server ip.\n"
			"Thir arg: Maximum packet size.\n");
		return -EINVAL;
	}

	sscanf(argv[1], "%s", Int);
	sscanf(argv[2], "%s", server_ip);
	sscanf(argv[3], "%d", max_packet);

	if (*max_packet >= BUFLEN) {
		printf("Wrong maximum packet size. It is bigger than internal"
			" buffer!\n");
		return -EINVAL;		
	}

	return 0;
}

int main(int argc, char *argv[])
{
	unsigned char buf[BUFLEN];
	int tcp_sock, tcp_c_sock;
	struct sockaddr_in srv_tcp;
	struct ifreq ifr;

	char Int[20];
	char server_ip[20];
	int rt, max_packet, packet_size;
	
	srand(time(0));
	memset((char *)&srv_tcp, 0, sizeof(struct sockaddr_in));
	memset(buf, 0, sizeof(buf));

	rt = arg_parse(argc, argv, Int, server_ip, &max_packet);
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


	if (setsockopt(tcp_sock, SOL_SOCKET, SO_REUSEADDR, &(int){1}, sizeof(int)) < 0) {
		perror("setsockopt");
		return -1;
	}


	rt = bind(tcp_sock, (struct sockaddr*)&srv_tcp, sizeof(srv_tcp));
	if (rt == -1) {
		perror("bind");
		return -1;
	}

	snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "%s", Int);


	if (setsockopt(tcp_sock, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr)) < 0) {
		perror("setsockopt 2");
		return -1;
	}

	rt = listen(tcp_sock, 2);
	if (rt < 0) {
		perror("listen");
		return -1;
	}

	while(1) {
		printf("Server listens for incoming connection.\n\n");
		tcp_c_sock = accept(tcp_sock, NULL, NULL);
		if (tcp_c_sock < 0) {
			perror("accept");
			return -1;
		}
		printf("Server has connected to the client.\n\n");
		while(1) {

			rt = recv(tcp_c_sock, buf, BUFLEN, 0);

			if (rt <= 0) {
				printf("Client terminated connection.\n\n");
				break;
			}

			printf("Server received packet of %d size.\n", rt);		
	
			packet_size = 1 + rand() % (max_packet - 1);
			generate_msg(buf, packet_size);

			rt = send(tcp_c_sock, buf, packet_size, 0); 
			if (rt <= 0) { 
				printf("Client terminated connection.\n\n");
				break;
			}	

			printf("Server sent packet of %d size.\n", packet_size);
		}

		close(tcp_c_sock);
	}
	close(tcp_sock);
}
