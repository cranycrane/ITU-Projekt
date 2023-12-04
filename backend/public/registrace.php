<?php

require 'mysql.php';

// Získání odeslaných dat z formuláře a aplikace funkce htmlspecialchars
$nickname = htmlspecialchars($_POST['nickname']);
$email = htmlspecialchars($_POST["email"]);
$password = htmlspecialchars($_POST['password']);
$confirmPassword = htmlspecialchars($_POST['confirm_password']);

$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

$sqlCheckExists = "SELECT email FROM users WHERE email = $email";
/*
if (!empty($result = mysqli_query($conn, $sql))) {
    echo "Chyba: Uzivatel jiz existuje";
    exit;
}
*/
$sqlRegister = "INSERT INTO users (nickname, password, email) VALUES('$nickname', '$hashedPassword', '$email')";

if (mysqli_query($conn, $sqlRegister)) {
    echo "New record created successfully";
  } else {
    echo "Error: " . $sqlRegister . "<br>" . mysqli_error($conn);
  }

?>