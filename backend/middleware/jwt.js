const jwt=require('jsonwebtoken')

const generateAccessToken=(user)=>{
    const payload={
        id:user.id,
        username:user.username,
        email:user.email
    }

    const secret = "R1P_4ND_T34R "
    const options = { expiresIn: '1h' };
    return jwt.sign(payload,secret,options)

}

module.exports={generateAccessToken}