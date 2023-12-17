<?php
// Připojení k databázi

use function App\getUserId;

include './mysql.php';

if (!isset($_GET['userId'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Chybějící údaje']);
    exit;
}

$userId = $_GET['userId'];

try {
    $selectQuery = "SELECT notificationTime FROM users WHERE id = ?";
    $selectStmt = $conn->prepare($selectQuery);
    
    if ($selectStmt === false) {
        throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
    }
    
    $selectStmt->bind_param("i", $userId);
    $selectStmt->execute();

    $result = $selectStmt->get_result();

    http_response_code(200);
    echo json_encode($result->fetch_assoc());
    exit;
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['error' => 'Error: ' . $e->getMessage()]);
}




$stmt->close();
$conn->close();
?>
