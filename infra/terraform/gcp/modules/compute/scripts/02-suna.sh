#!/usr/bin/bash

apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

cat <<EOF >/etc/apt/sources.list.d/docker.list
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
  $(lsb_release -cs) stable
EOF

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/google-cloud.gpg

cat <<EOF >/etc/apt/sources.list.d/google-cloud-sdk.list
deb [signed-by=/etc/apt/keyrings/google-cloud.gpg] \
  https://packages.cloud.google.com/apt \
  cloud-sdk main
EOF

apt-get update
add-apt-repository -y ppa:deadsnakes/ppa
apt-get install -y git python3.12 python3.12-venv python3.12-dev docker-ce docker-ce-cli containerd.io docker-compose-plugin google-cloud-cli

systemctl enable --now docker

git clone ${repo_url} /opt/suna

gcloud secrets versions access latest --secret="${backend_secret}" > /opt/suna/backend/.env
echo -e "\\n\\nADDITIONAL_ORIGINS=http://${public_ip}:3000\\n" >> /opt/suna/backend/.env
gcloud secrets versions access latest --secret="${frontend_secret}" > /opt/suna/frontend/.env.local
echo -e "\\n\\nNEXT_PUBLIC_BACKEND_URL=http://${public_ip}:8000/api\\n" >> /opt/suna/frontend/.env.local

cd /opt/suna
docker compose up -d