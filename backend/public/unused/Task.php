<?php

namespace App;


class Task {

    //private TaskManager $taskmanager;

    private int $id;
    private string $name;
    private string|null $description;
    private \DateTime $dateCreated;
    private string|null $dateDuedate;
    private string|null $status;
    private int $user_id;

    public function __construct($data)
    {
        $this->id = $data['id'];
        $this->name = $data['name'];
        $this->description = $data['description'];
        $this->dateCreated = new \DateTime($data['datecreated']);
        $this->dateDuedate = $data['datedue'];
        $this->status = $data['status'];
        $this->user_id = $data['user_id'];

        //$this->taskmanager = $taskmanager;

        //$this->id = $this->taskmanager->createTask($data);
    }

    public function updateTask($data) {
        //$this->taskmanager->updateTask($this->id, $data);

    }

    public function getData() {
        $data = [
            'name' => $this->name,
            'datecreated' => $this->dateCreated,
            'description' => $this->description,
            'duedate' => $this->dateDuedate,
            'status' => $this->status,
            'user_id' => $this->user_id
        ];
        return $data;
    } 

    public function getTitle() {
        return $this->name;
    }

}