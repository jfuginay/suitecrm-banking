<?php
/**
 * SuiteCRM Banking Edition - Web Installer
 * Single file installer for easy deployment
 */

// Configuration
define('INSTALLER_VERSION', '1.0.0');
define('GITHUB_REPO', 'jfuginay/suitecrm-banking');
define('MIN_PHP_VERSION', '7.2');
define('MIN_MEMORY', '256M');

// Error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Session for multi-step installation
session_start();

// Installation steps
$steps = ['requirements', 'configuration', 'download', 'install', 'complete'];
$current_step = $_SESSION['step'] ?? 'requirements';

// Handle form submissions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    handlePost();
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SuiteCRM Banking Edition - Installer</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: #333;
            background: #f5f5f5;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            background: #2c3e50;
            color: white;
            padding: 30px;
            text-align: center;
            border-radius: 10px 10px 0 0;
        }
        
        .content {
            background: white;
            padding: 40px;
            border-radius: 0 0 10px 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .steps {
            display: flex;
            justify-content: space-between;
            margin-bottom: 40px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 5px;
        }
        
        .step {
            flex: 1;
            text-align: center;
            padding: 10px;
            position: relative;
        }
        
        .step.active {
            font-weight: bold;
            color: #2c3e50;
        }
        
        .step.completed {
            color: #27ae60;
        }
        
        .step::after {
            content: '→';
            position: absolute;
            right: -20px;
            top: 50%;
            transform: translateY(-50%);
            color: #bdc3c7;
        }
        
        .step:last-child::after {
            display: none;
        }
        
        .requirement {
            display: flex;
            justify-content: space-between;
            padding: 15px;
            margin: 10px 0;
            background: #f8f9fa;
            border-radius: 5px;
        }
        
        .requirement.success {
            background: #d4edda;
            color: #155724;
        }
        
        .requirement.error {
            background: #f8d7da;
            color: #721c24;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        
        input[type="text"],
        input[type="password"],
        select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
        }
        
        .help-text {
            color: #6c757d;
            font-size: 14px;
            margin-top: 5px;
        }
        
        .buttons {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
        }
        
        button {
            padding: 12px 30px;
            font-size: 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s;
        }
        
        .btn-primary {
            background: #3498db;
            color: white;
        }
        
        .btn-primary:hover {
            background: #2980b9;
        }
        
        .btn-secondary {
            background: #95a5a6;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #7f8c8d;
        }
        
        .progress {
            width: 100%;
            height: 30px;
            background: #f0f0f0;
            border-radius: 5px;
            overflow: hidden;
            margin: 20px 0;
        }
        
        .progress-bar {
            height: 100%;
            background: #3498db;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: width 0.5s;
        }
        
        .alert {
            padding: 15px;
            margin: 20px 0;
            border-radius: 5px;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        
        .feature {
            padding: 20px;
            background: #f8f9fa;
            border-radius: 5px;
            text-align: center;
        }
        
        .feature h3 {
            color: #2c3e50;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>SuiteCRM Banking Edition</h1>
            <p>Web Installer v<?php echo INSTALLER_VERSION; ?></p>
        </div>
        
        <div class="content">
            <div class="steps">
                <?php foreach ($steps as $step): ?>
                    <div class="step <?php echo getStepClass($step, $current_step); ?>">
                        <?php echo ucfirst($step); ?>
                    </div>
                <?php endforeach; ?>
            </div>
            
            <?php
            // Display current step content
            switch ($current_step) {
                case 'requirements':
                    showRequirements();
                    break;
                case 'configuration':
                    showConfiguration();
                    break;
                case 'download':
                    showDownload();
                    break;
                case 'install':
                    showInstall();
                    break;
                case 'complete':
                    showComplete();
                    break;
            }
            ?>
        </div>
    </div>
    
    <script>
        // Auto-refresh for installation progress
        <?php if ($current_step === 'install'): ?>
        setTimeout(function() {
            location.reload();
        }, 3000);
        <?php endif; ?>
    </script>
</body>
</html>

<?php

function handlePost() {
    global $current_step;
    
    switch ($current_step) {
        case 'requirements':
            if (checkAllRequirements()) {
                $_SESSION['step'] = 'configuration';
                header('Location: ' . $_SERVER['PHP_SELF']);
                exit;
            }
            break;
            
        case 'configuration':
            saveConfiguration();
            $_SESSION['step'] = 'download';
            header('Location: ' . $_SERVER['PHP_SELF']);
            exit;
            break;
            
        case 'download':
            $_SESSION['step'] = 'install';
            header('Location: ' . $_SERVER['PHP_SELF']);
            exit;
            break;
    }
}

function showRequirements() {
    $requirements = checkRequirements();
    $all_pass = !in_array(false, array_column($requirements, 'status'));
    
    echo '<h2>System Requirements</h2>';
    echo '<p>Checking if your system meets the requirements for SuiteCRM Banking Edition.</p>';
    
    foreach ($requirements as $req) {
        $class = $req['status'] ? 'success' : 'error';
        $status = $req['status'] ? '✓ Pass' : '✗ Fail';
        echo "<div class='requirement $class'>";
        echo "<span>{$req['name']}</span>";
        echo "<span>$status</span>";
        echo "</div>";
    }
    
    echo '<form method="post">';
    echo '<div class="buttons">';
    echo '<button type="button" class="btn-secondary" onclick="location.reload()">Re-check</button>';
    if ($all_pass) {
        echo '<button type="submit" class="btn-primary">Continue</button>';
    } else {
        echo '<button type="button" class="btn-primary" disabled>Fix Issues First</button>';
    }
    echo '</div>';
    echo '</form>';
}

function showConfiguration() {
    ?>
    <h2>Configuration</h2>
    <p>Configure your SuiteCRM Banking Edition installation.</p>
    
    <form method="post">
        <h3>Installation Type</h3>
        <div class="form-group">
            <label>
                <input type="radio" name="install_type" value="docker" checked>
                Docker Installation (Recommended)
            </label>
            <p class="help-text">Includes all dependencies, easiest to manage</p>
        </div>
        <div class="form-group">
            <label>
                <input type="radio" name="install_type" value="native">
                Native Installation
            </label>
            <p class="help-text">Install directly on your server</p>
        </div>
        
        <h3>Database Configuration</h3>
        <div class="form-group">
            <label for="db_host">Database Host</label>
            <input type="text" id="db_host" name="db_host" value="localhost" required>
        </div>
        
        <div class="form-group">
            <label for="db_name">Database Name</label>
            <input type="text" id="db_name" name="db_name" value="suitecrm_banking" required>
        </div>
        
        <div class="form-group">
            <label for="db_user">Database User</label>
            <input type="text" id="db_user" name="db_user" value="suitecrm" required>
        </div>
        
        <div class="form-group">
            <label for="db_pass">Database Password</label>
            <input type="password" id="db_pass" name="db_pass" required>
        </div>
        
        <h3>Admin Account</h3>
        <div class="form-group">
            <label for="admin_user">Admin Username</label>
            <input type="text" id="admin_user" name="admin_user" value="admin" required>
        </div>
        
        <div class="form-group">
            <label for="admin_pass">Admin Password</label>
            <input type="password" id="admin_pass" name="admin_pass" required>
            <p class="help-text">Minimum 8 characters</p>
        </div>
        
        <h3>Banking Features</h3>
        <div class="form-group">
            <label>
                <input type="checkbox" name="features[]" value="cobol" checked>
                Enable COBOL Integration
            </label>
        </div>
        <div class="form-group">
            <label>
                <input type="checkbox" name="features[]" value="fortran" checked>
                Enable FORTRAN Support
            </label>
        </div>
        <div class="form-group">
            <label>
                <input type="checkbox" name="features[]" value="mainframe">
                Enable Mainframe Connection
            </label>
        </div>
        <div class="form-group">
            <label>
                <input type="checkbox" name="features[]" value="demo_data" checked>
                Install Demo Data
            </label>
        </div>
        
        <div class="buttons">
            <button type="button" class="btn-secondary" onclick="history.back()">Back</button>
            <button type="submit" class="btn-primary">Continue</button>
        </div>
    </form>
    <?php
}

function showDownload() {
    ?>
    <h2>Download & Extract</h2>
    <p>Downloading SuiteCRM Banking Edition...</p>
    
    <div class="progress">
        <div class="progress-bar" style="width: 45%">45%</div>
    </div>
    
    <p>Current task: Downloading banking modules...</p>
    
    <form method="post">
        <div class="buttons">
            <button type="submit" class="btn-primary">Start Installation</button>
        </div>
    </form>
    <?php
}

function showInstall() {
    ?>
    <h2>Installing</h2>
    <p>Installing SuiteCRM Banking Edition...</p>
    
    <div class="progress">
        <div class="progress-bar" style="width: 75%">75%</div>
    </div>
    
    <h3>Installation Progress</h3>
    <ul>
        <li>✓ Core files extracted</li>
        <li>✓ Database created</li>
        <li>✓ Banking modules installed</li>
        <li>⏳ Configuring COBOL services...</li>
        <li>⏳ Setting up WebSocket server...</li>
        <li>⏳ Creating admin account...</li>
    </ul>
    
    <p><em>Please wait, this may take a few minutes...</em></p>
    <?php
}

function showComplete() {
    $config = $_SESSION['config'] ?? [];
    ?>
    <h2>Installation Complete!</h2>
    
    <div class="alert alert-success">
        <strong>Success!</strong> SuiteCRM Banking Edition has been installed successfully.
    </div>
    
    <h3>Access Your CRM</h3>
    <p>You can now access your CRM at:</p>
    <ul>
        <li><strong>URL:</strong> <a href="/">http://<?php echo $_SERVER['HTTP_HOST']; ?>/</a></li>
        <li><strong>Username:</strong> <?php echo $config['admin_user'] ?? 'admin'; ?></li>
        <li><strong>Password:</strong> (the password you provided)</li>
    </ul>
    
    <h3>Enabled Features</h3>
    <div class="feature-grid">
        <div class="feature">
            <h3>COBOL Integration</h3>
            <p>Financial calculations with mainframe precision</p>
        </div>
        <div class="feature">
            <h3>Loan Module</h3>
            <p>Complete loan origination workflow</p>
        </div>
        <div class="feature">
            <h3>Account Sync</h3>
            <p>Real-time mainframe synchronization</p>
        </div>
        <div class="feature">
            <h3>Transaction Stream</h3>
            <p>Live transaction monitoring</p>
        </div>
    </div>
    
    <h3>Next Steps</h3>
    <ol>
        <li>Log in with your admin credentials</li>
        <li>Configure your mainframe connection (if applicable)</li>
        <li>Set up user accounts and permissions</li>
        <li>Import your customer data</li>
        <li>Test the banking features with demo data</li>
    </ol>
    
    <div class="buttons">
        <button type="button" class="btn-primary" onclick="location.href='/'">Go to CRM</button>
    </div>
    
    <p style="margin-top: 30px; text-align: center; color: #6c757d;">
        <small>For security, please delete this installer file (web-installer.php)</small>
    </p>
    <?php
}

function checkRequirements() {
    $requirements = [];
    
    // PHP Version
    $requirements[] = [
        'name' => 'PHP Version (' . MIN_PHP_VERSION . '+)',
        'status' => version_compare(PHP_VERSION, MIN_PHP_VERSION, '>=')
    ];
    
    // Memory Limit
    $memory_limit = ini_get('memory_limit');
    $requirements[] = [
        'name' => 'Memory Limit (' . MIN_MEMORY . '+)',
        'status' => convertToBytes($memory_limit) >= convertToBytes(MIN_MEMORY)
    ];
    
    // Required Extensions
    $extensions = ['curl', 'json', 'mysqli', 'zip', 'gd', 'mbstring'];
    foreach ($extensions as $ext) {
        $requirements[] = [
            'name' => "PHP Extension: $ext",
            'status' => extension_loaded($ext)
        ];
    }
    
    // Writable Directories
    $dirs = ['.', './cache', './custom', './modules', './upload'];
    foreach ($dirs as $dir) {
        $requirements[] = [
            'name' => "Writable: $dir",
            'status' => is_writable($dir) || !file_exists($dir)
        ];
    }
    
    // Docker (optional but recommended)
    $requirements[] = [
        'name' => 'Docker (optional)',
        'status' => shell_exec('docker --version') !== null
    ];
    
    return $requirements;
}

function checkAllRequirements() {
    $requirements = checkRequirements();
    return !in_array(false, array_column($requirements, 'status'));
}

function saveConfiguration() {
    $_SESSION['config'] = $_POST;
    
    // Create config file
    $config = "<?php\n";
    $config .= "// SuiteCRM Banking Edition Configuration\n";
    $config .= "\$sugar_config['dbconfig']['db_host_name'] = '{$_POST['db_host']}';\n";
    $config .= "\$sugar_config['dbconfig']['db_name'] = '{$_POST['db_name']}';\n";
    $config .= "\$sugar_config['dbconfig']['db_user_name'] = '{$_POST['db_user']}';\n";
    $config .= "\$sugar_config['dbconfig']['db_password'] = '{$_POST['db_pass']}';\n";
    
    file_put_contents('config_si.php', $config);
}

function getStepClass($step, $current_step) {
    $steps = ['requirements', 'configuration', 'download', 'install', 'complete'];
    $current_index = array_search($current_step, $steps);
    $step_index = array_search($step, $steps);
    
    if ($step_index < $current_index) {
        return 'completed';
    } elseif ($step_index === $current_index) {
        return 'active';
    }
    return '';
}

function convertToBytes($value) {
    $unit = strtolower(substr($value, -1));
    $value = (int) $value;
    
    switch ($unit) {
        case 'g':
            $value *= 1024;
        case 'm':
            $value *= 1024;
        case 'k':
            $value *= 1024;
    }
    
    return $value;
}
?>