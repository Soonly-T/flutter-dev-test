# Instructions for Testing

## SERVER SETTINGS

File: /backend/app.js

app.listen(port=3000,hostname="192.168.0.115",()=>{
    console.log(`Server is running on http://${hostname}:${[port]}`)
})


set the port and hostname of the server and run it by node app.js

## FRONTEND SETTINGS

File: /frontend/expenses_app/main.dart

String frontendHost = '192.168.0.115';
int frontendPort = 3000;

set frontendHost and frontendPort to match with the server's settings