<?php


require 'mysql.php';


if (!isset($_POST['userId']) || !isset($_FILES['profileImg'])) {
    http_response_code(400);
    echo json_encode(['message' => 'Missing data']);
    exit;
}


$userId = $_POST['userId'];
$profileImg = $_FILES['profileImg'];

// Zkontrolovat, zda došlo k nahrání souboru bez chyb
if ($profileImg['error'] != UPLOAD_ERR_OK) {
    http_response_code(500);
    echo json_encode(['message' => 'Error uploading file']);
    exit;
}


// Vytvořit unikátní název souboru
$targetDir = "./uploads/"; // Upravte cestu k adresáři pro nahrávání
$uniqueFileName = uniqid() . basename($profileImg['name']);
$targetFile = $targetDir . $uniqueFileName;

// Přesun souboru do cílového adresáře
if (!move_uploaded_file($profileImg['tmp_name'], $targetFile)) {
    http_response_code(500);
    echo json_encode(['message' => 'Failed to move uploaded file']);
    exit;
}

$sql = "UPDATE users SET profileImg = ? WHERE id = ?";

$stmt = $conn->prepare($sql);

if ($stmt === false) {
    http_response_code(500);
    throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
}

$stmt->bind_param("si", $uniqueFileName, $userId);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        http_response_code(200);
        echo json_encode(["message" => "Profilový obrázek úspěšně nahrán"]);
    } else {
        http_response_code(404);
        echo json_encode(["message" => "Uživatel nenalezen"]);
    }
} else {
    // Zpracování chyby při vykonávání SQL dotazu
    http_response_code(500);
    echo json_encode(['message' => 'Server error: ' . $stmt->error]);
}