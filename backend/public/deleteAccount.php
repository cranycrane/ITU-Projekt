<?php
// Připojení k databázi

include './mysql.php';

if (!isset($_GET['userId'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Chybi udaje']);
    exit;
}

$userId = $_GET['userId'];

try {
    $userQuery = "DELETE FROM messages WHERE fromUserID = ? OR toUserID = ?";
    $stmt = $conn->prepare($userQuery);

    if ($stmt === false) {
        http_response_code(500);
        throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
    }

    $stmt->bind_param("ii", $userId, $userId);

    if ($stmt->execute()) {

    } else {
        http_response_code(400);
        throw new \Exception("Chyba pri mazani zprav uzivatele");
    }

    $removeDiary = "DELETE FROM diary WHERE userId = ?";

    $stmt = $conn->prepare($removeDiary);

    if ($stmt === false) {
        http_response_code(500);
        throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
    }

    $stmt->bind_param("i", $userId);

    if ($stmt->execute()) {

    } else {
        http_response_code(400);
        throw new \Exception("Chyba pri mazani zaznamu uzivatele");
    }

    $unAssign = "UPDATE users SET assignedPsycho = NULL WHERE assignedPsycho = ?";

    $stmt->bind_param("i", $userId);

    if ($stmt->execute()) {

    } else {
        http_response_code(400);
        throw new \Exception("Chyba pri odebirani parovani");
    }

    $removeUser = "UPDATE users SET assignedPsycho = NULL, firstName = NULL, lastName = NULL, profileImg = NULL, firstSignIn = ? WHERE id = ?";

    $stmt = $conn->prepare($removeUser);

    if ($stmt === false) {
        http_response_code(500);
        throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
    }
    $firstSignIn = new \DateTime();
    $firstSignInFormatted = $firstSignIn->format('Y-m-d');

    $stmt->bind_param("si", $firstSignInFormatted ,$userId);

    if ($stmt->execute()) {
        http_response_code(200);
        echo json_encode(['message' => 'Uzivatel uspesne odebran']);
    } else {
        http_response_code(400);
        throw new \Exception("Chyba pri odebrani parovani uzivatele");
    }


} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['error' => 'Error: ' . $e->getMessage()]);
}



?>
