const express = require('express');
const dbOperations = require('../../../database/dbOperations');
const router=express.Router();
const encrypt=require('./encrypt')

router.post('/signup',async (req,res)=>{
    const {username,email,password}=req.body
    const hashedPass=await encrypt.encrypt(password);
    dbOperations.addUser(username,email,hashedPass);

})

router.post("/login",async (req,res)=>{
    const {username,password}=req.body
    const hashedPass=await encrypt.encrypt(password);
    const correct=await encrypt.comparePassword(username,password,hashedPass);


})
router.get('/get-users', async(req, res) => {
    dbOperations.getUsers();
    
});