<?php
// Připojení k databázi

use function App\findDay;
use function App\getUserId;

require './mysql.php';


if (!isset($_POST['userId'], $_POST['date'], $_POST['record1'], $_POST['record2'], $_POST['record3'], $_POST['score'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing data']);
    error_log("Received data: " . print_r($_POST, true), 3, "./log.txt");
    return;
}

// Přijetí POST dat
$userId = $_POST['userId'];
$date = $_POST['date'];
$record1 = $_POST['record1'];
$record2 = $_POST['record2'];
$record3 = $_POST['record3'];
$score = $_POST['score'];

// Zkontrolujeme, zda zaznam pro dany den a uzivatele jiz neexistuje
$result = findDay($userId, $date, $conn);

if ($result) {
    // Záznam existuje, provedeme update
    $sql = "UPDATE diary SET record1 = ?, record2 = ?, record3 = ?, score = ? WHERE userId = ? AND date = ?";
    $stmt = $conn->prepare($sql);
    if ($stmt === false) {
        // Zde byste měli zpracovat chybu
        throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
    }
    $stmt->bind_param("sssiss", $record1, $record2, $record3, $score, $userId, $date);
}
else {
    // SQL dotaz pro vložení dat
    $sql = "INSERT INTO diary (userId, date, record1, record2, record3, score) VALUES (?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    
    if ($stmt === false) {
        throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
    }
    $stmt->bind_param("sssssi", $userId, $date, $record1, $record2, $record3, $score);
}


// Výkon dotazu
if ($stmt->execute()) {
    http_response_code(200);
    echo "Záznam byl úspěšně vytvořen";
} else {
    http_response_code(400);
    echo "Chyba: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>