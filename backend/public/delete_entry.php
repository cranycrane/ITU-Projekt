<?php
// Připojení k databázi

use function App\getUserId;

include './mysql.php';

if (!isset($_GET['userId'], $_GET['date'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing dataaa']);
    error_log("Received data: " . print_r($_POST, true), 3, "./log.txt");
    return;
}

// Přijetí ID záznamu
$userId = $_GET['userId'] ?? null;
$date = $_GET['date'] ?? null;

$sql = "DELETE FROM diary WHERE userId = ? AND date = ?";
$stmt = $conn->prepare($sql);

if ($stmt === false) {
    // Zde byste měli zpracovat chybu
    throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
}

$stmt->bind_param("ss", $userId, $date);

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