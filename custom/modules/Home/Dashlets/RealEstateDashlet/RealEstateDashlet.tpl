<div class="dashletPanelBody">
    <div style="padding: 15px;">
        <h3 style="color: #333; border-bottom: 2px solid #667eea; padding-bottom: 5px;">
            🏡 Real Estate Clients & Payment Processing
        </h3>
        
        <div style="display: flex; gap: 20px; margin-top: 15px;">
            <!-- Quick Actions -->
            <div style="flex: 1; background: #f8f9fa; padding: 15px; border-radius: 8px;">
                <h4>🚀 Quick Actions</h4>
                <p><a href="index.php?module=COBOL_Bridge&action=calculator" style="color: #667eea; text-decoration: none;">
                    💰 Financial Calculator
                </a></p>
                <p><a href="index.php?module=COBOL_Bridge&action=transaction_ledger" style="color: #667eea; text-decoration: none;">
                    📊 Transaction Ledger
                </a></p>
                <p><a href="index.php?module=Mainframe_Sync&action=index" style="color: #667eea; text-decoration: none;">
                    🔄 Mainframe Sync
                </a></p>
                <p><a href="real_estate_dashboard.html" target="_blank" style="color: #667eea; text-decoration: none;">
                    🏠 Add New Client
                </a></p>
            </div>
            
            <!-- Customer List -->
            <div style="flex: 2;">
                <h4>👥 Recent Clients</h4>
                {if $customers}
                    {foreach from=$customers item=customer}
                        <div style="background: #e8f4f8; border-left: 4px solid #667eea; padding: 10px; margin: 5px 0; border-radius: 4px;">
                            <strong>{$customer.fullName}</strong><br>
                            <small style="color: #666;">
                                📧 {$customer.email}<br>
                                💳 {$customer.cardNumber} ({$customer.cardType})<br>
                                🏠 {$customer.propertyDetails.propertyType|capitalize} • ${$customer.propertyDetails.estimatedValue|number_format}
                            </small>
                        </div>
                    {/foreach}
                {else}
                    <p style="color: #666; font-style: italic;">No customers yet. <a href="real_estate_dashboard.html" target="_blank">Add your first client!</a></p>
                {/if}
            </div>
        </div>
        
        <!-- Integration Status -->
        <div style="margin-top: 20px; padding: 10px; background: #d4edda; border: 1px solid #c3e6cb; border-radius: 4px;">
            <strong>🔗 Integration Status:</strong>
            <span style="color: #155724;">
                ✅ Credit Card API Connected • ✅ COBOL Services Active • ✅ Mainframe Sync Ready
            </span>
        </div>
    </div>
</div>