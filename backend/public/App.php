<?php
declare(strict_types=1);


function printTasks() {
  require 'mysql.php';
  // Dotaz SELECT
    $sql = "SELECT * FROM tasks";
    $result = mysqli_query($conn, $sql);

    // Zpracování výsledků
    // Zpracování výsledků
if (mysqli_num_rows($result) > 0) {
  while ($row = mysqli_fetch_assoc($result)) {
    echo "<tr>";
    echo "<td>" . $row["date"] . "</td>";
    echo "<td>";
    
    // Tlačítko "Upravit"
    echo "<form method='post'>";
    echo "<input type='hidden' name='task_id' value='" . $row["id"] . "'>";

    if (isset($_POST['edit_task']) && $_POST['task_id'] === $row["id"]) {
      // Zobrazení textového pole pro úpravu názvu úkolu
      echo "<input type='text' name='edited_task_name' value='" . $row["name"] . "'>";
    } else {
      echo $row["name"];
    }
    
    echo "</td>";
    echo "<td>" . $row["state"] . "</td>";
    echo "<td>";

    if ($row["state"] === 'nedokonceno') {
      echo "<input type='submit' name='change_state' value='Dokončit'>";
      if (isset($_POST['change_state']) && $_POST['task_id'] === $row["id"]) {
        $taskId = $row["id"];
        $newState = 'dokonceno'; // Nový stav úkolu
    
        // Zde předpokládáme, že již máte připojení k databázi v proměnné $conn
        changeTaskState($conn, $taskId, $newState);
      }
    }

    echo "</td>";

    // Tlačítko "Upravit"
    echo "<td>";
    
    if (isset($_POST['edit_task']) && $_POST['task_id'] === $row["id"]) {
      echo "<input type='submit' name='save_task' value='Uložit'>";
    } else {
      echo "<input type='submit' name='edit_task' value='Upravit'>";
    }

    
    if (isset($_POST['save_task']) && $_POST['task_id'] === $row["id"]) {
      $editedTaskName = $_POST['edited_task_name'];
      // Zde provedete aktualizaci názvu úkolu v databázi pomocí funkce changeTaskName()
      changeTaskName($conn, $row["id"], $editedTaskName);
    }

    echo "</td>";
    
    // Tlacitko "Smazat"
    echo "<td>";
    echo "<input type='submit' name='remove_task' value='Smazat'>";
    if (isset($_POST['remove_task']) && $_POST['task_id'] === $row["id"]) {
      removeTask($conn, $row["id"]);
    }
    echo "</form>";
    echo "</td>";
    echo "</tr>";
  }
    }
     else {
      echo "Žádné záznamy nebyly nalezeny.";
    }
    mysqli_close($conn);
}

function addTask($taskname, $taskstate) {
  require 'mysql.php';
  // Dotaz SELECT
    $sql = "INSERT INTO tasks (date, name, state) VALUES(CURDATE(), '$taskname', '$taskstate');";

    if (mysqli_query($conn, $sql)) {
      echo "Záznam byl úspešně přidán.";
      header("Location: index.php");
      exit();
    }
    else {
      echo "Chyba při přidávání záznamu: " . mysqli_error($conn);
    }
    mysqli_close($conn);
}

// Funkce pro zpracování změny stavu úkolu
function changeTaskState($conn, $taskId, $newState) {
  $sqlUpdate = "UPDATE tasks SET state = ? WHERE id = ?";

  $stmt = $conn->prepare($sqlUpdate);
  $stmt->bind_param("si", $newState, $taskId);
  if ($stmt->execute()) {
    echo "Stav úkolu byl změněn na $newState";
    header("Location: index.php");
    exit();
  } else {
    echo "Chyba při aktualizaci záznamu: " . $stmt->error;
  }
}

function changeTaskName($conn, $taskid, $editedTaskName) {
  $sqlUpdate = "UPDATE tasks SET name = ? WHERE id = ?";

  $stmt = $conn->prepare($sqlUpdate);
  $stmt->bind_param("si", $editedTaskName, $taskid);
  if ($stmt->execute()) {
    echo "Nazev ukolu zmenen na $editedTaskName";
    header("Location: index.php");
    exit();
  } else {
    echo "Chyba při aktualizaci záznamu: " . $stmt->error;
  }
}

function removeTask($conn, $taskid) {
  $sqlRemove = "DELETE FROM tasks WHERE id = ?";

  $stmt = $conn->prepare($sqlRemove);
  $stmt->bind_param("i", $taskid);
  if ($stmt->execute()) {
    echo "OK";
    header("Location: index.php");
    exit();
  }
  else {
    echo "Ukol se nepodarilo smazat.";
  }

}