{* COBOL Banking Integration - Admin Configuration Template *}

<h2>COBOL Banking Integration Configuration</h2>

{if $saved}
<div class="alert alert-success">
    <strong>Success!</strong> Configuration saved successfully.
</div>
{/if}

<form method="POST" action="index.php?module=Administration&action=COBOLConfig">
    
    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title">Service Status</h3>
        </div>
        <div class="panel-body">
            <table class="table table-striped">
                <tr>
                    <td>COBOL API Service</td>
                    <td>
                        {if $service_status.api}
                            <span class="label label-success">Running</span>
                        {else}
                            <span class="label label-danger">Not Running</span>
                        {/if}
                    </td>
                </tr>
                <tr>
                    <td>WebSocket Server</td>
                    <td>
                        {if $service_status.websocket}
                            <span class="label label-success">Connected</span>
                        {else}
                            <span class="label label-warning">Not Connected</span>
                        {/if}
                    </td>
                </tr>
                <tr>
                    <td>Redis Cache</td>
                    <td>
                        {if $service_status.redis}
                            <span class="label label-success">Available</span>
                        {else}
                            <span class="label label-warning">Not Available</span>
                        {/if}
                    </td>
                </tr>
                <tr>
                    <td>Docker</td>
                    <td>
                        {if $service_status.docker}
                            <span class="label label-success">Installed</span>
                        {else}
                            <span class="label label-danger">Not Installed</span>
                        {/if}
                    </td>
                </tr>
                <tr>
                    <td>COBOL Programs</td>
                    <td>
                        {if $service_status.cobol_compiled}
                            <span class="label label-success">Compiled</span>
                        {else}
                            <span class="label label-warning">Not Compiled</span>
                        {/if}
                    </td>
                </tr>
            </table>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title">Basic Configuration</h3>
        </div>
        <div class="panel-body">
            <div class="form-group">
                <label for="cobol_integration_enabled">
                    <input type="checkbox" id="cobol_integration_enabled" name="cobol_integration_enabled" value="1" {if $settings.cobol_integration_enabled}checked{/if}>
                    Enable COBOL Integration
                </label>
                <p class="help-block">Master switch to enable/disable all COBOL features</p>
            </div>
            
            <div class="form-group">
                <label for="cobol_api_url">COBOL API URL</label>
                <input type="text" class="form-control" id="cobol_api_url" name="cobol_api_url" value="{$settings.cobol_api_url}" required>
                <p class="help-block">URL for the COBOL REST API service (default: http://localhost:3001)</p>
            </div>
            
            <div class="form-group">
                <label for="cobol_websocket_url">WebSocket URL</label>
                <input type="text" class="form-control" id="cobol_websocket_url" name="cobol_websocket_url" value="{$settings.cobol_websocket_url}">
                <p class="help-block">URL for real-time transaction streaming (default: ws://localhost:8081)</p>
            </div>
            
            <button type="submit" name="test_connection" value="1" class="btn btn-info">Test Connection</button>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title">Performance Settings</h3>
        </div>
        <div class="panel-body">
            <div class="form-group">
                <label for="cobol_cache_enabled">
                    <input type="checkbox" id="cobol_cache_enabled" name="cobol_cache_enabled" value="1" {if $settings.cobol_cache_enabled}checked{/if}>
                    Enable Caching
                </label>
                <p class="help-block">Cache COBOL calculation results for better performance</p>
            </div>
            
            <div class="form-group">
                <label for="cobol_cache_ttl">Cache TTL (seconds)</label>
                <input type="number" class="form-control" id="cobol_cache_ttl" name="cobol_cache_ttl" value="{$settings.cobol_cache_ttl}" min="0">
                <p class="help-block">How long to cache calculation results (default: 3600)</p>
            </div>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title">Mainframe Configuration (Optional)</h3>
        </div>
        <div class="panel-body">
            <div class="form-group">
                <label for="cobol_mainframe_host">Mainframe Host</label>
                <input type="text" class="form-control" id="cobol_mainframe_host" name="cobol_mainframe_host" value="{$settings.cobol_mainframe_host}">
                <p class="help-block">IP address or hostname of your mainframe (for real mainframe integration)</p>
            </div>
            
            <div class="form-group">
                <label for="cobol_mainframe_port">Mainframe Port</label>
                <input type="text" class="form-control" id="cobol_mainframe_port" name="cobol_mainframe_port" value="{$settings.cobol_mainframe_port}">
                <p class="help-block">TN3270 port (default: 3270)</p>
            </div>
            
            <div class="form-group">
                <label for="cobol_auth_type">Authentication Type</label>
                <select class="form-control" id="cobol_auth_type" name="cobol_auth_type">
                    <option value="LDAP" {if $settings.cobol_auth_type eq 'LDAP'}selected{/if}>LDAP</option>
                    <option value="RACF" {if $settings.cobol_auth_type eq 'RACF'}selected{/if}>RACF</option>
                    <option value="NONE" {if $settings.cobol_auth_type eq 'NONE'}selected{/if}>None</option>
                </select>
            </div>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title">Docker Settings</h3>
        </div>
        <div class="panel-body">
            <div class="form-group">
                <label for="cobol_docker_auto_start">
                    <input type="checkbox" id="cobol_docker_auto_start" name="cobol_docker_auto_start" value="1" {if $settings.cobol_docker_auto_start}checked{/if}>
                    Auto-start Docker services
                </label>
                <p class="help-block">Automatically start COBOL services when needed</p>
            </div>
            
            <div class="form-group">
                <button type="button" class="btn btn-primary" onclick="startDockerServices()">Start COBOL Services</button>
                <button type="button" class="btn btn-warning" onclick="stopDockerServices()">Stop COBOL Services</button>
                <button type="button" class="btn btn-info" onclick="viewDockerLogs()">View Logs</button>
            </div>
        </div>
    </div>

    <div class="form-actions">
        <button type="submit" name="save" value="1" class="btn btn-success btn-lg">Save Configuration</button>
        <a href="index.php?module=Administration&action=index" class="btn btn-default btn-lg">Cancel</a>
    </div>
</form>

<script>
function startDockerServices() {
    if (confirm('Start COBOL Docker services?')) {
        // Make AJAX call to start services
        $.post('index.php?module=COBOL_Bridge&action=StartServices', function(data) {
            alert('Services starting... Please wait 30 seconds and refresh this page.');
        });
    }
}

function stopDockerServices() {
    if (confirm('Stop COBOL Docker services?')) {
        $.post('index.php?module=COBOL_Bridge&action=StopServices', function(data) {
            alert('Services stopped.');
            location.reload();
        });
    }
}

function viewDockerLogs() {
    window.open('index.php?module=COBOL_Bridge&action=ViewLogs', '_blank');
}
</script>

<style>
.panel {
    margin-bottom: 20px;
}
.form-group {
    margin-bottom: 15px;
}
.help-block {
    color: #737373;
    font-size: 12px;
}
</style>