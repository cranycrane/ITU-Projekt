<?php
// Připojení k databázi

use function App\getUserId;

include './mysql.php';



if (!isset($_GET['psychologistId'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing psychologistId']);
    exit;
}

// Případné získání Creator_ID z GET požadavku
$psychologistId = $_GET['psychologistId'];
try {

    $sql = "SELECT id, firstName, lastName, profileImg FROM users WHERE assignedPsycho = ?";

    $stmt = $conn->prepare($sql);
    if ($stmt === false) {
        // Zde byste měli zpracovat chybu
        throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
    }

    $stmt->bind_param("s", $psychologistId);

    // Výkon dotazu
    if ($stmt->execute()) {
        $result = $stmt->get_result();
        $clients = [];
    
        while ($row = $result->fetch_assoc()) {
            // Dotaz na poslední záznam
            $lastRecordStmt = $conn->prepare("SELECT date FROM diary WHERE userId = ? ORDER BY date DESC LIMIT 1");
            $lastRecordStmt->bind_param("s", $row['id']);
            $lastRecordStmt->execute();
            $lastRecordResult = $lastRecordStmt->get_result();
            $lastRecordRow = $lastRecordResult->fetch_assoc();
    
            $clients[] = [
                'userId' => $row['id'],
                'firstName' => $row['firstName'],
                'lastName' => $row['lastName'],
                'profileImagePath' => $row['profileImg'],
                'lastRecordDate' => $lastRecordRow ? $lastRecordRow['date'] : null
            ];
        }

        http_response_code(200);
        echo json_encode($clients);

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
