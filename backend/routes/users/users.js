const express = require('express');
const dbOperations = require('../../../database/dbOperations');
const router=express.Router();
const encrypt=require('./encrypt')
const jwt=require('./middleware/jwt.js')

router.post('/signup',async (req,res)=>{
    const {username,email,password}=req.body
    const hashedPass=await encrypt.encrypt(password);
    dbOperations.addUser(username,email,hashedPass);

})

router.post("/login",async (req,res)=>{
    const {loginIdentifier,password}=req.body
    try{
        
        const correct=await encrypt.comparePassword(loginIdentifier,password);
        if (correct){
            const userData=dbOperations.getUser(loginIdentifier)
            const userjwt=jwt.generateAccessToken(userData)
            //write the logic for the jwt token
            return userjwt
        } else{
            //alert user invalid credential

        }
        
}catch(err){
    console.log(err) 
    //display to the user code that user not found
    if (err.message === "User not found") {
        // Handle the "user not found" error
        return res.status(401).json({ message: "Username or Email is incorrect" });
    } else {
        // Handle other errors (e.g., database errors)
        return res.status(500).json({ message: "Something went wrong" });
    }

}
})

router.get('/get-users', async(req, res) => {
    dbOperations.getUsers();
    
});