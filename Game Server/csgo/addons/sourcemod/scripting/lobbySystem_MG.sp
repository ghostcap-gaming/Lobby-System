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
	apiRequest();
}

void redirectPlayer(char steamId[64]) {
	int client = getClientBySteamId(steamId);
	if(client > 0) {
		ServerCommand("sm_redirect %i zombies.ghostcap.com:27015", client);
	}
}

int getClientBySteamId(char steamId[64]) {
	char steamIdOfPlayer[64];
	for(int i = 1; i <= MaxClients; i++) {
		if(IsClientInGame(i) && !IsFakeClient(i)) {
			GetClientAuthId(i, AuthId_SteamID64, steamIdOfPlayer, sizeof(steamIdOfPlayer));
			if(StrEqual(steamIdOfPlayer, steamId)) {
				return i;
			}
		}
	}
	
	return 0;
}

void apiRequest() {
	httpClient = new HTTPClient("https://stats.ghostcap.com");

	JSONObject post = new JSONObject();
	
	JSONArray steamIds = new JSONArray();
	
	post.SetString	(
						"server",
						"multigame"
					);
					
	char steamId[64];
	bool send = false;
	
	for(int i = 1; i <= MaxClients; i++) {
		if(IsClientInGame(i) && !IsFakeClient(i)) {
			GetClientAuthId(i, AuthId_SteamID64, steamId, sizeof(steamId));
			steamIds.PushString(steamId);
			send = true;
		}
	}
	
	if(send) {
	
		post.Set	(
						"steamIds",
						steamIds
					);
					
		post.SetString	(
							"password",
							"GO%$(gj43wgpio54hdpomdfs;lvmesrfgoe"
						);
					
		httpClient.Post	(
							"/api/lobby.php", 
							post, 
							jsonCallbackRedirectPlayers,
							_
						);
	}
	
	delete post;
	
	delete httpClient;
}

public void jsonCallbackRedirectPlayers	(
											HTTPResponse response,
											any none
										) {
	if (response.Status != HTTPStatus_OK) {
		return;
	}

	if (response.Data == null) {
		return;
	}
	
	JSONObject steamIdsObject = view_as<JSONObject>(response.Data);
	
	bool anyData = steamIdsObject.GetBool("anyData");
	
	if(anyData) {
		char steamId[64];
		
		JSONArray steamIdsArray = view_as<JSONArray>(steamIdsObject.Get("steamIds"));
		
		for (int i = 0, j = steamIdsArray.Length; i < j; i++){
			JSONObject steamElement = view_as<JSONObject>(steamIdsArray.Get(i));
			
			steamElement.GetString	(
										"steamId", 
										steamId, 
										sizeof(steamId)
									);
			
			redirectPlayer(steamId);
			
			delete steamElement;
		}
		
		delete steamIdsArray;
	}
}	