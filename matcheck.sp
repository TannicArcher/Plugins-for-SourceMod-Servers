#include <sourcemod>
#include <filemanager>

#define FILENAME "mat_words.txt"
#define MAX_WARNINGS 3

new g_matWarnings[MaxClients+1];
new String:g_matWords[32][32];
new g_matWordsCount;

public void OnPluginStart()
{
    RegisterCommand("mat_warning", "mat_warning", ADMFLAG_GENERIC, "Warn a player for using offensive language");
    LoadMatWordsFromFile();
    
    Plugin.Author = "TannicArcher";
    Plugin.Description = "A SourceMod plugin that warns and kicks players for using offensive language.";
    Plugin.Version = "1.0";
}

public Action:mat_warning(client, args)
{
    if (!IsClientInGame(client))
        return Plugin_Handled;

    if (args.ArgC() < 2)
    {
        PrintToChat(client, "Usage: !mat_warning <nickname>");
        return Plugin_Handled;
    }

    const target = FindTargetByNick(args.Arg(1));

    if (target == 0)
    {
        PrintToChat(client, "Player not found.");
        return Plugin_Handled;
    }

    g_matWarnings[target]++;

    if (g_matWarnings[target] >= MAX_WARNINGS)
    {
        KickClient(target, "You have been kicked from the server for using offensive language.");
        g_matWarnings[target] = 0;
    }
    else
    {
        PrintToChat(target, "You have been warned for using offensive language. Warnings: %d/%d",
            g_matWarnings[target], MAX_WARNINGS);
        PrintToChat(client, "Player %s has been warned for using offensive language. Warnings: %d/%d",
            GetClientName(target), g_matWarnings[target], MAX_WARNINGS);
    }

    SaveWarningsToFile();

    return Plugin_Handled;
}

public void OnClientDisconnect(client)
{
    g_matWarnings[client] = 0;
    SaveWarningsToFile();
}

public void LoadMatWordsFromFile()
{
    FileHandle file = OpenFile(FILENAME, "rt");

    if (file == FileHandle_INVALID)
        return;

    g_matWordsCount = 0;
    char line[32];

    while (ReadLine(file, line, sizeof(line)) != -1)
    {
        if (line[0] == '/' && line[1] == '/')
            continue;

        strcopy(g_matWords[g_matWordsCount], line);
        g_matWordsCount++;
    }

    CloseFile(file);
}

public void SaveWarningsToFile()
{
    FileHandle file = OpenFile(FILENAME, "wt");

    if (file == FileHandle_INVALID)
        return;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_matWarnings[i] > 0)
        {
            FPrintF(file, "%d\n", i);
            FPrintF(file, "%d\n", g_matWarnings[i]);
        }
    }

    CloseFile(file);
}

public bool ContainsMatWord(const word[])
{
    for (int i = 0; i < g_matWordsCount; i++)
    {
        if (StrContains(word, g_matWords[i], false))
            return true;
    }

    return false;
}

public void OnClientSay(int client, int team, const String:text)
{
    if (ContainsMatWord(text))
    {
        g_matWarnings[client]++;
        
        if (g_matWarnings[client] >= MAX_WARNINGS)
        {
            KickClient(client, "You have been kicked from the server for using offensive language.");
            g_matWarnings[client] = 0;
        }
        else
        {
            PrintToChat(client, "You have been warned for using offensive language. Warnings: %d/%d",
                g_matWarnings[client], MAX_WARNINGS);
        }

        SaveWarningsToFile();
    }
}
