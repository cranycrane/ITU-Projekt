<?php


require 'vendor/autoload.php';

use App\MySQL;
use App\TaskManager;
use App\TaskRepository;
/*
*/
//$userid = $_SESSION['userid'];
$userid = '';

$dbConnection = new MySQL('db', 'cranycrane', 'cranycrane', 'tasks', '3306');

$taskrepository = new TaskRepository($dbConnection);

$taskmanager = new TaskManager($taskrepository);

/*

$data = [
    'name' => "TESTIK1",
    'datecreated' => date('Y-m-d H:i:s'),
    'description' => "POPIS",
    'datedue' => '2023-01-01',
    'status' => "Dokonceno",
    'userid' => "1"
];
$taskmanager->createTask($data)
*/
$tasks = $taskmanager->getTasksById(1);

?>


<!DOCTYPE html>
<html>
    <head>
        <title>Task Manager</title>
        <meta charset="utf-8">
        <link rel="stylesheet" href="style.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
        <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>

    </head>
    <body>
    <div class="row">
        <div class="column">
        <table>
                <tr>
                    <th>Datum přidání</th>
                    <th>Název úkolu</th>
                    <th>Stav</th>
                    <th>Dokonceno</th>
                    <th>Upravitt</th>
                </tr>
                <?php foreach ($tasks as $task): $data = $task->getData(); 
                //var_dump($tasks); ?>
                <tr>
                    <td><?php echo $data['datecreated']->format('d-m-Y') ?></td>
                    <td><?php echo $data['name']; ?></td>
                    <td><?php echo $data['status'];; ?></td>
                    <td><?php echo $data['name']; ; ?></td>
                    <td><?php echo $data['name']; ; ?></td>
                </tr>
                <?php endforeach; ?>
            </table>
        </div>
        <div class="column">
            <b>Přidat úkol</b>
            <form method="post" action="<?php $taskmanager->formCreateTask(1) ?>">
                <label for="name">Název úkolu</label><br>
                <input type="text" id="name" name="name" required><br>
                
                <label for="status">Stav úkolu</label><br>
                <select id="status" name="status">
                    <option value="nedokonceno">Nedokončeno</option>
                    <option value="Dokonceno">Dokončeno</option>
                </select>
                
                <input type="submit" value="submit" name="submit">
            </form>
        </div>
    </div>
    </body>
</html>