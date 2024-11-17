# Habilitar WinRM e configurar serviço
Write-Output "Habilitando o WinRM e configurando o serviço..."
winrm quickconfig -force

# Permitir autenticação básica
Write-Output "Habilitando autenticação básica..."
winrm set winrm/config/service/Auth '@{Basic="true"}'

# Permitir comunicações não criptografadas
Write-Output "Permitindo comunicações não criptografadas..."
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

# Configurar limite de memória para shells remotas
Write-Output "Configurando o limite de memória para shells remotas..."
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'

Write-Output "Configuração do WinRM concluída com sucesso!"
