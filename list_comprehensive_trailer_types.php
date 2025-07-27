<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Database configuration
$host = 'localhost';
$dbname = 'plunlt_0v7nax';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Fetch all comprehensive trailer types
    $stmt = $pdo->prepare("
        SELECT 
            id,
            name,
            length_min,
            length_max,
            width,
            height_min,
            height_max,
            weight_capacity_lbs,
            weight_capacity_kg,
            common_uses,
            category,
            status,
            created_at
        FROM tbl_trailer_types 
        WHERE status = 1 
        ORDER BY name ASC
    ");
    
    $stmt->execute();
    $trailerTypes = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'status' => true,
        'message' => 'Trailer types fetched successfully',
        'trailer_types' => $trailerTypes
    ]);
    
} catch(PDOException $e) {
    echo json_encode([
        'status' => false,
        'message' => 'Database error: ' . $e->getMessage(),
        'trailer_types' => []
    ]);
}
?> 