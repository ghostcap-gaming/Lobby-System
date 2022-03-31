<?php

## DATABASE DATA ##
$dbIp = 'ENTERYOURDETAILS';
$dbName = 'ENTERYOURDETAILS';
$dbUser = 'ENTERYOURDETAILS';
$dbPass = 'ENTERYOURDETAILS';
## END OF DB DATA ##

## DON'T EDIT ANYTHING BELOW THIS LINE ##
## ----------------------------------- ##

$data = file_get_contents('php://input');
$data = (!empty($data)) ? json_decode($data, TRUE) : $_POST;


$dbh = new PDO('mysql:host=' . $dbIp. ';dbname=' . $dbName, $dbUser, $dbPass);
$query = $dbh->prepare("SET NAMES UTF8");
$query->execute();

#TESTLOG
$query = $dbh->prepare("INSERT INTO debug (time, message) VALUES (?, ?)");
$query->execute([time(), "POST: [" . json_encode($_POST) . "]"]);

if(isset($data['password']) && $data['password'] === 'GO%$(gj43wgpio54hdpomdfs;lvmesrfgoe') {
	if(isset($data['server'])) {
		if($data['server'] === 'zombie' && isset($data['action'])) {
			if($data['action'] === 'connect' && isset($data['steamId'])) {
				$dbh->prepare("DELETE FROM queue WHERE steam_id = ? AND unix_timestamp(FROM_UNIXTIME(join_time, '%Y-%m-%d')) = unix_timestamp(CURDATE())")->execute([$data['steamId']]);
				$dbh->prepare("INSERT INTO queue (steam_id, join_time) VALUES (?, ?)")->execute([$data['steamId'], time()]);
				print json_encode(['ok']);
				exit;
			}
			elseif($data['action'] === 'timer' && isset($data['slots'])) {
				$slots = (int)$data['slots'];
				if($slots > 0) {
					$dbh->prepare("UPDATE queue SET flag = 1, back_time = ? WHERE flag = 0 ORDER BY id ASC LIMIT " . $slots)->execute([time()]);
				}
				print json_encode(['ok']);
				exit;
			}
		}
		elseif($data['server'] === 'multigame' && isset($data['steamIds']) && is_array($data['steamIds']) && !empty($data['steamIds'])) {
			$sqlIn = '';
			$sqlArray = [];
			$result['anyData'] = FALSE;
			
			foreach($data['steamIds'] AS $steamId) {
				$sqlIn .= '?,';
				$sqlArray[] = $steamId;
			}
			$sqlIn = substr($sqlIn, 0, -1);
			
			$query = $dbh->prepare("SELECT steam_id FROM queue WHERE flag = 1 AND steam_id IN ($sqlIn) ORDER BY id ASC");
			$query->execute($sqlArray);
			while($steamIdFromDB = $query->fetch()) {
				$result['steamIds'][] = [
					'steamId' => $steamIdFromDB['steam_id'],
				];
				$result['anyData'] = TRUE;
			}
			print json_encode($result);
			exit;
		}
	}
}