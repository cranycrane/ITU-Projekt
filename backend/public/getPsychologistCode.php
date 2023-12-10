<?php
// Připojení k databázi

use function App\getUserId;

include './mysql.php';

function generatePairingCode() {
    $characters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $codeLength = 5;
    $code = '';

    for ($i = 0; $i < $codeLength; $i++) {
        $code .= $characters[mt_rand(0, strlen($characters) - 1)];
    }

    return $code;
}


if (!isset($_GET['userId'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing userId']);
    return;
}

// Případné získání Creator_ID z GET požadavku
$userId = $_GET['userId'];
try {

    $query = "SELECT assignedPsycho FROM users WHERE id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("s", $userId);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();
    
    if (!empty($row['assignedPsycho'])) {
        // Uživatel již má přiděleného psychologa
        http_response_code(200);
        echo json_encode(['hasPsychologist' => true]);
        exit;
    }

    $pairingCode = generatePairingCode();

    $sql = "UPDATE users SET pairingCode = ? WHERE id = ?";
    $stmt = $conn->prepare($sql);
    if ($stmt === false) {
        // Zde byste měli zpracovat chybu
        throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
    }

    $stmt->bind_param("ss", $pairingCode, $userId);

    // Výkon dotazu
    if ($stmt->execute()) {
        http_response_code(200);
        echo json_encode(['hasPsychologist' => false, "pairingCode" => $pairingCode]);
    } else {
        http_response_code(400);
        echo "Chyba: " . $stmt->error;
    }

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['error' => 'Error: ' . $e->getMessage()]);
}

$stmt->close();
$conn->close();
?>
