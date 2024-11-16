#!/bin/bash

#!/bin/bash

# Atualiza os pacotes do sistema
sudo apt update -y && sudo apt upgrade -y

# Instala o Nginx
sudo apt install nginx -y

sleep 10

# Cria uma configuração de proxy reverso que aceita qualquer endereço
cat <<EOL | sudo tee /etc/nginx/sites-available/reverse-proxy
server {
    listen 80;
    
    server_name _;  # Aceita qualquer domínio ou IP

    location / {
        proxy_pass http://iis-lnx:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# Remove o link para o default e ativa a nova configuração
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/reverse-proxy /etc/nginx/sites-enabled/

# Testa a configuração para garantir que está correta
sudo nginx -t

# Reinicia o Nginx para aplicar as alterações
sudo systemctl restart nginx

# Ativa o Nginx para iniciar automaticamente na inicialização
sudo systemctl enable nginx
