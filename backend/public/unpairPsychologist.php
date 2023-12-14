<?php
// Připojení k databázi

include './mysql.php';

if (!isset($_POST['userId'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Chybi udaje']);
    exit;
}

$userId = $_POST['userId'];


$userQuery = "DELETE FROM messages WHERE fromUserID = ? OR toUserID = ?";
$stmt = $conn->prepare($userQuery);

if ($stmt === false) {
    http_response_code(500);
    throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
}

$stmt->bind_param("ii", $userId, $userId);

if ($stmt->execute()) {

} else {
    http_response_code(404);
    throw new \Exception("Chyba: uzivatel neexistuje");
}

$unAssignQuery = "UPDATE users SET assignedPsycho = NULL WHERE id = ?";

$stmt = $conn->prepare($unAssignQuery);

if ($stmt === false) {
    http_response_code(500);
    throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
}

$stmt->bind_param("i", $userId);

if ($stmt->execute()) {
    http_response_code(200);
    echo json_encode(['message' => 'Uspesne odebrano parovani']);
} else {
    http_response_code(404);
    throw new \Exception("Chyba: uzivatel neexistuje");
}



$stmt->close();
$conn->close();
?>
