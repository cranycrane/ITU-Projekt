<?php
include './mysql.php';

if (!isset($_POST['fromUserID']) || !isset($_POST['toUserID']) || !isset($_POST['messageText'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing required fields']);
    exit;
}

$fromUserID = $_POST['fromUserID'];
$toUserID = $_POST['toUserID'];
$messageText = $_POST['messageText'];

$sql = "INSERT INTO messages (fromUserID, toUserID, messageText) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
if ($stmt === false) {
    // Zpracování chyby
    http_response_code(500);
    echo json_encode(['error' => 'Server error: ' . $conn->error]);
    exit;
}

$stmt->bind_param("iis", $fromUserID, $toUserID, $messageText);
if ($stmt->execute()) {
    http_response_code(200);
    echo json_encode(['message' => 'Message sent successfully']);
} else {
    // Zpracování chyby
    http_response_code(500);
    echo json_encode(['error' => 'Failed to send message']);
}

$stmt->close();
$conn->close();
?>
