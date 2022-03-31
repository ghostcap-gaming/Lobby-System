#include <artourdev>
#include <ripext>

HTTPClient httpClient;

public Plugin:myinfo = 
{
	name = "CS:GO MULTIGAME LOBBY SYSTEM",
	author = artourdev_author,
	version = artourdev_version,
	url = artourdev_url
};

public OnPluginStart() {
	CreateTimer(60.0, timerCheckPlayers, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public Action timerCheckPlayers(Handle timer) {
	int players = countPlayers();
	if(50 < players < 62) {
		apiRequest("timer", "", 64-players);
	}
}

public OnClientPutInServer(int client) {
	if(countPlayers() > 62) {
		char steamId[64];
		GetClientAuthId(client, AuthId_SteamID64, steamId, sizeof(steamId));
		apiRequest("connect", steamId, 0);
		redirectPlayer(client);
	}
}

int countPlayers() {
	int playersOnServer = 0;
	for(int i = 1; i <= MaxClients; i++) {
		if(IsClientInGame(i) && IsClientConnected(i)) {
			playersOnServer++;
		}
	}
	
	return playersOnServer;
}

void redirectPlayer(int client) {
	ServerCommand("sm_redirect %i 51.79.162.166:25571", client);
}

void apiRequest(char[] type, char steamId[64] = "", int slots = 0) {
	httpClient = new HTTPClient("https://stats.ghostcap.com");

	JSONObject post = new JSONObject();
	
	post.SetString	(
						"server",
						"zombie"
					);
					
	post.SetString	(
						"action",
						type
					);
					
	post.SetString	(
						"password",
						"GO%$(gj43wgpio54hdpomdfs;lvmesrfgoe"
					);

	if(StrEqual(type, "timer")) {
		post.SetInt	(
						"slots",
						slots
					);
	}
	
	else if(StrEqual(type, "connect")) {
		post.SetString	(
							"steamId",
							steamId
						);
	}

	httpClient.Post	(
						"/api/lobby.php", 
						post, 
						jsonCallbackNoReturn,
						_
					);	
	
	delete post;
	
	delete httpClient;
}

public void jsonCallbackNoReturn	(
										HTTPResponse response,
										any none
									)
{
	if (response.Status != HTTPStatus_OK) {
		return;
	}

	if (response.Data == null) {
		return;
	}
}