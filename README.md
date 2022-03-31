# Lobby-System
A REST Sourcemod lobby system that will queue players before they enter your main server.

# History And Usecase
This was made with the intention of having one CSGO lobby server where players would first connect to before being teleported to your main CSGO server. If the main server was full, the player would join a queue and remain in the lobby until a slot was available. Think of Planetside 2 and their queue system before you enter the actual server. This was supposed to be a work around for the 64 player limit on servers. 

We ran into some problems that we were unable to overcome so we decided to abandon the project.

If you make something with this, we would love to hear about your project!

# Requirements
* Web server
* MYSQL
* Sourcemod
* REST in Pawn Extension on your servers

# Setup

Please remember, this is in alpha 0.001 version. But you can still check it out if you wish. I may have missed some things as this project is years old at this point. 

1. Run SQL query in your MYSQL database:

```
CREATE TABLE `queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `steam_id` varchar(64) DEFAULT NULL,
  `join_time` int(11) DEFAULT NULL COMMENT 'Time when player joined queue',
  `back_time` int(11) DEFAULT NULL COMMENT 'Time when player redirected back from lobby to zombie',
  `flag` int(1) DEFAULT '0' COMMENT 'Flag if player has queued',
  PRIMARY KEY (`id`),
  KEY `IDX_STEAM_ID` (`steam_id`),
  KEY `IDX_JOIN_TIME` (`join_time`),
  KEY `IDX_BACK_TIME` (`back_time`),
  KEY `IDX_FLAG` (`flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

2. Put lobby.php file into the 'api' folder in stats.ghostcap.com domain (so script can be reached by HTTP REQUEST at https://stats.ghostcap.com/api/lobby.php).

3. Upload all files from archive to both gameservers (ZE & MG) except the .smx plugin contained server name:
3.1 Upload lobbySystem_MG.smx only to Multigame server
3.2 Upload lobbySystem_ZE.smx only to Zombie Escape server

4. Restart both servers. You are done! :)
