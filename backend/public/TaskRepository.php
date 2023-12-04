<?php

namespace App;

class TaskRepository {
    private $connection;

    public function __construct(MySQL $connection)
    {
        $this->connection = $connection;
    }

    public function findById($taskId) {
        // Implementace metody pro vyhledání úkolu podle ID
        $sql = "SELECT * FROM tasks WHERE id = $taskId";

        return $this->connection->query($sql);
    }

    public function findAll() {
        // Implementace metody pro získání všech úkolů
        $sql = "SELECT * FROM tasks";
        
        $result = $this->connection->query($sql);
        


    }

    public function allByUserId($userId) {
        // Implementace metody pro vyhledání úkolů podle ID uživatele
        $sql = "SELECT * FROM tasks WHERE user_id = $userId";

        $result = $this->connection->query($sql);

        $tasks = [];

        while ($row = $result->fetch_assoc()) {
            $task = new Task($row);
            $tasks = $task;
        }

        return $tasks;
    }

    public function create($data) {
        // Implementace metody pro vytvoření nového úkolu
        $sql = "INSERT INTO tasks (name, description, datecreated, user_id) 
        VALUES ('" . $data['name'] . "', '" . $data['description'] . "', '" . $data['datecreated'] . "', " . $data['user_id'] . ")";

        $this->connection->query($sql);
        return $this->connection->getLastInsertedId();
    }

    public function update($taskId, $data) {
        // Implementace metody pro aktualizaci existujícího úkolu
        $sql = "UPDATE task SET (name, description, datedue, user_id) VALUES()";

        return $this->connection->query($sql);
    }

    public function delete($taskId) {
        // Implementace metody pro smazání úkolu
        $sql = "DELETE FROM tasks WHERE id = $taskId";

        return $this->connection->query($sql);
    }
}