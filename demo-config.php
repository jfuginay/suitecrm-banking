<?php
/**
 * SuiteCRM Banking Demo Configuration
 * Auto-login and demo features for hosted demos
 */

// Demo mode settings
$sugar_config['demo_mode'] = true;
$sugar_config['demo_reset_interval'] = 3600; // Reset every hour
$sugar_config['demo_banner'] = true;

// Auto-login credentials
$sugar_config['demo_users'] = [
    'manager' => [
        'username' => 'bank_manager',
        'password' => 'demo123',
        'role' => 'Bank Manager',
        'description' => 'Full access to all banking features'
    ],
    'loan_officer' => [
        'username' => 'loan_officer', 
        'password' => 'demo123',
        'role' => 'Loan Officer',
        'description' => 'Process loan applications'
    ],
    'teller' => [
        'username' => 'teller',
        'password' => 'demo123', 
        'role' => 'Bank Teller',
        'description' => 'View customer accounts'
    ]
];

// Demo data settings
$sugar_config['demo_data'] = [
    'customers' => 50,
    'loans' => 25,
    'accounts' => 100,
    'transactions' => 500
];

// COBOL API endpoint for demos
$sugar_config['cobol_api_url'] = getenv('COBOL_API_URL') ?: 'http://cobol-api:3000';

// Disable features that shouldn't be in demo
$sugar_config['disable_email_send'] = true;
$sugar_config['disable_persistent_connections'] = false;
$sugar_config['demo_disable_modules'] = ['Campaigns', 'EmailMarketing'];

// Performance settings for demo
$sugar_config['disable_count_query'] = true;
$sugar_config['list_max_entries_per_page'] = 20;

// Demo reset schedule
if (getenv('AUTO_RESET') === 'hourly') {
    // Check if we need to reset
    $last_reset_file = '/tmp/last_demo_reset';
    $should_reset = false;
    
    if (!file_exists($last_reset_file)) {
        $should_reset = true;
    } else {
        $last_reset = filemtime($last_reset_file);
        if (time() - $last_reset > 3600) {
            $should_reset = true;
        }
    }
    
    if ($should_reset) {
        // Reset will be handled by a cron job
        touch($last_reset_file);
    }
}

// Add demo banner CSS
if (!empty($sugar_config['demo_banner'])) {
    $sugar_config['additional_css'] = '
        .demo-banner {
            background: #f39c12;
            color: white;
            padding: 10px;
            text-align: center;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 9999;
            font-weight: bold;
        }
        .demo-banner a {
            color: white;
            text-decoration: underline;
            margin-left: 20px;
        }
        body.LoginView .demo-credentials {
            background: white;
            border: 2px solid #3498db;
            border-radius: 8px;
            padding: 20px;
            margin: 20px auto;
            max-width: 400px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .demo-credentials h3 {
            color: #2c3e50;
            margin-bottom: 15px;
        }
        .demo-credentials button {
            background: #3498db;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            margin: 5px;
        }
        .demo-credentials button:hover {
            background: #2980b9;
        }
    ';
}

// Database configuration for cloud deployment
if (getenv('DATABASE_URL')) {
    $db_url = parse_url(getenv('DATABASE_URL'));
    $sugar_config['dbconfig']['db_host_name'] = $db_url['host'];
    $sugar_config['dbconfig']['db_user_name'] = $db_url['user'];
    $sugar_config['dbconfig']['db_password'] = $db_url['pass'];
    $sugar_config['dbconfig']['db_name'] = substr($db_url['path'], 1);
    $sugar_config['dbconfig']['db_port'] = $db_url['port'] ?? 3306;
}

// Site URL for cloud deployment
if (getenv('RAILWAY_STATIC_URL')) {
    $sugar_config['site_url'] = 'https://' . getenv('RAILWAY_STATIC_URL');
} elseif (getenv('RENDER_EXTERNAL_URL')) {
    $sugar_config['site_url'] = getenv('RENDER_EXTERNAL_URL');
} elseif (getenv('HEROKU_APP_NAME')) {
    $sugar_config['site_url'] = 'https://' . getenv('HEROKU_APP_NAME') . '.herokuapp.com';
}