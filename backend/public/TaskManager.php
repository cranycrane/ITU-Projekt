<?php

namespace App;

use DateTime;

class TaskManager {

    private TaskRepository $taskrepository;

    public function __construct(TaskRepository $taskrepository)
    {
        $this->taskrepository = $taskrepository;
    }

    public function getTasksById(int $user_id) {

        $queryResult = $this->taskrepository->findById($user_id);
        $tasks = [];

        while ($row = mysqli_fetch_assoc($queryResult)) {

            $task = new Task($row);
            array_push($tasks, $task);
        }

        return $tasks;
    }

    public function createTask($data) {
        /*
        $data = [
            'title' => $title,
            'description' => $description,
            'duedate' => $dueDate,
            'status' => $status,
            'userid' => $user_id
        ];
        */
        $data['id'] = $this->taskrepository->create($data);
        
        $task = new Task($data);

        return $task;
    }

    public function formCreateTask($id) {

        if ($_SERVER["REQUEST_METHOD"] == "POST") {
            htmlspecialchars($_SERVER["PHP_SELF"]);
            $data = [
                'name' => $_POST['name'],
                'datecreated' => date('y-m-d'),
                'description' => '',
                'datedue' => '',
                'status' => $_POST['status'],
                'user_id' => $id
            ];

            $this->createTask($data);
            echo "Ukol uspesne pridan!";
        }

    }

    public function updateTask($taskID, $data) {


    }

    public function removeTask($taskID) {

    return $this->taskrepository->delete($taskID);
    }





}