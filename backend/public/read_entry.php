<?php
// Připojení k databázi

use function App\getUserId;

include './MySQL.php';

if (!isset($_GET['deviceId'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing data']);
    return;
}

// Případné získání Creator_ID z GET požadavku
$deviceId = $_GET['deviceId'];

$userId = getUserId($deviceId, $conn);

// SQL dotaz pro načtení dat
if (isset($_GET['date'])) {
    $date = $_GET['date'];
    if (!DateTime::createFromFormat('Y-m-d', $date)) {
        throw new \Exception('Neplatný formát data');
    }

    $sql = "SELECT * FROM diary WHERE userId = ? AND date = ?";
    $stmt = $conn->prepare($sql);
    if ($stmt === false) {
        // Zde byste měli zpracovat chybu
        throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
    }
    $stmt->bind_param("ss", $userId, $date);
}
else {
    $sql = "SELECT * FROM diary WHERE userId = ?";
    $stmt = $conn->prepare($sql);
    if ($stmt === false) {
        // Zde byste měli zpracovat chybu
        throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
    }
    $stmt->bind_param("s", $userId);
}


$stmt->execute();
$result = $stmt->get_result();

$entries = array();
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $entries[] = $row;
    }
} 

echo json_encode($entries);

$stmt->close();
$conn->close();
?>
