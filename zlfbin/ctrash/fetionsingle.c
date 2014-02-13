#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

void main(int agrc, char *agrv[])
{
	char *command,cmd[2048];
	char zto[12]; /*contact to send message*/
	command="/web/nagios/libexec/fetion";
	if ( access(command, F_OK) != 0 ) {
		printf("The fetion command don't exist!please check /web/nagios/libexec/fetion\n"); exit(0);
	}
	else if ( agrc <= 1 ) {
		printf("NO MESSAGE;Please type some message to your friend\n"); exit(0);
	}
	else {
		printf("PLEASE INPUT YOUR MESSAGE TO:"); scanf("%11[0-9][^\n]d", zto);
		printf("send %s to %s\n", agrv[1], zto);
		sprintf(cmd, "%s --mobile=15221556659 --pwd=1qazxsw2 --to=%s --msg-type=1 --msg-utf8=\"%s\"", command, zto, agrv[1]);
		system(cmd);
	}
}
