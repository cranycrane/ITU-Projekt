<?php

namespace App;

function getUserId(string $deviceId, \mysqli $conn): string {
    $sql = "SELECT id FROM users WHERE deviceId = ?";
    $stmt = $conn->prepare($sql);

    if ($stmt === false) {
        throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
    }

    $stmt->bind_param("s", $deviceId);

    if ($stmt->execute()) {
        $result = $stmt->get_result();
        $user = $result->fetch_assoc();

        if ($user) {
            return $user['id'];
        } else {
            // Uživatel nenalezen, vytvoření nového uživatele
            $insertSql = "INSERT INTO users (deviceId) VALUES (?)";
            $insertStmt = $conn->prepare($insertSql);

            if ($insertStmt === false) {
                throw new \Exception('Chyba při přípravě SQL dotazu pro vložení: ' . $conn->error);
            }

            $insertStmt->bind_param("s", $deviceId);

            if ($insertStmt->execute()) {
                // Vrácení ID nově vytvořeného uživatele
                return $conn->insert_id;
            } else {
                throw new \Exception('Chyba při vkládání nového uživatele: ' . $insertStmt->error);
            }
        }
    } else {
        throw new \Exception('Chyba při vykonání SQL dotazu: ' . $stmt->error);
    }
}


function findDay(string $userId, string $date, \mysqli $conn): array {
    
    if (!\DateTime::createFromFormat('Y-m-d', $date)) {
        throw new \Exception('Neplatný formát data');
    }
    
    // Kontrola, zda již záznam existuje
    $sql = "SELECT * FROM diary WHERE userId = ? AND date = ?";
    $stmt = $conn->prepare($sql);
    if ($stmt === false) {
        // Zde byste měli zpracovat chybu
        throw new \Exception('Chyba při přípravě SQL dotazu: ' . $conn->error);
    }
    $stmt->bind_param("ss", $userId, $date);
    $stmt->execute();

    $result = $stmt->get_result();

    if ($result->num_rows == 1) {
        // Záznam pro daného uživatele a datum již existuje
        return $result->fetch_assoc();
    } else if ($result->num_rows > 0){
        throw new \Exception('Chyba: Existuje vice zaznamu pro jeden den a uzivatele');
    }
    else {
        return [];
    }
}




// Parametry připojení k databázi
$servername = "db"; // Adresa serveru, obvykle localhost pro lokální vývoj
$username = "cranycrane"; // Uživatelské jméno pro MySQL
$password = "cranycrane"; // Heslo pro MySQL
$dbname = "diary"; // Název vaší databáze

// Vytvoření připojení k databázi
$conn = new \mysqli($servername, $username, $password, $dbname, 3306);

// Kontrola připojení
if ($conn->connect_error) {
    die("Připojení selhalo: " . $conn->connect_error);
}

// Nastavení kódování pro správnou komunikaci s databází
$conn->set_charset("utf8");

// Tento skript nyní můžete vkládat do vašich ostatních PHP skriptů, které vyžadují připojení k databázi
?>
