const express= require('express');
const jsonwebtoken = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const app = express();
const routes=require('./routes');

const router=express.Router();


app.use(express.json());
app.use(cors())


app.listen(port=3000,hostname="localhost",()=>{
    console.log(`Server is running on http://${hostname}:${[port]}`)
})

