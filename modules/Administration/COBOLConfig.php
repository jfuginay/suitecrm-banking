<?php
/**
 * COBOL Banking Integration - Admin Configuration Panel
 */

if (!defined('sugarEntry') || !sugarEntry) die('Not A Valid Entry Point');

require_once('modules/Administration/Administration.php');

class COBOLConfig extends SugarView
{
    public function display()
    {
        global $mod_strings, $app_strings, $sugar_config;
        
        $admin = BeanFactory::newBean('Administration');
        $admin->retrieveSettings('cobol');
        
        // Handle form submission
        if (!empty($_POST['save'])) {
            $this->saveConfig();
            SugarApplication::redirect('index.php?module=Administration&action=COBOLConfig&saved=true');
        }
        
        // Test connection
        if (!empty($_POST['test_connection'])) {
            $this->testConnection();
        }
        
        // Current settings
        $settings = array(
            'cobol_api_url' => !empty($admin->settings['cobol_api_url']) ? $admin->settings['cobol_api_url'] : 'http://localhost:3001',
            'cobol_websocket_url' => !empty($admin->settings['cobol_websocket_url']) ? $admin->settings['cobol_websocket_url'] : 'ws://localhost:8081',
            'cobol_integration_enabled' => !empty($admin->settings['cobol_integration_enabled']) ? $admin->settings['cobol_integration_enabled'] : false,
            'cobol_cache_enabled' => !empty($admin->settings['cobol_cache_enabled']) ? $admin->settings['cobol_cache_enabled'] : true,
            'cobol_cache_ttl' => !empty($admin->settings['cobol_cache_ttl']) ? $admin->settings['cobol_cache_ttl'] : 3600,
            'cobol_mainframe_host' => !empty($admin->settings['cobol_mainframe_host']) ? $admin->settings['cobol_mainframe_host'] : '',
            'cobol_mainframe_port' => !empty($admin->settings['cobol_mainframe_port']) ? $admin->settings['cobol_mainframe_port'] : '3270',
            'cobol_auth_type' => !empty($admin->settings['cobol_auth_type']) ? $admin->settings['cobol_auth_type'] : 'LDAP',
            'cobol_docker_auto_start' => !empty($admin->settings['cobol_docker_auto_start']) ? $admin->settings['cobol_docker_auto_start'] : true,
        );
        
        // Check service status
        $service_status = $this->checkServiceStatus($settings['cobol_api_url']);
        
        $this->ss->assign('settings', $settings);
        $this->ss->assign('service_status', $service_status);
        $this->ss->assign('saved', !empty($_GET['saved']));
        $this->ss->assign('MOD', $mod_strings);
        $this->ss->assign('APP', $app_strings);
        
        echo $this->ss->fetch('custom/modules/Administration/COBOLConfig.tpl');
    }
    
    private function saveConfig()
    {
        $admin = BeanFactory::newBean('Administration');
        
        $settings = array(
            'cobol_api_url' => $_POST['cobol_api_url'],
            'cobol_websocket_url' => $_POST['cobol_websocket_url'],
            'cobol_integration_enabled' => !empty($_POST['cobol_integration_enabled']) ? 1 : 0,
            'cobol_cache_enabled' => !empty($_POST['cobol_cache_enabled']) ? 1 : 0,
            'cobol_cache_ttl' => intval($_POST['cobol_cache_ttl']),
            'cobol_mainframe_host' => $_POST['cobol_mainframe_host'],
            'cobol_mainframe_port' => $_POST['cobol_mainframe_port'],
            'cobol_auth_type' => $_POST['cobol_auth_type'],
            'cobol_docker_auto_start' => !empty($_POST['cobol_docker_auto_start']) ? 1 : 0,
        );
        
        foreach ($settings as $key => $value) {
            $admin->saveSetting('cobol', $key, $value);
        }
        
        // Also update config_override.php for backwards compatibility
        require_once('modules/Configurator/Configurator.php');
        $configurator = new Configurator();
        $configurator->loadConfig();
        
        $configurator->config['cobol_api_url'] = $settings['cobol_api_url'];
        $configurator->config['cobol_websocket_url'] = $settings['cobol_websocket_url'];
        $configurator->config['cobol_integration_enabled'] = $settings['cobol_integration_enabled'];
        
        $configurator->saveConfig();
        
        // Clear cache
        require_once('include/SugarCache/SugarCache.php');
        SugarCache::cleanOpcodes();
    }
    
    private function checkServiceStatus($url)
    {
        $status = array(
            'api' => false,
            'websocket' => false,
            'redis' => false,
            'docker' => false,
            'cobol_compiled' => false
        );
        
        // Check API
        $ch = curl_init($url . '/health');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 5);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode == 200) {
            $status['api'] = true;
            $health = json_decode($response, true);
            $status['cobol_compiled'] = !empty($health['cobol_programs_compiled']);
        }
        
        // Check Docker
        exec('docker ps 2>&1', $output, $return_var);
        $status['docker'] = ($return_var === 0);
        
        // Check Redis
        if (class_exists('Redis')) {
            try {
                $redis = new Redis();
                $redis->connect('localhost', 6379);
                $status['redis'] = $redis->ping();
            } catch (Exception $e) {
                $status['redis'] = false;
            }
        }
        
        return $status;
    }
    
    private function testConnection()
    {
        global $mod_strings;
        
        $url = $_POST['cobol_api_url'] . '/health';
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 10);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);
        
        if ($httpCode == 200) {
            $health = json_decode($response, true);
            SugarApplication::appendErrorMessage(
                '<div class="alert alert-success">' .
                'Connection successful! COBOL Service Version: ' . $health['version'] .
                '</div>'
            );
        } else {
            SugarApplication::appendErrorMessage(
                '<div class="alert alert-danger">' .
                'Connection failed! Error: ' . ($error ?: 'HTTP ' . $httpCode) .
                '</div>'
            );
        }
    }
}