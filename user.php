<?php
// ตั้งค่าการเชื่อมต่อ
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "app_qa";

// สร้างการเชื่อมต่อ
$conn = mysqli_connect($servername, $username, $password, $dbname);

// ตรวจสอบการเชื่อมต่อ
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

$user = isset($_POST['user']) ? trim($_POST['user']) : '';

if ($user == "INSERT") {
    $username = $_POST['username'];
    $password = $_POST['password'];
    $name = $_POST['name'];
    $role = $_POST['role'];
    
    $sql = "INSERT INTO `user` (`id`, `username`, `password`, `name`, `role`) VALUES (NULL, '$username', '$password', '$name', '$role')";
    
    if ($conn->query($sql) === TRUE) {
        echo "Insert Success";
    } else {
        echo "Error: " . $conn->error;
    }
}

if ($user == "UPDATE") {
    $id = $_POST['id']; // ID ของข้อมูลที่ต้องการอัปเดต
    $username = $_POST['username'];
    $password = $_POST['password'];
    $name = $_POST['name'];
    $role = $_POST['role'];
    
    $sql = "UPDATE `user` SET `username` = '$username', `password` = '$password', `name` = '$name', `role` = '$role' WHERE `id` = $id";
    
    if ($conn->query($sql) === TRUE) {
        echo "Update Success";
    } else {
        echo "Error: " . $conn->error;
    }
}

if ($user == "DELETE") {
    $id = isset($_POST['id']) ? intval($_POST['id']) : 0; // รับ ID และแปลงเป็นจำนวนเต็ม

    if ($id > 0) {
        $sql = "DELETE FROM `user` WHERE `id` = $id";
        if ($conn->query($sql) === TRUE) {
            echo "Delete Success";
        } else {
            echo "Error: " . $conn->error;
        }
    } else {
        echo "Invalid ID";
    }
}

if ($user == "SELECT_ALL") {
    $sql = "SELECT * FROM `user`";
    
    $result = $conn->query($sql);
    
    if ($result->num_rows > 0) {
        $data = [];
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        echo json_encode($data);
    } else {
        echo json_encode(["message" => "No records found"]);
    }
}


if ($user == "SELECT") {
    $id = $_POST['id']; // ID ของข้อมูลที่ต้องการเลือก
    
    // Escape ค่า $id เพื่อลดความเสี่ยงจาก SQL Injection
    $id = $conn->real_escape_string($id);
    
    $sql = "SELECT `id`, `username`, `password`, `name`, `role` FROM `user` WHERE `id` = '$id'";
    
    $result = $conn->query($sql);
    
    if ($result->num_rows > 0) {
        $data = [];
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        echo json_encode($data);
    } else {
        echo json_encode(["message" => "No records found"]);
    }
}


$conn->close();
?>
