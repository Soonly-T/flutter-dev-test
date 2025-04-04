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

const verifyAccessToken=(token)=>{
    const secret= "R1P_4ND_T34R "
    try {
        const decoded = jwt.verify(token, secret);
        return decoded;
    } catch (err) {
        console.error('Token verification failed:', err);
        return null;
    }
}

module.exports={generateAccessToken, verifyAccessToken}

