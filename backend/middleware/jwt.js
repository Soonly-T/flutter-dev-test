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

const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token == null) {
        return res.status(401).json({ message: 'No token provided' });
    }

    const decodedToken = verifyAccessToken(token);

    if (decodedToken) {
        req.user = decodedToken;
        next();
    } else {
        return res.status(403).json({ message: 'Invalid or expired token' });
    }
};
module.exports={generateAccessToken, verifyAccessToken, authenticateToken}

