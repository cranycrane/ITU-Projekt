<?php
// Připojení k databázi
include './mysql.php';

// Přijetí POST dat
$id = $_POST['id'];
$creator_id = $_POST['creatorId'];
$record1 = $_POST['record1'];
$record2 = $_POST['record2'];
$record3 = $_POST['record3'];
$score = $_POST['score'];

// SQL dotaz pro aktualizaci dat
$sql = "UPDATE diary SET record1 = ?, record2 = ?, record3 = ?, score = ? WHERE id = ? AND creatorId = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sssiii", $record1, $record2, $record3, $score, $id, $creator_id);

// Výkon dotazu
if ($stmt->execute()) {
    echo "Záznam byl aktualizován";
} else {
    echo "Chyba: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>
