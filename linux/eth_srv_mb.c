#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <net/if.h>

#define SERVER "10.0.0.3"
#define BUFLEN 512
#define PORT 8888

int main(void) {
	struct sockaddr_in si_me, si_other;
	struct ifreq ifr;
	char buf[BUFLEN];
	int slen = sizeof(si_other);
	int s, rt;
	s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (s == -1) {
		perror("socket");
		return -1;
	}
	memset((char *) &si_me, 0, sizeof(struct sockaddr_in));
	si_me.sin_family = AF_INET;
	si_me.sin_port = htons(PORT);
	si_me.sin_addr.s_addr = inet_addr(SERVER);

	rt = bind(s, (struct sockaddr*)&si_me, sizeof(si_me));
	if (rt == -1) {
		perror("bind");
		return -1;
	}

	snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "eth0");
	if (setsockopt(s, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr)) < 0) {
		perror("setsockopt");
		return -1;
	}

	while(1) {
		printf("UDP SERVER: waiting for data.\n");
		rt = recvfrom(s, buf, BUFLEN, 0, (struct sockaddr *)&si_other,
			      &slen);

		if (rt == -1) {
			perror("ecvfrom");
			return -1;
		}

		printf("UDP SERVER: received packet from %s:%d\nData:%s\n", 
		       inet_ntoa(si_other.sin_addr), ntohs(si_other.sin_port),
		       buf);

		memset(buf, 0, BUFLEN);
	}
}
