<?php


require './mysql.php';


if (!isset($_GET['userId'])) {
    http_response_code(400);
    echo json_encode(['message' => 'Missing data']);
}

$userId = $_GET['userId'];

$sql = "SELECT * FROM users WHERE id = ?";

$stmt = $conn->prepare($sql);

if ($stmt === false) {
    // Zde byste měli zpracovat chybu
    throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
}

$stmt->bind_param("i", $userId);

if ($stmt->execute()) {
    $result = $stmt->get_result();
    if ($user = $result->fetch_assoc()) {
        $imagePath = "./uploads/" . $user['profileImg'];
        if ($user['profileImg'] != null and file_exists($imagePath)) {
            $imageData = base64_encode(file_get_contents($imagePath));
            $user['profileImg'] = 'data:image/jpeg;base64,' . $imageData;
        } else {
            $user['profileImg'] = null; // Není-li obrázek nalezen
        }
        http_response_code(200);
        $user['hasPsychologist'] = $user['assignedPsycho'] == null ? false : true;
        echo json_encode($user);
    } else {
        http_response_code(404);
        echo json_encode(['message' => 'User not found']);
    }
} else {
    http_response_code(500);
    echo json_encode(['message' => 'Server error: ' . $stmt->error]);
}