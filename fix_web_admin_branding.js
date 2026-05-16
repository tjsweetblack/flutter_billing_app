const fs = require('fs');
let html = fs.readFileSync('web-admin/index.html', 'utf8');

// 1. Branding Updates: Colors & Logo
html = html.replace(/#3b82f6/g, '#7ed957'); // Replace blue with green
html = html.replace(/#2563eb/g, '#6ab64a'); // Replace dark blue with slightly darker green
html = html.replace(/#0284c7/g, '#4caf50'); // Replace accent blue
html = html.replace(/#e0f2fe/g, '#e8f5e9'); // Replace light blue background
html = html.replace(/\<div class="logo">KP<\/div>/g, '<img src="../web/icons/Icon-192.png" alt="Logo" class="logo" style="background:none;">');
html = html.replace(/\<div class="header-logo">KP<\/div>/g, '<img src="../web/icons/Icon-192.png" alt="Logo" class="header-logo" style="background:none;">');
html = html.replace(/>Portal Bancário Kandonga POS</g, '>Portal de Análise Kandonga<');

// 2. Add Audit Log Modal to UI
const auditLogModal = `

    <!-- Audit Log Modal -->
    <div class="modal" id="auditModal">
        <div class="modal-content" style="max-width: 800px;">
            <div class="modal-header">
                <h2>Registo de Decisões de Micro-crédito</h2>
                <button class="close-modal" onclick="closeAuditModal()">×</button>
            </div>
            <div class="filter-controls" style="margin-bottom: 20px;">
               <input type="text" id="auditSearch" placeholder="Pesquisar loja..." style="padding:8px; border:1px solid #e2e8f0; border-radius:8px; width:100%;">
            </div>
            <div style="overflow-x: auto;">
                <table class="transaction-table">
                    <thead>
                        <tr>
                            <th>Data</th>
                            <th>Loja</th>
                            <th>Montante</th>
                            <th>Decisão</th>
                            <th>Banco</th>
                        </tr>
                    </thead>
                    <tbody id="auditBody"></tbody>
                </table>
            </div>
        </div>
    </div>
`;
html = html.replace(/<\/body>/g, auditLogModal + '\n</body>');

// Add "Ver Registo" button to header
const auditButton = `<button class="refresh-btn" onclick="openAuditModal()" style="margin-right: 12px; background: #e8f5e9; color: #4caf50;">Ver Registo (Audit)</button>`;
html = html.replace(/<button class="logout-btn"/, auditButton + '\n                <button class="logout-btn"');

// 3. Update JavaScript logic to handle Audit Logging
const auditLogic = `
        function openAuditModal() {
            document.getElementById('auditModal').classList.add('active');
            renderAuditLog();
        }
        function closeAuditModal() {
            document.getElementById('auditModal').classList.remove('active');
        }
        
        document.getElementById('auditModal').addEventListener('click', e => { if (e.target === document.getElementById('auditModal')) closeAuditModal(); });
        
        function renderAuditLog() {
            const auditBody = document.getElementById('auditBody');
            const search = (document.getElementById('auditSearch') ? document.getElementById('auditSearch').value.toLowerCase() : '');
            
            // Filter all loans that have been processed (not pending) across all time
            const processedLoans = allLoans.filter(l => l.status !== 'pending' && l.bank === currentBank);
            
            const filtered = processedLoans.filter(l => (l.shopName || '').toLowerCase().includes(search));
            
            if (filtered.length === 0) {
                auditBody.innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 20px; color: #64748b;">Nenhuma decisão registada</td></tr>';
                return;
            }
            
            filtered.sort((a,b) => new Date(b.updatedAt || b.date) - new Date(a.updatedAt || a.date));
            
            auditBody.innerHTML = filtered.map(loan => \`
                <tr>
                    <td>\${formatDate(loan.updatedAt || loan.date)}</td>
                    <td><strong>\${loan.shopName || 'N/A'}</strong></td>
                    <td>Kz \${(loan.amount || 0).toLocaleString()}</td>
                    <td><span class="loan-status status-\${loan.status}">\${getStatusLabel(loan.status)}</span></td>
                    <td>\${loan.updatedBy || loan.bank || currentBank}</td>
                </tr>
            \`).join('');
        }
        // Add search listener
        setTimeout(() => {
           if(document.getElementById('auditSearch')) {
              document.getElementById('auditSearch').addEventListener('input', renderAuditLog);
           }
        }, 1000);
`;

html = html.replace(/document\.addEventListener\('keydown'/g, auditLogic + '\n        document.addEventListener(\'keydown\'');

fs.writeFileSync('web-admin/index.html', html);
