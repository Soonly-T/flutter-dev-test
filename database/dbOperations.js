const db= requires("./database.js")

const addUser=(username,email,hashedPass)=>{
    try{
        db.run(`INSERT INTO USERS(USERNAME, EMAIL, HASHED_PASS) VALUES (?,?,?)`,[username,email,hashedPass], function(err){
          if(err){
            console.log(err)
          }
        })
      }catch (err){
        console.log(err)
    
      }

}

const removeUser=(username)=>{
    try{
        db.run("DELETE FROM EXPENSE WHERE USER_ID IN (SELECT ID FROM USERS WHERE USERNAME = ?) ",username, function(err){
            if (err){
                console.log(err)
            }
        })
        db.run("DELETE FROM USERS WHERE USERNAME = ?",username, function(err){
            if (err){
                console.log(err)
            }
        })

    }catch(err){
        console.log(err)
    }}

//approach 1
const patchUsername=(oldUsername,newUsername)=>{
    try{
        db.run("UPDATE USERS SET USERNAME = ? WHERE USERNAME = ?" [newUsername,oldUsername],function(err){
            if (err){
                console.log(err)
            }
        })
    }catch(err){
        console.log(err)
    }
}


// //approach 2
// const patchUsername=(email,username)=>{
//     try{
//         db.run("UPDATE USERS SET USERNAME =? WHERE EMAIL = ?", [username,email],function(err){
//             if(err){
//                 console.log(err)
//             }
//         })
//     }catch(err){
//         console.log(err)
//     }
// }

const patchEmail=(newPassword,username)=>{
    try{
        db.run("UPDATE USERS SET USERNAME = ? WHERE USERNAME = ?" [newEmail,username],function(err){
            if (err){
                console.log(err)
            }
        })
    }catch(err){
        console.log(err)
    }
}