#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    // Get the download option using dmenu
    char *download_options[3] = {"Video", "Audio", "Video_Thumbnail"};
    char download_cmd[100];
    char video_url[100];
    char dmenu_command[100] = "echo -e '";
    for (int i = 0; i < 3; i++) {
        strcat(dmenu_command, download_options[i]);
        strcat(dmenu_command, "\\n");
    }
    strcat(dmenu_command, "' | dmenu -p 'Download Video or Audio or Thumbnails:'");
    FILE *dmenu_output = popen(dmenu_command, "r");
    if (dmenu_output == NULL) {
        printf("Error: failed to run dmenu\n");
        return 1;
    }
    fgets(download_cmd, sizeof(download_cmd), dmenu_output);
    pclose(dmenu_output);
    download_cmd[strcspn(download_cmd, "\n")] = 0;
    if (strcmp(download_cmd, "Video") == 0) {
        strcpy(download_cmd, "cd ~/Videos/ && yt-dlp -f \"bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best\" --merge-output-format mp4");
    } else if (strcmp(download_cmd, "Audio") == 0) {
        strcpy(download_cmd, "cd ~/Music/ && yt-dlp -f 140");
    } else if (strcmp(download_cmd, "Video_Thumbnail") == 0) {
        strcpy(download_cmd, "cd ~/Images/Thumbnails/ && yt-dlp --skip-download --write-thumbnail");
    }

    // Get the video URL using dmenu
    FILE *url_output = popen("echo '' | dmenu -p 'Enter URL:'", "r");
    if (url_output == NULL) {
        printf("Error: failed to run dmenu\n");
        return 1;
    }
    fgets(video_url, sizeof(video_url), url_output);
    pclose(url_output);
    video_url[strcspn(video_url, "\n")] = 0;

    // Download the video using youtube-dl
    char full_command[200];
    sprintf(full_command, "%s %s", download_cmd, video_url);
    system(full_command);
    return 0;
}
