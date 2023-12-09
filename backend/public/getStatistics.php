<?php

require 'mysql.php';

if (!isset($_GET['userId'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing userId']);
    exit;
}

$userId = $_GET['userId'];

try {
    // Počet záznamů
    $countQuery = "SELECT COUNT(*) FROM diary WHERE userId = ?";
    $countStmt = $conn->prepare($countQuery);
    $countStmt->bind_param("s", $userId);
    $countStmt->execute();
    $countResult = $countStmt->get_result();
    $totalCount = $countResult->fetch_row()[0];

    // Průměrný počet slov na záznam
    $avgWordsQuery = "SELECT AVG(LENGTH(record1) - LENGTH(REPLACE(record1, ' ', '')) + LENGTH(record2) - LENGTH(REPLACE(record2, ' ', '')) + LENGTH(record3) - LENGTH(REPLACE(record3, ' ', '')) + CASE WHEN record1 <> '' THEN 1 ELSE 0 END + CASE WHEN record2 <> '' THEN 1 ELSE 0 END + CASE WHEN record3 <> '' THEN 1 ELSE 0 END) as avgWords FROM diary WHERE userId = ?";
    $avgWordsStmt = $conn->prepare($avgWordsQuery);
    $avgWordsStmt->bind_param("s", $userId);
    $avgWordsStmt->execute();
    $avgWordsResult = $avgWordsStmt->get_result();
    $avgWords = $avgWordsResult->fetch_assoc()['avgWords'];

    // Průměrný počet slov na záznam
    $totalWordsQuery = "SELECT SUM(LENGTH(record1) - LENGTH(REPLACE(record1, ' ', '')) + LENGTH(record2) - LENGTH(REPLACE(record2, ' ', '')) + LENGTH(record3) - LENGTH(REPLACE(record3, ' ', '')) + CASE WHEN record1 <> '' THEN 1 ELSE 0 END + CASE WHEN record2 <> '' THEN 1 ELSE 0 END + CASE WHEN record3 <> '' THEN 1 ELSE 0 END) as totalWords FROM diary WHERE userId = ?";
    $totalWordsStmt = $conn->prepare($totalWordsQuery);
    $totalWordsStmt->bind_param("s", $userId);
    $totalWordsStmt->execute();
    $totalWordsResult = $totalWordsStmt->get_result();
    $totalWords = $totalWordsResult->fetch_assoc()['totalWords'];

    // Nejdelší záznam podle počtu slov
    $longestEntryQuery = "SELECT MAX(LENGTH(record1) - LENGTH(REPLACE(record1, ' ', '')) + LENGTH(record2) - LENGTH(REPLACE(record2, ' ', '')) + LENGTH(record3) - LENGTH(REPLACE(record3, ' ', '')) + CASE WHEN record1 <> '' THEN 1 ELSE 0 END + CASE WHEN record2 <> '' THEN 1 ELSE 0 END + CASE WHEN record3 <> '' THEN 1 ELSE 0 END) as maxWordCount FROM diary WHERE userId = ?";
    $longestEntryStmt = $conn->prepare($longestEntryQuery);
    $longestEntryStmt->bind_param("s", $userId);
    $longestEntryStmt->execute();
    $longestEntryResult = $longestEntryStmt->get_result();
    $longestEntryWordCount = $longestEntryResult->fetch_assoc()['maxWordCount'];

    // Získání data registrace uživatele
    $regDateQuery = "SELECT firstSignIn FROM users WHERE id = ?";
    $regDateStmt = $conn->prepare($regDateQuery);
    $regDateStmt->bind_param("s", $userId);
    $regDateStmt->execute();
    $regDateResult = $regDateStmt->get_result();
    $registrationDate = new DateTime($regDateResult->fetch_assoc()['firstSignIn']);

    // Získání dnešního data
    $currentDate = new DateTime();

    // Výpočet celkového počtu dnů od registrace
    $interval = $registrationDate->diff($currentDate);
    $totalDays = $interval->days;

    // Výpočet počtu vyplněných dnů
    $filledDaysQuery = "SELECT COUNT(DISTINCT date) FROM diary WHERE userId = ?";
    $filledDaysStmt = $conn->prepare($filledDaysQuery);
    $filledDaysStmt->bind_param("s", $userId);
    $filledDaysStmt->execute();
    $filledDaysResult = $filledDaysStmt->get_result();
    $filledDaysCount = $filledDaysResult->fetch_row()[0];

    // Výpočet počtu nevyplněných dnů
    $unfilledDaysCount = $totalDays - $filledDaysCount;

    // Vytvoření výsledkového pole
    $stats = [
        'totalDays' => $totalDays,
        'filledDays' => $filledDaysCount,
        'unfilledDays' => $unfilledDaysCount,
        'averageWordsPerEntry' => round($avgWords),
        'totalWords' => round($totalWords),
        'longestEntryLength' => $longestEntryWordCount
    ];

    http_response_code(200);
    echo json_encode($stats);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Server error']);
}
?>
