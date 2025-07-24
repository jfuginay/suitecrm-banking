<?php
if(!defined('sugarEntry') || !sugarEntry) die('Not A Valid Entry Point');

require_once('include/Dashlets/DashletGeneric.php');

class RealEstateDashlet extends DashletGeneric {
    
    public function __construct($id, $def = null)
    {
        global $current_user, $app_strings;
        require('modules/DashBoard/language/en_us.lang.php');
        
        parent::__construct($id, $def);
        
        if(empty($def['title'])) $this->title = translate('LBL_REAL_ESTATE_TITLE', 'Home');
        
        $this->searchFields = array();
        $this->columns = array();
        
        $this->seedBean = new stdClass();
    }
    
    public function displayDashlet()
    {
        global $current_user;
        
        $ss = new Sugar_Smarty();
        
        // Get customer data from our credit card API
        $customers = $this->getCustomers();
        
        $ss->assign('customers', $customers);
        $ss->assign('dashlet_id', $this->id);
        $ss->assign('module', 'Home');
        
        return $ss->fetch(dirname(__FILE__) . '/RealEstateDashlet.tpl');
    }
    
    private function getCustomers() 
    {
        // Read our customer profiles
        $profileFile = $GLOBALS['sugar_config']['site_url'] . '/../../CUSTOMER_PROFILES.json';
        if (file_exists($profileFile)) {
            $content = file_get_contents($profileFile);
            $lines = explode("\n", trim($content));
            $customers = [];
            
            foreach ($lines as $line) {
                if (trim($line) && $line !== '}') {
                    $customer = json_decode($line, true);
                    if ($customer && isset($customer['customerId'])) {
                        $customers[] = $customer;
                    }
                }
            }
            return $customers;
        }
        
        return [];
    }
    
    public function displayOptions()
    {
        return '';
    }
}
?>