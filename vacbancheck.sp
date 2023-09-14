#include <sourcemod>

public void OnPluginStart()
{
    HookEvent("player_activate", Event_PlayerActivate, EventHookMode_Post);

    Plugin.Author = "TannicArcher";
    Plugin.Description = "A SourceMod plugin that automatically assigns the 'VAC' tag to players with VAC bans and displays it whenever a player with a VAC ban joins the server.";
    Plugin.Version = "1.0";
}

public Action Event_PlayerActivate(Handle event, const char[] name, bool& bHandled)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    bool isVACBanned = GetEventInt(event, "vacbanned") != 0;

    if (isVACBanned)
    {
        SetClientTag(client, "VAC");
        PrintToChatAll("Player %s has joined with a VAC ban!", GetClientName(client));
    }

    return Plugin_Continue;
}
