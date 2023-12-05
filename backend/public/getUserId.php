<?php

namespace App;

use Exception;

require 'mysql.php';

if (!isset($_POST['deviceId'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing deviceId']);
    exit;
}

$deviceId = $_POST['deviceId'];

try {
    $userId = getUserId($deviceId, $conn);
}
catch (Exception) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing deviceId']); 
}

http_response_code(200);
echo json_encode(['userId' => $userId]);