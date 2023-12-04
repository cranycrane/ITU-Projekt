<?php
// Připojení k databázi

use function App\getUserId;

include './MySQL.php';

// Přijetí ID záznamu
$id = $_GET['id'] ?? null;
$deviceId = $_GET['deviceId'] ?? null;

if (is_null($id)) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing id']);
    exit;
}
else if (is_null($deviceId)) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing deviceId']);
    exit;
}

$userId = getUserId($deviceId, $conn);

$sql = "DELETE FROM diary WHERE id = ? AND userId = ?";
$stmt = $conn->prepare($sql);

if ($stmt === false) {
    // Zde byste měli zpracovat chybu
    throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
}

$stmt->bind_param("ss", $id, $userId);

if ($stmt->execute()) {
    $result = $stmt->affected_rows > 0;
} else {
    $result = false;
}

if ($result) {
    http_response_code(200);
    echo json_encode(['message' => 'Zaznam uspesne smazan']);
}
else {
    http_response_code(400);
    throw new \Exception("Chyba: zaznam neexistuje");
}


$stmt->close();
$conn->close();