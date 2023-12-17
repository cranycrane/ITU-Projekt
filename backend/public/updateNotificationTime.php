<?php
// Připojení k databázi

use function App\getUserId;

include './mysql.php';

if (!isset($_POST['userId'], $_POST['notificationTime'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Chybějící údaje']);
    exit;
}

$userId = $_POST['userId'];
$notificationTime = $_POST['notificationTime'];

try {
    $updateQuery = "UPDATE users SET notificationTime = ? WHERE id = ?";
    $updateStmt = $conn->prepare($updateQuery);
    
    if ($updateStmt === false) {
        throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
    }
    
    $updateStmt->bind_param("ss", $notificationTime, $userId);
    $updateStmt->execute();
    
    http_response_code(200);
    echo json_encode(['success' => 'Čas aktualizace úspěšně aktualizován']);
    exit;
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['error' => 'Error: ' . $e->getMessage()]);
}




$stmt->close();
$conn->close();
?>
