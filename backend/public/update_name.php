<?php


require 'mysql.php';


if (!isset($_POST['userId'], $_POST['firstName'], $_POST['lastName'])) {
    http_response_code(400);
    echo json_encode(['message' => 'Missing data']);
}

$userId = $_POST['userId'];
$firstName = $_POST['firstName'];
$lastName = $_POST['lastName'];


$sql = "UPDATE users SET firstName = ?, lastName = ? WHERE id = ?";

$stmt = $conn->prepare($sql);

if ($stmt === false) {
    // Zde byste měli zpracovat chybu
    throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
}

$stmt->bind_param("ssi", $firstName, $lastName, $userId);

if ($stmt->execute()) {
    http_response_code(200);
    echo json_encode(["message" => "Zaznam uzivatele uspesne aktualizovan"]);
}
else {
    http_response_code(400);
    throw new \Exception('Chyba při provádění SQL dotazu: ' . $stmt->error);
}
