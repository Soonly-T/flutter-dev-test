const bcrypt=require('bcrypt');
const saltRounds=10;
const myPlaintextPassword='s0/\/\\P4$$w0rD';
const someOtherPlaintextPassword='not_bacon';
const dbOperations=require('../database/dbOperations');

const encrypt = (password)=>{
    if (err){
        console.log(err);
    }
    else{
        const hashedPass=bcrypt.hash(password,saltRounds,(err,hash));
        return hashedPass
    }
}

const comparePassword=(username,password,storedPassword,saltRoundshash)=>{
    const hashdb=dbOperations.getHashedPassword(username);
    const hash=encrypt(password);

    if (hashdb===hash){
        return true;
    }
    else{
        return false;
    }


}


bcrypt.hash(myPlaintextPassword,saltRounds,(err,hash)=>{
    if(err){
        console.log(err);
    }
    else{
        console.log(hash);
        bcrypt.compare(myPlaintextPassword,hash,(err,result)=>{
            console.log(result);
        });
        bcrypt.compare(someOtherPlaintextPassword,hash,(err,result)=>{
            console.log(result);
        });
    }
});

module.exports={encrypt, comparePassword}