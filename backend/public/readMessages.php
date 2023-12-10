<?php
include './mysql.php';

if (!isset($_GET['userID'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing userID']);
    exit;
}

$userID = $_GET['userID'];

$sql = "SELECT * FROM messages WHERE toUserID = ? OR fromUserID = ? ORDER BY timestamp DESC";
$stmt = $conn->prepare($sql);
if ($stmt === false) {
    // Zpracování chyby
    http_response_code(500);
    echo json_encode(['error' => 'Server error: ' . $conn->error]);
    exit;
}

$stmt->bind_param("ii", $userID, $userID);
if ($stmt->execute()) {
    $result = $stmt->get_result();
    $messages = [];
    while ($row = $result->fetch_assoc()) {
        $messages[] = $row;
    }

    http_response_code(200);
    echo json_encode($messages);
} else {
    // Zpracování chyby
    http_response_code(500);
    echo json_encode(['error' => 'Failed to retrieve messages']);
}

$stmt->close();
$conn->close();
?>
