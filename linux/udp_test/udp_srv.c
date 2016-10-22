#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <net/if.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <time.h>

#define BUFLEN 10000
#define SERVER_PORT 8889

void generate_msg(char *buf, int msg_size) {
	for (int i = 0; i < msg_size; i++)
		buf[i] = (char)i + (char)rand();
}

int arg_parse(int argc, char *argv[], char *Int, char *server_ip, 
	      int *max_packet, int *repeat) 
{
	if (argc < 4) {
		printf("Wrong input args.\n"
			"First arg: Interface to bound.\n"
			"Second arg: server ip.\n"
			"Third arg: Maximum packet size.\n"
			"Fourth arg (optional): Repetition count. Must be the"
			" same as in the client.\n");
		return -EINVAL;
	}

	sscanf(argv[1], "%s", Int);
	sscanf(argv[2], "%s", server_ip);
	sscanf(argv[3], "%d", max_packet);
	
	if (argc == 5)
		sscanf(argv[4], "%d", repeat);
	else
		*repeat = 1;

	if (*max_packet >= BUFLEN) {
		printf("Wrong maximum packet size. It is bigger than internal"
			" buffer!\n");
		return -EINVAL;		
	}

	return 0;
}

int main(int argc, char *argv[]) {
	struct sockaddr_in si_me, si_other;
	struct ifreq ifr;
	char buf[BUFLEN];
	int slen = sizeof(si_other);
	int s, rt, max_packet, packet_size, repeat;

	char Int[20];
	char server_ip[20];

	srand(time(0));

	rt = arg_parse(argc, argv, Int, server_ip, &max_packet, &repeat);
	if (rt < 0)
		return rt;

	s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (s == -1) {
		perror("socket");
		return -1;
	}

	memset((char *) &si_me, 0, sizeof(struct sockaddr_in));
	si_me.sin_family = AF_INET;
	si_me.sin_port = htons(SERVER_PORT);
	si_me.sin_addr.s_addr = inet_addr(server_ip);

	rt = bind(s, (struct sockaddr*)&si_me, sizeof(si_me));
	if (rt == -1) {
		perror("bind");
		return -1;
	}

	snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "%s", Int);
	if (setsockopt(s, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr)) < 0) {
		perror("setsockopt");
		return -1;
	}
	
	while(1) {
		for (int i = 0; i < repeat; i++) {
			rt = recvfrom(s, buf, BUFLEN, 0, 
				(struct sockaddr *)&si_other, &slen);

			if (rt <= 0) {
				perror("recvfrom");
				close(s);
				return -1;
			}	

			printf("Server received packet with %d bytes.\n", rt);
		}
		
		for (int i = 0; i < repeat; i++) {
			packet_size = 1 + rand() % (max_packet - 1);
			generate_msg(buf, packet_size);

			rt = sendto(s,  buf, packet_size, 0, (struct sockaddr *)&si_other,
				    slen);
			if (rt <= 0) {
				perror("sendto");
				close(s);
				return -1;
			}	
			printf("Server sent packet with %d bytes.\n", packet_size);
		}
	}
}
