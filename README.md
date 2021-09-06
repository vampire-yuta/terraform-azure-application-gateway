# Infra

## VM用キーペア作成
```
ssh-keygen -t rsa -f vamdemic -N '' 
```

## サーバ証明書作成
```
openssl genrsa 2048 > server.key && openssl req -new -key server.key -subj "/C=JP/ST=Tokyo" -out server.csr && openssl x509 -days 3650 -req -signkey server.key -in server.csr -out server.crt
openssl pkcs12 -export -inkey server.key -in server.cer -out server.pfx
```
