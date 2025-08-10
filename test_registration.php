<?php
// Test registration endpoint to verify what the server should return
header('Content-Type: application/json');
header('X-API-KEY: cscodetech');

// Disable PHP error display to prevent HTML in JSON response
ini_set('display_errors', 0);
error_reporting(0);

// Get input data
$input = [];
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = $_POST; // Form data
    if (empty($input)) {
        $input = json_decode(file_get_contents('php://input'), true); // JSON data
    }
}

// Log the input for debugging
error_log("Registration input: " . print_r($input, true));

// Validate required fields
$required_fields = ['name', 'mobile', 'email', 'password', 'user_role'];
$missing_fields = [];

foreach ($required_fields as $field) {
    if (empty($input[$field])) {
        $missing_fields[] = $field;
    }
}

if (!empty($missing_fields)) {
    $response = [
        'Result' => 'false',
        'ResponseCode' => '400',
        'ResponseMsg' => 'Missing required fields: ' . implode(', ', $missing_fields)
    ];
    echo json_encode($response);
    exit;
}

// Simulate successful registration
$response = [
    'Result' => 'true',
    'ResponseCode' => '200',
    'ResponseMsg' => 'User registered successfully',
    'UserLogin' => [
        'id' => '123',
        'name' => $input['name'],
        'mobile' => $input['mobile'],
        'email' => $input['email'],
        'user_role' => $input['user_role'],
        'selected_brand' => isset($input['selected_brand']) ? $input['selected_brand'] : null,
        'selected_trailer_type' => isset($input['selected_trailer_type']) ? $input['selected_trailer_type'] : null,
        'status' => '1',
        'created_at' => date('Y-m-d H:i:s')
    ]
];

echo json_encode($response);
?>
