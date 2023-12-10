<?php
// Připojení k databázi

use function App\getUserId;

include './mysql.php';

if (!isset($_POST['psychologistId'], $_POST['pairingCode'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Chybějící údaje']);
    exit;
}

$psychologistId = $_POST['psychologistId'];
$pairingCode = $_POST['pairingCode'];

// Najdeme uživatele s daným párovacím kódem
$userQuery = "SELECT id FROM users WHERE pairingCode = ?";
$stmt = $conn->prepare($userQuery);
$stmt->bind_param("s", $pairingCode);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    // Aktualizujeme přiřazení psychologa
    $userId = $result->fetch_assoc()['id'];
    $updateQuery = "UPDATE users SET assignedPsycho = ? WHERE id = ?";
    $updateStmt = $conn->prepare($updateQuery);

    if ($updateStmt === false) {
        throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
    }

    $updateStmt->bind_param("ss", $psychologistId, $userId);
    $updateStmt->execute();

    http_response_code(200);
    echo json_encode(['success' => 'Psycholog byl úspěšně přiřazen']);
} else {
    http_response_code(404);
    echo json_encode(['error' => 'Nenalezen žádný uživatel s daným kódem']);
}



$stmt->close();
$conn->close();
?>
