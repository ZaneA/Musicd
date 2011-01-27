#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

/* Yay goto :D */
char *trim(char *buffer, char *stripchars)
{
	int i = 0;

	/* Left Side */
	char *start = buffer;

left:
	for (i = 0; i < strlen(stripchars); i++) {
		if (*start == stripchars[i]) {
			start++;
			goto left;
		}
	}

	/* Right Side */
	char *end = start + strlen(start) - 1;

right:
	for (i = 0; i < strlen(stripchars); i++) {
		if (*end == stripchars[i]) {
			*end = '\0';
			--end;
			goto right;
		}
	}

	return start;
}

int main()
{
	char filename[128];
	char artist[128];
	char title[128];

	char buffer[128];

	char path[128];
	sprintf(path, "%s/.musicd/songchange.sh", getenv("HOME"));

	memset(filename, 0, 128);
	memset(artist, 0, 128);
	memset(title, 0, 128);

	while (!feof(stdin)) {
		fgets(buffer, 128, stdin);

		buffer[strlen(buffer) - 1] = '\0';

		if (!strncmp("Playing", buffer, 7)) {
			memset(filename, 0, 128);
			strncpy(filename, basename(buffer + 8), 128);
		} else if (!strncmp(" Title:", buffer, 7)) {
			memset(title, 0, 128);
			strncpy(title, buffer + 8, 128);
		} else if (!strncmp(" Artist:", buffer, 8)) {
			memset(artist, 0, 128);
			strncpy(artist, buffer + 9, 128);
		} else if (!strncmp("Starting", buffer, 8)) {
			pid_t pid;
			int rv;
			switch ((pid = fork())) {
				case -1:
					fprintf(stderr, "Could not fork\n");
					exit(1);
				case 0:
					/* Child */
					execl("/bin/sh", "sh", trim(path, " "), trim(filename, " "), trim(artist, " abcdefghijklmnopqrstuvwxyz"), trim(title, " abcdefghijklmnopqrstuvwxyz"), (char *)NULL);
					break;
				default:
					/* Parent */
					wait(&rv);
					break;
			}
		}
	}

	return 0;
}
