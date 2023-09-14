#include <sourcemod>

const char YOUTUBE_URL[] = "https://www.youtube.com/watch?v=dQw4w9WgXcQ";

public Plugin myinfo = {
    name = "FunnyBanned",
    author = "TannicArcher",
    description = "Funny banned player",
    url = "https://github.com/TannicArcher"
};

public void OnClientAuthorized(int client)
{
    const char[] game = GetClientGame(client);

    if (StrEqual(game, "csgo", true) || StrEqual(game, "css", true) || StrEqual(game, "left4dead2", true))
    {
        if (IsClientInGame(client) && IsClientBanned(client))
        {
            SetClientConVarString(client, "cl_disablehtmlmotd", "1");
            SetClientConVarString(client, "cl_disablehtmlfullscreen", "1");
            SetClientConVarString(client, "motd_url", YOUTUBE_URL);
        }
    }
}
