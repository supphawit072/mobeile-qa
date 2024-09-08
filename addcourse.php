<?php
// ตั้งค่าการเชื่อมต่อ
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "app_qa";

// สร้างการเชื่อมต่อ
$conn = new mysqli($servername, $username, $password, $dbname);

// ตรวจสอบการเชื่อมต่อ
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// รับ action จาก POST
$action = isset($_POST['action']) ? trim($_POST['action']) : '';

if ($action == "INSERT_COURSE") {
    $coursecode = $_POST['coursecode'];
    $coursename = $_POST['coursename'];
    $credits = $_POST['credits'];
    $instructor = $_POST['instructor'];
    $groups = $_POST['groups'];
    $receives = $_POST['receives'];

    $stmt = $conn->prepare("INSERT INTO course (coursecode, coursename, credits, instructor, groups, receives) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssisss", $coursecode, $coursename, $credits, $instructor, $groups, $receives);

    if ($stmt->execute()) {
        echo "Insert Success";
    } else {
        echo "Error: " . $stmt->error;
    }

    $stmt->close();
}

if ($action == "UPDATE_COURSE") {
    $id = $_POST['id'];
    $coursecode = $_POST['coursecode'];
    $coursename = $_POST['coursename'];
    $credits = $_POST['credits'];
    $instructor = $_POST['instructor'];
    $groups = $_POST['groups'];
    $receives = $_POST['receives'];

    $stmt = $conn->prepare("UPDATE course SET coursecode=?, coursename=?, credits=?, instructor=?, groups=?, receives=? WHERE id=?");
    $stmt->bind_param("ssisssi", $coursecode, $coursename, $credits, $instructor, $groups, $receives, $id);

    if ($stmt->execute()) {
        echo "Update Success";
    } else {
        echo "Error: " . $stmt->error;
    }

    $stmt->close();
}

if ($action == "DELETE_COURSE") {
    $id = isset($_POST['id']) ? intval($_POST['id']) : 0;

    if ($id > 0) {
        $stmt = $conn->prepare("DELETE FROM course WHERE id = ?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            echo "Delete Success";
        } else {
            echo "Error: " . $stmt->error;
        }

        $stmt->close();
    } else {
        echo "Invalid ID";
    }
}

if ($action == "SELECT_ALL_COURSES") {
    $sql = "SELECT * FROM course";
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

if ($action == "SELECT_COURSE_BY_CODE") {
    $coursecode = $_POST['coursecode'];

    $stmt = $conn->prepare("SELECT id, coursecode, coursename, credits, instructor, groups, receives FROM course WHERE coursecode = ?");
    $stmt->bind_param("s", $coursecode);

    if ($stmt->execute()) {
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            $data = [];
            while ($row = $result->fetch_assoc()) {
                $data[] = $row;
            }
            echo json_encode($data);
        } else {
            echo json_encode(["message" => "No records found"]);
        }
    } else {
        echo "Error: " . $stmt->error;
    }

    $stmt->close();
}

$conn->close();
?>
